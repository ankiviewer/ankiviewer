module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode


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
    | SyncDatabaseLeave Json.Encode.Value
    | SyncDatabaseMsg Json.Encode.Value
    | NoOp


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialPhxSocket : Phoenix.Socket.Socket Msg
initialPhxSocket =
    Phoenix.Socket.init socketServer
        -- |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Phoenix.Socket.on "done" "sync:database" SyncDatabaseLeave


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket }


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
                { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]

        SyncDatabaseMsg m ->
            let
                _ =
                    Debug.log "SyncDatabaseMsg" m
            in
                model ! []

        SyncDatabaseLeave _ ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.leave "sync:database" model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick LoadDatabase ] [ text "Load Database" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
