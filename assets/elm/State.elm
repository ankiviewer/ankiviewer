port module State exposing (init, subscriptions, update)

import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import List.Extra as List
import Process
import Set
import Task
import Types
    exposing
        ( Collection
        , Card
        , D
        , M
        , ErrorType(..)
        , Flags
        , Model
        , Msg(..)
        , Page(..)
        , RequestMsg(..)
        , Rule
        , RuleResponse
        , CardSearchParams
        , RuleInputType(..)
        , SyncData
        , SyncMsg(..)
        , SyncState(..)
        )
import Url exposing (Url)
import Url.Builder as Url
import Url.Parser as Parser exposing (Parser, oneOf, s, top)
import Http


port portStartSync : Encode.Value -> Cmd msg


port portSyncMsg : (Encode.Value -> msg) -> Sub msg


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
    , page = urlToPage url
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
            ( { model | page = urlToPage url }, Cmd.none )

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
            ( { model | homeMsg = Ok (Syncing ( "", 0 )) }, portStartSync Encode.null )

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


urlToPage : Url.Url -> Page
urlToPage url =
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
    portSyncMsg (SyncIncomingMsg >> Sync)


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
