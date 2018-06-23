module State exposing (init, update, subscriptions)

import Types exposing (Model, Collection, Msg(..), Page(Home, Search))
import Rest
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (null)
import Task
import Process


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket
    , search = ""
    , model = ""
    , deck = ""
    , tags = []
    , order = []
    , rule = 0
    , collection = initialCollection
    , notes = []
    , error = False
    , syncingDatabase = False
    , syncingDatabaseMsg = ""
    , page = Home
    }


initialCollection : Collection
initialCollection =
    { mod = 0, notes = 0 }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Rest.getCollection )


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Socket.on "done" "sync:database" SyncDatabaseLeave


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
                case decodeValue Rest.syncDatabaseMsgDecoder raw of
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
                      , Rest.getCollection
                      , Process.sleep 600 |> Task.perform (always StopSpinner)
                      ]

        NewCollection (Ok collection) ->
            { model | collection = collection } ! []

        NewCollection (Err e) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        GetCollection ->
            model ! [ Rest.getCollection ]

        GetNotes ->
            model ! [ Rest.getNotes model ]

        NewNotes (Ok notes) ->
            let
                _ =
                    Debug.log "hi" (toString notes)
            in
                { model | notes = notes } ! []

        NewNotes (Err e) ->
            let
                _ =
                    Debug.log "NewNotes Err" (toString e)
            in
                model ! []

        SearchInput search ->
            let
                newModel =
                    { model | search = search }
            in
                newModel ! [ Rest.getNotes newModel ]

        PageChange page ->
            { model | page = page } ! []

        PageChangeToSearch ->
            let
                newModel =
                    { model | page = Search, search = "" }
            in
                newModel ! [ Rest.getNotes newModel ]

        NoOp ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.phxSocket PhxMsg
