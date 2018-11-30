port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, input, label, text, textarea)
import Html.Attributes exposing (class, classList, href, id, style, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import List.Extra as List
import Process
import Set exposing (Set)
import Task
import Time
import Time.Format as Time
import Url exposing (Url)
import Url.Builder as Url
import Url.Parser as Parser exposing (Parser, oneOf, s, top)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


port startSync : Encode.Value -> Cmd msg


port syncData : (Encode.Value -> msg) -> Sub msg


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel url key
    , Cmd.batch
        [ getCollection
        , getRules
        ]
    )


initialModel : Url -> Nav.Key -> Model
initialModel url key =
    { key = key
    , page = stepUrl url
    , collection = Collection 0 0 [] []
    , homeMsg = Ok NotSyncing
    , showColumns = False
    , excludedColumns = Set.empty
    , search = ""
    , cards = []
    , rules = []
    , ruleInput = Rule "" "" "" 0
    , ruleErr = Nothing
    , selectedRule = Nothing
    }


syncDataDecoder : Decoder SyncData
syncDataDecoder =
    Decode.map2 SyncData
        (Decode.field "msg" Decode.string)
        (Decode.field "percentage" Decode.int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Request requestMsg ->
            requestUpdate model requestMsg

        Sync syncMsg ->
            syncUpdate model syncMsg

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | page = stepUrl url }, Cmd.none )

        ToggleShowColumns ->
            ( { model | showColumns = not model.showColumns }, Cmd.none )

        ToggleColumn col ->
            ( { model
                | excludedColumns =
                    if Set.member col model.excludedColumns then
                        Set.remove col model.excludedColumns

                    else
                        Set.insert col model.excludedColumns
              }
            , Cmd.none
            )

        SearchInput search ->
            ( { model | search = search }, getCards { search = search } )

        RuleInput ruleInputType s ->
            ( { model | ruleInput = ruleInputUpdate model.ruleInput ruleInputType s, ruleErr = Nothing }, Cmd.none )

        ToggleRule ruleId ->
            case model.selectedRule of
                Nothing ->
                    let
                        ruleInput =
                            List.find
                                (\{ rid } ->
                                    rid == ruleId
                                )
                                model.rules
                                |> Maybe.withDefault (Rule "" "" "" 0)
                    in
                    ( { model | selectedRule = Just ruleId, ruleInput = ruleInput }, Cmd.none )

                Just oldSelectedRuleId ->
                    if ruleId == oldSelectedRuleId then
                        ( { model | selectedRule = Nothing, ruleInput = Rule "" "" "" 0 }, Cmd.none )

                    else
                        let
                            ruleInput =
                                List.find
                                    (\{ rid } ->
                                        rid == ruleId
                                    )
                                    model.rules
                                    |> Maybe.withDefault (Rule "" "" "" 0)
                        in
                        ( { model | selectedRule = Just ruleId, ruleInput = ruleInput }, Cmd.none )

        RunRule rid ->
            let
                _ =
                    Debug.todo "handle rule running"
            in
            ( model, Cmd.none )


ruleInputUpdate : Rule -> RuleInputType -> String -> Rule
ruleInputUpdate ruleInput ruleInputType s =
    case ruleInputType of
        RuleName ->
            { ruleInput | name = s }

        RuleCode ->
            { ruleInput | code = s }

        RuleTests ->
            { ruleInput | tests = s }


requestUpdate : Model -> RequestMsg -> ( Model, Cmd Msg )
requestUpdate model requestMsg =
    case requestMsg of
        NewRules (Ok rules) ->
            ( { model | rules = rules }, Cmd.none )

        NewRules (Err err) ->
            let
                _ =
                    Debug.log "rules:err" err
            in
            ( model, Cmd.none )

        NewRuleResponse (Ok { err, ruleErr, rules }) ->
            if err then
                ( { model | ruleErr = Just ruleErr }, Cmd.none )

            else
                ( { model | rules = rules, ruleErr = Nothing, ruleInput = Rule "" "" "" 0 }, Cmd.none )

        NewRuleResponse (Err err) ->
            let
                _ =
                    Debug.log "jasdkfljasflsdf" err
            in
            ( model, Cmd.none )

        CreateRule ->
            ( model, createRule model.ruleInput )

        GetRules ->
            ( model, getRules )

        UpdateRule ->
            ( model, updateRule model.ruleInput )

        DeleteRule rid ->
            ( { model | ruleInput = Rule "" "" "" 0, selectedRule = Nothing }, deleteRule rid )

        NewCards (Ok cards) ->
            ( { model | cards = cards }, Cmd.none )

        NewCards (Err err) ->
            let
                _ =
                    Debug.log "err" err
            in
            ( model, Cmd.none )

        NewCollection (Ok collection) ->
            ( { model | collection = collection }, Cmd.none )

        NewCollection (Err e) ->
            ( { model | homeMsg = Err (HttpError (Debug.toString e)) }, Cmd.none )


