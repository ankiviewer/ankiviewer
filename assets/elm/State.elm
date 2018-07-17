port module State exposing (init, update, subscriptions)

import Types
    exposing
        ( Model
        , Collection
        , Msg(..)
        , SyncingMsg(..)
        , RequestMsg(..)
        , Views(HomeView, SearchView)
        , Url
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
    , noteColumns = initialNoteColumns
    , showingManageNoteColumns = False
    , view = HomeView
    }


initialNoteColumns : List Bool
initialNoteColumns =
    List.range 1 12
        |> List.map (\_ -> True)


initialCollection : Collection
initialCollection =
    { mod = 0, notes = 0 }


init : ( Model, Cmd Msg )
init =
    initialModel ! [ Rest.getCollection ]


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" (Receive >> Sync)
        |> Socket.on "done" "sync:database" (Stopping >> Sync)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxMsg phxMsg ->
            updateSocketHelper model (Socket.update phxMsg) []

        Sync Start ->
            updateSocketHelper { model | syncingDatabase = True } (Socket.join (Channel.init "sync:database")) []

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
            updateSocketHelper model (Socket.leave "sync:database") [ Rest.getCollection, Process.sleep 600 |> Task.perform (\_ -> (Sync Stop)) ]

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
            let
                newModel =
                    { model | search = search }
            in
                newModel ! [ Rest.getNotes newModel ]

        ToggleNoteColumn index ->
            let
                noteColumns =
                    List.indexedMap
                        (\i nc ->
                            if i == index then
                                not nc
                            else
                                nc
                        )
                        model.noteColumns
            in
                { model | noteColumns = noteColumns } ! []

        ToggleManageNotes ->
            { model | showingManageNoteColumns = not model.showingManageNoteColumns } ! []

        ViewChange SearchView ->
            { model | view = SearchView }
                ! [ Rest.getNotes model, toString SearchView |> Url |> urlOut ]

        ViewChange view ->
            { model | view = view } ! [ toString view |> Url |> urlOut ]

        UrlIn { view } ->
            { model | view = router view }
                ! case view of
                    "/search" ->
                        [ Rest.getNotes model ]

                    _ ->
                        []

        NoOp ->
            model ! []


updateSocketHelper : Model -> (Socket Msg -> ( Socket Msg, Cmd (Socket.Msg Msg) )) -> List (Cmd Msg) -> ( Model, Cmd Msg )
updateSocketHelper model socketCmd cmds =
    let
        ( phxSocket, phxCmd ) =
            socketCmd model.phxSocket
    in
        { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd, Cmd.batch cmds ]


router : String -> Views
router viewString =
    case viewString of
        "/" ->
            HomeView

        "/search" ->
            SearchView

        _ ->
            HomeView


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Socket.listen model.phxSocket PhxMsg
        , urlIn UrlIn
        ]


port urlIn : (Url -> msg) -> Sub msg


port urlOut : Url -> Cmd msg
