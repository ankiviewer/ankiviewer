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
    | ReceiveDatabaseMsg Json.Encode.Value
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
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "hello" "sync:database" ReceiveDatabaseMsg


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

        ReceiveDatabaseMsg m ->
            let
                _ =
                    Debug.log "ReceiveDatabaseMsg" m
            in
                model ! []

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