syncUpdate : Model -> SyncMsg -> ( Model, Cmd Msg )
syncUpdate model syncMsg =
    case syncMsg of
        StartSync ->
            ( { model | homeMsg = Ok (Syncing ( "", 0 )) }, startSync Encode.null )

        SyncIncomingMsg val ->
            case Decode.decodeValue syncDataDecoder val of
                Ok { message, percentage } ->
                    let
                        cmd =
                            if message == "done" then
                                Process.sleep 2000
                                    |> Task.perform (\_ -> Sync StopSync)

                            else
                                Cmd.none
                    in
                    ( { model | homeMsg = Ok (Syncing ( message, percentage )) }
                    , cmd
                    )

                Err e ->
                    ( { model | homeMsg = Err (SyncError (Debug.toString e)) }, Cmd.none )

        StopSync ->
            ( { model | homeMsg = Ok NotSyncing }, Cmd.none )


stepUrl : Url.Url -> Page
stepUrl url =
    Parser.parse parser url
        |> Maybe.withDefault NotFound


parser : Parser (Page -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Search (s "search")
        , Parser.map Rules (s "rules")
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    syncData (SyncIncomingMsg >> Sync)


getRules : Cmd Msg
getRules =
    Http.get
        { url = "/api/rules"
        , expect = Http.expectJson (NewRules >> Request) rulesDecoder
        }


createRule : Rule -> Cmd Msg
createRule rule =
    Http.post
        { url = "/api/rules"
        , body = Http.jsonBody (ruleEncoder rule)
        , expect = Http.expectJson (NewRuleResponse >> Request) ruleResponseDecoder
        }


updateRule : Rule -> Cmd Msg
updateRule rule =
    Http.request
        { method = "PUT"
        , headers = []
        , url = "/api/rules/" ++ String.fromInt rule.rid
        , body = Http.jsonBody (ruleEncoder rule)
        , expect = Http.expectJson (NewRuleResponse >> Request) ruleResponseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


deleteRule : Int -> Cmd Msg
deleteRule rid =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "/api/rules/" ++ String.fromInt rid
        , body = Http.emptyBody
        , expect = Http.expectJson (NewRules >> Request) rulesDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


ruleEncoder : Rule -> Encode.Value
ruleEncoder rule =
    Encode.object
        [ ( "name", Encode.string rule.name )
        , ( "code", Encode.string rule.code )
        , ( "tests", Encode.string rule.tests )
        ]


rulesDecoder : Decoder (List Rule)
rulesDecoder =
    Decode.field "rules" (Decode.list ruleDecoder)


ruleDecoder : Decoder Rule
ruleDecoder =
    Decode.succeed Rule
        |> required "name" Decode.string
        |> required "code" Decode.string
        |> required "tests" Decode.string
        |> required "rid" Decode.int


ruleErrDecoder : Decoder Rule
ruleErrDecoder =
    Decode.succeed Rule
        |> optional "name" Decode.string ""
        |> optional "code" Decode.string ""
        |> optional "tests" Decode.string ""
        |> hardcoded 0


ruleResponseDecoder : Decoder RuleResponse
ruleResponseDecoder =
    Decode.field "err" Decode.bool
        |> Decode.andThen
            (\err ->
                if err then
                    Decode.succeed RuleResponse
                        |> hardcoded err
                        |> hardcoded []
                        |> required "params" ruleErrDecoder

                else
                    Decode.succeed RuleResponse
                        |> hardcoded err
                        |> required "params" (Decode.list ruleDecoder)
                        |> hardcoded (Rule "" "" "" 0)
            )


getCollection : Cmd Msg
getCollection =
    Http.get
        { url = "/api/collection"
        , expect = Http.expectJson (NewCollection >> Request) collectionDecoder
        }


getCards : CardSearchParams -> Cmd Msg
getCards { search } =
    let
        url =
            Url.absolute
                [ "api", "cards" ]
                [ Url.string "search" search
                , Url.string "model" ""
                , Url.string "deck" ""
                , Url.string "tags" ""
                , Url.string "modelorder" ""
                , Url.string "rule" ""
                ]
    in
    Http.get
        { url = url
        , expect = Http.expectJson (NewCards >> Request) (Decode.list cardsDecoder)
        }


cardsDecoder : Decoder Card
cardsDecoder =
    Decode.succeed Card
        |> required "model" Decode.string
        |> required "mod" Decode.int
        |> required "ord" Decode.int
        |> required "tags" (Decode.list Decode.string)
        |> required "deck" Decode.string
        |> required "ttype" Decode.int
        |> required "queue" Decode.int
        |> required "due" Decode.int
        |> required "reps" Decode.int
        |> required "lapses" Decode.int
        |> required "front" Decode.string
        |> required "back" Decode.string


collectionDecoder : Decoder Collection
collectionDecoder =
    Decode.succeed Collection
        |> required "mod" Decode.int
        |> required "cards" Decode.int
        |> required "models" modelsDecoder
        |> required "decks" decksDecoder


decksDecoder : Decoder (List D)
decksDecoder =
    Decode.list
        (Decode.succeed D
            |> required "name" Decode.string
            |> required "did" Decode.int
        )


modelsDecoder : Decoder (List M)
modelsDecoder =
    Decode.list
        (Decode.succeed M
            |> required "name" Decode.string
            |> required "mid" Decode.int
            |> required "flds" (Decode.list Decode.string)
            |> required "did" Decode.int
        )


homePage : Model -> Html Msg
homePage ({ collection } as model) =
    case model.homeMsg of
        Err (HttpError err) ->
            errorView <| "Http Error: " ++ err

        Err (SyncError err) ->
            errorView <| "Sync Error: " ++ err

        Ok (Syncing ( message, syncPercentage )) ->
            syncing
                { message = message
                , syncPercentage = syncPercentage
                }

        Ok NotSyncing ->
            info
                { mod = collection.mod
                , cards = collection.cards
                }


errorView : String -> Html Msg
errorView errorText =
    div
        [ class "red" ]
        [ text errorText
        ]


info : { mod : Int, cards : Int } -> Html Msg
info { mod, cards } =
    div
        []
        [ div
            [ class "mv2"
            , id "home-last_modified"
            ]
            [ text <| "Last modified: " ++ Time.format Time.utc "Weekday, ordDay Month Year at padHour:padMinute" mod
            ]
        , div
            [ class "mv2"
            , id "home-number_notes"
            ]
            [ text <| "Number notes: " ++ String.fromInt cards
            ]
        , button
            [ onClick <| Sync StartSync
            , class "button-primary"
            , id "home-sync_button"
            ]
            [ text "Sync Database"
            ]
        ]


syncing : { message : String, syncPercentage : Int } -> Html Msg
syncing { message, syncPercentage } =
    div
        []
        [ div
            []
            [ text <| message ++ "..."
            ]
        , div
            [ class "sync-loader"
            , id "home-sync_loader"
            ]
            [ div
                [ class "sync-bar"
                , style "width" <| String.fromInt syncPercentage ++ "%"
                ]
                []
            ]
        , div
            []
            [ text <| String.fromInt syncPercentage ++ "%"
            ]
        ]


cardColumns : List String
cardColumns =
    [ "model", "mod", "ord", "tags", "deck", "type", "queue", "due", "reps", "lapses", "front", "back" ]


pageToString : Page -> String
pageToString page =
    case page of
        Home ->
            "Home"

        Search ->
            "Search"

        Rules ->
            "Rules"

        NotFound ->
            "NotFound"


view : Model -> Browser.Document Msg
view model =
    { title = "Ankiviewer - " ++ pageToString model.page
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    [ navbar
        { items =
            [ ( Home, "Home", "/" )
            , ( Search, "Search", "/search" )
            , ( Rules, "Rules", "/rules" )
            ]
        , selected = model.page
        }
    , case model.page of
        Home ->
            homePage model

        Search ->
            searchPage model

        Rules ->
            rulesPage model

        NotFound ->
            notFoundPage model
    ]


searchPage : Model -> Html Msg
searchPage model =
    if model.showColumns then
        div
            []
            [ div
                []
                [ text "Green is showing, red is not showing, click to toggle"
                ]
            , div
                [ id "search-columns_container"
                ]
                (List.map
                    (\col ->
                        div
                            [ class "dib ma1 pointer red"
                            , classList
                                [ ( "green", not (Set.member col model.excludedColumns) )
                                ]
                            , onClick <| ToggleColumn col
                            ]
                            [ text col ]
                    )
                    cardColumns
                )
            , div
                []
                [ button
                    [ onClick ToggleShowColumns
                    , id "search-done"
                    ]
                    [ text "Done"
                    ]
                ]
            ]

    else
        div
            []
            [ div
                []
                [ input
                    [ onInput SearchInput
                    , id "search-input"
                    ]
                    []
                ]
            , if model.search == "" then
                div
                    []
                    [ button
                        [ onClick ToggleShowColumns
                        , id "search-edit_columns"
                        ]
                        [ text "Edit columns"
                        ]
                    ]

              else
                div
                    []
                    [ div
                        [ id "search-column_headers" ]
                        (let
                            columns =
                                cardColumns
                                    |> List.filter
                                        (\col ->
                                            not (Set.member col model.excludedColumns)
                                        )
                         in
                         List.map
                            (\col ->
                                div
                                    [ class "dib ma1"
                                    , style "width" <| String.fromInt (100 // List.length columns) ++ "%"
                                    ]
                                    [ text col
                                    ]
                            )
                            columns
                        )
                    , div
                        [ id "search-result-rows" ]
                        (List.map
                            (\card ->
                                cardColumns
                                    |> List.foldr
                                        (\cur acc ->
                                            if not (Set.member cur model.excludedColumns) then
                                                case cur of
                                                    "model" ->
                                                        card.model :: acc

                                                    "mod" ->
                                                        String.fromInt card.mod :: acc

                                                    "ord" ->
                                                        String.fromInt card.ord :: acc

                                                    "tags" ->
                                                        String.join ", " card.tags :: acc

                                                    "deck" ->
                                                        card.deck :: acc

                                                    "type" ->
                                                        String.fromInt card.ttype :: acc

                                                    "queue" ->
                                                        String.fromInt card.queue :: acc

                                                    "due" ->
                                                        String.fromInt card.due :: acc

                                                    "reps" ->
                                                        String.fromInt card.reps :: acc

                                                    "lapses" ->
                                                        String.fromInt card.lapses :: acc

                                                    "front" ->
                                                        card.front :: acc

                                                    "back" ->
                                                        card.back :: acc

                                                    _ ->
                                                        let
                                                            _ =
                                                                Debug.log "UNKNOWN" cur
                                                        in
                                                        acc

                                            else
                                                acc
                                        )
                                        []
                            )
                            model.cards
                            |> List.map
                                (\cards ->
                                    div
                                        [ class "ma1" ]
                                        (List.map
                                            (\card ->
                                                div
                                                    [ class "ma1 dib overflow-hidden"
                                                    , style "width" <| String.fromInt (100 // List.length cards) ++ "%"
                                                    ]
                                                    [ text card
                                                    ]
                                            )
                                            cards
                                        )
                                )
                        )
                    ]
            ]


ruleInputItem : Model -> (Rule -> String) -> String -> (List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg) -> RuleInputType -> String -> String -> Html Msg
ruleInputItem model ruleKey labelText inputType ruleInputType heightClass inputId =
    div
        []
        [ div
            [ class "ma4 flex items-center" ]
            [ label
                [ class "dib w-20"
                ]
                [ text labelText
                ]
            , inputType
                [ class <| heightClass ++ " w-70 border-box ba b--gray"
                , onInput (RuleInput ruleInputType)
                , value (ruleKey model.ruleInput)
                , id inputId
                ]
                []
            ]
        , case Maybe.withDefault "" (Maybe.map ruleKey model.ruleErr) of
            "" ->
                text ""

            e ->
                div
                    [ class "red" ]
                    [ text e
                    ]
        ]


rulesPage : Model -> Html Msg
rulesPage model =
    div
        [ class "flex items-top" ]
        [ div
            [ class "w-80 dib" ]
            [ ruleInputItem model .name "Name:" input RuleName "h2" "rules-input_name"
            , ruleInputItem model .code "Code:" textarea RuleCode "h4" "rules-input_code"
            , ruleInputItem model .tests "Tests:" textarea RuleTests "h4" "rules-input_tests"
            , case model.selectedRule of
                Nothing ->
                    div
                        []
                        [ button
                            [ onClick <| Request CreateRule
                            , id "rules-add_new"
                            ]
                            [ text "Add New"
                            ]
                        ]

                Just ruleId ->
                    div
                        []
                        [ button
                            [ onClick <| Request UpdateRule
                            , id "rules-update_rule"
                            ]
                            [ text "Update Rule"
                            ]
                        , button
                            [ onClick <| Request (DeleteRule ruleId)
                            , id "rules-delete_rule"
                            ]
                            [ text "Delete Rule"
                            ]
                        , button
                            [ onClick <| RunRule ruleId
                            , id "rules-run_rule"
                            ]
                            [ text "Run Rule"
                            ]
                        ]
            ]
        , div
            [ class "w-20 dib mv4 mr2"
            , id "rules-rules_container"
            ]
            (List.map
                (\rule ->
                    div
                        [ classList
                            [ ( "bg-primary", (model.selectedRule |> Maybe.withDefault 0) == rule.rid )
                            ]
                        , class "pa1 pointer"
                        , onClick <| ToggleRule rule.rid
                        ]
                        [ text rule.name
                        ]
                )
                model.rules
            )
        ]


notFoundPage : Model -> Html Msg
notFoundPage model =
    div
        []
        [ text "404 - Not found"
        ]


navbar : { items : List ( b, String, String ), selected : b } -> Html Msg
navbar { items, selected } =
    div
        [ class "nav" ]
        (List.map
            (\( identifier, content, link ) ->
                a
                    [ class "nav-item"
                    , classList [ ( "selected", identifier == selected ) ]
                    , href link
                    ]
                    [ text content
                    ]
            )
            items
        )


type alias Flags =
    {}


type alias Model =
    { key : Nav.Key
    , page : Page
    , collection : Collection
    , homeMsg : Result ErrorType SyncState
    , showColumns : Bool
    , excludedColumns : Set String
    , search : String
    , cards : List Card
    , rules : List Rule
    , ruleInput : Rule
    , ruleErr : Maybe Rule
    , selectedRule : Maybe Int
    }


type alias Rule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    }


type alias RuleResponse =
    { err : Bool
    , rules : List Rule
    , ruleErr : Rule
    }


type SyncState
    = Syncing ( String, Int )
    | NotSyncing


type ErrorType
    = HttpError String
    | SyncError String


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Request RequestMsg
    | Sync SyncMsg
    | ToggleShowColumns
    | ToggleColumn String
    | SearchInput String
    | RuleInput RuleInputType String
    | ToggleRule Int
    | RunRule Int


type SyncMsg
    = StartSync
    | StopSync
    | SyncIncomingMsg Encode.Value


type RequestMsg
    = NewCollection (Result Http.Error Collection)
    | NewRules (Result Http.Error (List Rule))
    | NewRuleResponse (Result Http.Error RuleResponse)
    | NewCards (Result Http.Error (List Card))
    | GetRules
    | CreateRule
    | UpdateRule
    | DeleteRule Int


type RuleInputType
    = RuleName
    | RuleCode
    | RuleTests


type Page
    = Home
    | Search
    | Rules
    | NotFound


type alias Collection =
    { mod : Int
    , cards : Int
    , models : List M
    , decks : List D
    }


type alias M =
    { name : String
    , mid : Int
    , flds : List String
    , did : Int
    }


type alias D =
    { name : String
    , did : Int
    }


type alias SyncData =
    { message : String
    , percentage : Int
    }


type alias Card =
    { model : String
    , mod : Int
    , ord : Int
    , tags : List String
    , deck : String
    , ttype : Int
    , queue : Int
    , due : Int
    , reps : Int
    , lapses : Int
    , front : String
    , back : String
    }


type alias CardSearchParams =
    { search : String
    }
