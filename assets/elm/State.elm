port module State exposing (init, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import List.Extra as List
import Process
import Set
import Task
import Types
    exposing
        ( Collection
        , ErrorType(..)
        , Flags
        , Model
        , Msg(..)
        , Page(..)
        , RequestMsg(..)
        , Rule
        , RuleInputType(..)
        , SyncData
        , SyncMsg(..)
        , SyncState(..)
        )
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf, s, top)


port portStartSync : Encode.Value -> Cmd msg


port portSyncMsg : (Encode.Value -> msg) -> Sub msg


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel url key, Cmd.batch [ Api.getCollection, Api.getRules ] )


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
            ( { model | search = search }, Api.getCards { search = search } )

        RuleInput ruleInputType ->
            ( { model | ruleInput = ruleInputUpdate model.ruleInput ruleInputType, ruleErr = Nothing }, Cmd.none )

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


ruleInputUpdate : Rule -> RuleInputType -> Rule
ruleInputUpdate ruleInput ruleInputType =
    case ruleInputType of
        RuleName name ->
            { ruleInput | name = name }

        RuleCode code ->
            { ruleInput | code = code }

        RuleTests tests ->
            { ruleInput | tests = tests }


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
            ( model, Api.createRule model.ruleInput )

        GetRules ->
            ( model, Api.getRules )

        UpdateRule ->
            ( model, Api.updateRule model.ruleInput )

        DeleteRule rid ->
            ( { model | ruleInput = Rule "" "" "" 0, selectedRule = Nothing }, Api.deleteRule rid )

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
