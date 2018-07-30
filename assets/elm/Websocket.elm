module Websocket exposing (update, updateSocketHelper, initialPhxSocket)

import Types exposing (Msg(PhxMsg, Websocket), Model, WebsocketMsg(Sync, RunRule), SyncMsg(..), RunRuleMsg(..))
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Rest
import Task
import Process
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode exposing (null)


socketServer : String
socketServer =
    "ws://localhost:5000/socket/websocket"


update : WebsocketMsg -> Model -> ( Model, Cmd Msg )
update websocketMsg model =
    case websocketMsg of
        Sync syncMsg ->
            sync syncMsg model

        RunRule runRuleMsg ->
            runRule runRuleMsg model


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" (Receive >> Sync >> Websocket)
        |> Socket.on "done" "sync:database" (Stopping >> Sync >> Websocket)
        |> Socket.on "run:msg" "run:rule" (RunReceive >> RunRule >> Websocket)
        |> Socket.on "done" "run:rule" (RunStopping >> RunRule >> Websocket)


sync : SyncMsg -> Model -> ( Model, Cmd Msg )
sync syncMsg model =
    case syncMsg of
        Start ->
            updateSocketHelper { model | syncingDatabase = True } (Socket.join (Channel.init "sync:database")) []

        Receive raw ->
            if model.syncingError then
                model ! []
            else
                case decodeValue Rest.msgDecoder raw of
                    Ok { decodedMsg } ->
                        { model | syncingDatabaseMsg = decodedMsg } ! []

                    Err err ->
                        sync (Stopping null) { model | syncingDatabaseMsg = err, syncingError = True }

        Stop ->
            { model | syncingDatabase = False } ! []

        Stopping _ ->
            updateSocketHelper model (Socket.leave "sync:database") [ Rest.getCollection, Process.sleep 600 |> Task.perform (\_ -> Websocket (Sync Stop)) ]


runRule : RunRuleMsg -> Model -> ( Model, Cmd Msg )
runRule runRuleMsg model =
    case runRuleMsg of
        RunStart rid ->
            updateSocketHelper
                { model | ruleRunning = rid }
                (Socket.join (Channel.init "run:rule"
                    |> Channel.withPayload
                        (Encode.object
                            [ ( "rid", Encode.int rid ) ]
                        )
                    )
                )
                []

        RunReceive raw ->
          case decodeValue Rest.msgDecoder raw of
            Ok { decodedMsg } ->
                { model | ruleRunMsg = decodedMsg } ! []

            Err err ->
                { model | ruleRunError = True, ruleRunMsg = err } ! []

        RunSendStop ->
            model ! []

        RunStopping _ ->
            updateSocketHelper model (Socket.leave "run:rule") [ Process.sleep 600 |> Task.perform (\_ -> Websocket (RunRule RunStop)) ]

        RunStop ->
           { model | ruleRunning = -1 } ! []


updateSocketHelper : Model -> (Socket Msg -> ( Socket Msg, Cmd (Socket.Msg Msg) )) -> List (Cmd Msg) -> ( Model, Cmd Msg )
updateSocketHelper model socketCmd cmds =
    let
        ( phxSocket, phxCmd ) =
            socketCmd model.phxSocket
    in
        { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd, Cmd.batch cmds ]
