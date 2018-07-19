module State exposing (init, update, subscriptions)

import Types
    exposing
        ( Model
        , Collection
        , Flags
        , Url
        , Msg(..)
        , RequestMsg(..)
        , WebsocketMsg(Sync)
        , SyncMsg(..)
        , Views(HomeView, SearchView)
        )
import Rest
import Phoenix.Socket as Socket exposing (Socket)
import Ports exposing (urlIn, urlOut, setColumns)
import Websocket exposing (updateSocketHelper, initialPhxSocket)
import Request
import Router exposing (router)


initialModel : Flags -> Model
initialModel flags =
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
    , noteColumns = initialNoteColumns flags
    , showingManageNoteColumns = False
    , view = HomeView
    }


initialNoteColumns : Flags -> List Bool
initialNoteColumns flags =
    case flags of
        Just columns ->
            columns

        Nothing ->
            List.range 1 12
                |> List.map (\_ -> True)


initialCollection : Collection
initialCollection =
    { mod = 0, notes = 0 }


init : Flags -> ( Model, Cmd Msg )
init flags =
    initialModel flags ! [ Rest.getCollection ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxMsg phxMsg ->
            updateSocketHelper model (Socket.update phxMsg) []

        Websocket websocketMsg ->
            Websocket.update websocketMsg model

        Request requestMsg ->
            Request.update requestMsg model

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
                { model | noteColumns = noteColumns } ! [ setColumns noteColumns ]

        ToggleManageNotes ->
            { model | showingManageNoteColumns = not model.showingManageNoteColumns } ! []

        ViewChange viewMsg ->
            Router.update viewMsg model

        UrlIn { view } ->
            { model | view = router view }
                ! case view of
                    "/search" ->
                        [ Rest.getNotes model ]

                    _ ->
                        []

        NoOp ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Socket.listen model.phxSocket PhxMsg
        , urlIn UrlIn
        ]
