module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Attributes exposing (classList, attribute, disabled, id)
import Html.Events exposing (onClick)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode exposing (Value, null)
import Json.Decode exposing (Decoder, string, int, decodeValue)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import Process
import Http


main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = PhxMsg (Socket.Msg Msg)
    | SyncDatabase
    | StopSpinner
    | SyncDatabaseLeave Value
    | SyncDatabaseMsg Value
    | GetCollection
    | NewCollection (Result Http.Error Collection)
    | NoOp


type alias Model =
    { phxSocket : Socket Msg
    , collection : Collection
    , error : Bool
    , syncingDatabase : Bool
    , syncingDatabaseMsg : String
    }


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket
    , collection = { lastModifiedDate = 0, numberNotes = 0 }
    , error = False
    , syncingDatabase = False
    , syncingDatabaseMsg = ""
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    ( initialModel, getCollection )


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Socket.on "done" "sync:database" SyncDatabaseLeave


type alias SyncMsg =
    { syncMsg : String
    }


syncDatabaseMsgDecoder : Decoder SyncMsg
syncDatabaseMsgDecoder =
    required "msg" string <| decode SyncMsg


getCollection : Cmd Msg
getCollection =
    Http.send NewCollection <| Http.get "/api/collection" collectionResdecoder


type alias Collection =
    { lastModifiedDate : Int
    , numberNotes : Int
    }


collectionResdecoder : Decoder Collection
collectionResdecoder =
    decode Collection
        |> required "last_modified_date" int
        |> required "number_notes" int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.update msg model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd ]

        SyncDatabase ->
            let
                channel =
                    Channel.init "sync:database"

                ( phxSocket, phxCmd ) =
                    Socket.join channel initialPhxSocket
            in
                { model | phxSocket = phxSocket, syncingDatabase = True } ! [ Cmd.map PhxMsg phxCmd ]

        SyncDatabaseMsg raw ->
            if model.error then
                model ! []
            else
                case decodeValue syncDatabaseMsgDecoder raw of
                    Ok { syncMsg } ->
                        { model | syncingDatabaseMsg = syncMsg } ! []

                    Err err ->
                        update (SyncDatabaseLeave null) { model | syncingDatabaseMsg = err, error = True }

        StopSpinner ->
            { model | syncingDatabase = False } ! []

        SyncDatabaseLeave _ ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.leave "sync:database" model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhxMsg phxCmd
                      , getCollection
                      , Process.sleep 600 |> Task.perform (always StopSpinner)
                      ]

        NewCollection (Ok collection) ->
            let
                _ =
                    Debug.log "x" collection
            in
                { model | collection = collection } ! []

        NewCollection (Err e) ->
            let
                _ =
                    Debug.log "e" e
            in
                model ! []

        GetCollection ->
            model ! [ getCollection ]

        NoOp ->
            model ! []


view : Model -> Html Msg
view { syncingDatabase, syncingDatabaseMsg, error, collection } =
    div []
        [ button
            [ onClick SyncDatabase
            , disabled syncingDatabase
            , attribute "data-label" "Sync Database"
            , classList
                [ ( "sync-button", True )
                , ( "syncing", syncingDatabase )
                ]
            , id "load-button"
            ]
            [ text "Sync Database" ]
        , div
            [ classList
                [ ( "dn", (not (syncingDatabase || error)) )
                , ( "red", error )
                ]
            ]
            [ text syncingDatabaseMsg ]
        , div
            []
            [ div [] [ text <| "last modified: " ++ toString collection.lastModifiedDate ]
            , div [] [ text <| "number notes: " ++ toString collection.numberNotes ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.phxSocket PhxMsg
