module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Attributes exposing (classList, attribute, disabled, id)
import Html.Events exposing (onClick)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode exposing (Value, null)
import Json.Decode exposing (Decoder, string, decodeValue)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import Process


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
    | NoOp


type alias Model =
    { phxSocket : Socket Msg
    , error : Bool
    , syncingDatabase : Bool
    , syncingDatabaseMsg : String
    }


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket
    , error = False
    , syncingDatabase = False
    , syncingDatabaseMsg = ""
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


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
                      , Process.sleep 600 |> Task.perform (always StopSpinner)
                      ]

        NoOp ->
            model ! []


view : Model -> Html Msg
view { syncingDatabase, syncingDatabaseMsg, error } =
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
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.phxSocket PhxMsg
