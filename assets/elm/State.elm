module State exposing (init, update, subscriptions)

import Types
    exposing
        ( Model
        , Collection
        , Rule
        , ErrRuleResponse
        , Flags
        , Url
        , Msg(..)
        , RequestMsg(..)
        , WebsocketMsg(Sync)
        , SyncMsg(..)
        , Views(HomeView)
        )
import Rest
import Phoenix.Socket as Socket exposing (Socket)
import Ports exposing (urlIn, urlOut, setColumns)
import Websocket exposing (updateSocketHelper, initialPhxSocket)
import Request
import Router exposing (router)
import Rule


initialModel : Flags -> Model
initialModel flags =
    { phxSocket = initialPhxSocket
    , search = ""
    , model = ""
    , deck = ""
    , tags = []
    , order = []
    , rule = -1
    , rules = []
    , ruleEditRid = -1
    , ruleEdit = initialRule
    , ruleErr = ""
    , ruleValidationErr = initialErrRuleResponse
    , areYouSureDelete = -1
    , ruleRunning = -1
    , ruleRunError = False
    , ruleRunMsg = ""
    , newRule = initialRule
    , collection = initialCollection
    , notes = []
    , syncingError = False
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


initialRule : Rule
initialRule =
    { rid = -1
    , name = ""
    , code = ""
    , tests = ""
    }


initialErrRuleResponse : ErrRuleResponse
initialErrRuleResponse =
    { code = ""
    , tests = ""
    , name = ""
    }


initialCollection : Collection
initialCollection =
    { mod = -1
    , notes = -1
    , models = []
    , decks = []
    }


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

        ToggleDeck deck ->
            let
                newDeck =
                    if deck == model.deck then
                        ""
                    else
                        deck

                newModel =
                    { model | deck = newDeck }
            in
                newModel ! [ Rest.getNotes newModel ]

        ToggleModel m ->
            let
                newM =
                    if m == model.model then
                        ""
                    else
                        m

                newModel =
                    { model | model = newM }
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

                    "/rules" ->
                        [ Rest.getRules ]

                    _ ->
                        []

        NoOp ->
            model ! []

        RuleMsg ruleMsg ->
            Rule.update ruleMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Socket.listen model.phxSocket PhxMsg
        , urlIn UrlIn
        ]
