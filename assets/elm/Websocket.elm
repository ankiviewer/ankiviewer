module Websocket exposing (update, updateSocketHelper, initialPhxSocket)

import Types exposing (Msg(PhxMsg, Websocket), Model, WebsocketMsg(Sync), SyncMsg(..))
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Rest
import Task
import Process
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (null)


socketServer : String
socketServer =
    "ws://localhost:5000/socket/websocket"


update : WebsocketMsg -> Model -> ( Model, Cmd Msg )
update websocketMsg model =
    case websocketMsg of
        Sync syncMsg ->
            sync syncMsg model


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" (Receive >> Sync >> Websocket)
        |> Socket.on "done" "sync:database" (Stopping >> Sync >> Websocket)


sync : SyncMsg -> Model -> ( Model, Cmd Msg )
sync syncMsg model =
    case syncMsg of
        Start ->
            updateSocketHelper { model | syncingDatabase = True } (Socket.join (Channel.init "sync:database")) []

        Receive raw ->
            if model.syncingError then
                model ! []
            else
                case decodeValue Rest.syncDatabaseMsgDecoder raw of
                    Ok { syncMsg } ->
                        { model | syncingDatabaseMsg = syncMsg } ! []

                    Err err ->
                        sync (Stopping null) { model | syncingDatabaseMsg = err, syncingError = True }

        Stop ->
            { model | syncingDatabase = False } ! []

        Stopping _ ->
            updateSocketHelper model (Socket.leave "sync:database") [ Rest.getCollection, Process.sleep 600 |> Task.perform (\_ -> Websocket (Sync Stop)) ]


updateSocketHelper : Model -> (Socket Msg -> ( Socket Msg, Cmd (Socket.Msg Msg) )) -> List (Cmd Msg) -> ( Model, Cmd Msg )
updateSocketHelper model socketCmd cmds =
    let
        ( phxSocket, phxCmd ) =
            socketCmd model.phxSocket
    in
        { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd, Cmd.batch cmds ]
