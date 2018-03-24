module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Attributes exposing (classList, attribute, disabled, id)
import Html.Events exposing (onClick)
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode
import Json.Decode
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
    = PhoenixMsg (Socket.Msg Msg)
    | SyncDatabase
    | StopSpinner
    | SyncDatabaseLeave Json.Encode.Value
    | SyncDatabaseMsg Json.Encode.Value
    | NoOp


type alias Model =
    { phxSocket : Socket.Socket Msg
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


initialPhxSocket : Socket.Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Socket.on "done" "sync:database" SyncDatabaseLeave


type alias SyncMsg =
    { syncMsg : String
    }


syncDatabaseMsgDecoder : Json.Decode.Decoder SyncMsg
syncDatabaseMsgDecoder =
    Json.Decode.map SyncMsg
        (Json.Decode.field "msg" Json.Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.update msg model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]

        SyncDatabase ->
            let
                channel =
                    Channel.init "sync:database"

                ( phxSocket, phxCmd ) =
                    Socket.join channel initialPhxSocket
            in
                { model | phxSocket = phxSocket, syncingDatabase = True } ! [ Cmd.map PhoenixMsg phxCmd ]

        SyncDatabaseMsg raw ->
            if model.error then
                model ! []
            else
                case Json.Decode.decodeValue syncDatabaseMsgDecoder raw of
                    Ok { syncMsg } ->
                        { model | syncingDatabaseMsg = syncMsg } ! []

                    Err err ->
                        update (SyncDatabaseLeave Json.Encode.null) { model | syncingDatabaseMsg = err, error = True }

        StopSpinner ->
            { model | syncingDatabase = False } ! []

        SyncDatabaseLeave _ ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.leave "sync:database" model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhoenixMsg phxCmd
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
    Socket.listen model.phxSocket PhoenixMsg
