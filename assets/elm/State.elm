module State exposing (init, update, subscriptions)

import Types
    exposing
        ( Model
        , Collection
        , Msg(..)
        , SyncingMsg(..)
        , RequestMsg(..)
        , Views(HomeView, SearchView)
        )
import Rest
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (null)
import Task
import Process


socketServer : String
socketServer =
    "ws://localhost:5000/socket/websocket"


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
    , view = HomeView
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
        |> Socket.on "sync:msg" "sync:database" (Receive >> Sync)
        |> Socket.on "done" "sync:database" (Stopping >> Sync)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxMsg phxMsg ->
            updateSocket model (Socket.update phxMsg) []

        Sync Start ->
            updateSocket { model | syncingDatabase = True } (Socket.join (Channel.init "sync:database")) []

        Sync (Receive raw) ->
            if model.error then
                model ! []
            else
                case decodeValue Rest.syncDatabaseMsgDecoder raw of
                    Ok { syncMsg } ->
                        { model | syncingDatabaseMsg = syncMsg } ! []

                    Err err ->
                        update (Sync (Stopping null)) { model | syncingDatabaseMsg = err, error = True }

        Sync Stop ->
            { model | syncingDatabase = False } ! []

        Sync (Stopping _) ->
            updateSocket model (Socket.leave "sync:database") [ Rest.getCollection, Process.sleep 600 |> Task.perform (always (Sync Stop)) ]

        Request (NewCollection (Ok collection)) ->
            { model | collection = collection } ! []

        Request (NewCollection (Err e)) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        Request GetCollection ->
            model ! [ Rest.getCollection ]

        Request GetNotes ->
            model ! [ Rest.getNotes model ]

        Request (NewNotes (Ok notes)) ->
            { model | notes = notes } ! []

        Request (NewNotes (Err e)) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        SearchInput search ->
            updatedModel { model | search = search } Rest.getNotes

        ViewChange SearchView ->
            updatedModel { model | view = SearchView, search = "" } Rest.getNotes

        ViewChange view ->
            { model | view = view } ! []

        NoOp ->
            model ! []


updateSocket : Model -> (Socket Msg -> ( Socket Msg, Cmd (Socket.Msg Msg) )) -> List (Cmd Msg) -> ( Model, Cmd Msg )
updateSocket model socketCmd cmds =
    let
        ( phxSocket, phxCmd ) =
            socketCmd model.phxSocket
    in
        { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd, Cmd.batch cmds ]


updatedModel : Model -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
updatedModel model modelFn =
    model ! [ modelFn model ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.phxSocket PhxMsg
