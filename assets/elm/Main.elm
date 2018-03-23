module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Attributes exposing (classList, attribute, disabled, id)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
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
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | LoadDatabase
    | StopSpinner
    | SyncDatabaseLeave Json.Encode.Value
    | SyncDatabaseMsg Json.Encode.Value
    | NoOp


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , loadingDatabase : Bool
    , loadingDatabaseMsg : String
    }


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket
    , loadingDatabase = False
    , loadingDatabaseMsg = ""
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialPhxSocket : Phoenix.Socket.Socket Msg
initialPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Phoenix.Socket.on "done" "sync:database" SyncDatabaseLeave


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
                    Phoenix.Socket.update msg model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]

        LoadDatabase ->
            let
                channel =
                    Phoenix.Channel.init "sync:database"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel initialPhxSocket
            in
                { model | phxSocket = phxSocket, loadingDatabase = True } ! [ Cmd.map PhoenixMsg phxCmd ]

        SyncDatabaseMsg raw ->
            case Json.Decode.decodeValue syncDatabaseMsgDecoder raw of
                Ok { syncMsg } ->
                    { model | loadingDatabaseMsg = syncMsg } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "SyncDatabaseMsg" err
                    in
                        model ! []

        StopSpinner ->
            { model | loadingDatabase = False } ! []

        SyncDatabaseLeave _ ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.leave "sync:database" model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhoenixMsg phxCmd
                      , Process.sleep 600 |> Task.perform (always StopSpinner)
                      ]

        NoOp ->
            model ! []


view : Model -> Html Msg
view { loadingDatabase, loadingDatabaseMsg } =
    div []
        [ button
            [ onClick LoadDatabase
            , disabled loadingDatabase
            , attribute "data-label" "Load Database"
            , classList
                [ ( "load-button", True )
                , ( "loading", loadingDatabase )
                ]
            , id "load-button"
            ]
            [ text "Load Database" ]
        , div
            [ classList [ ( "dn", not loadingDatabase ) ]
            ]
            [ text loadingDatabaseMsg ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
