port module Rules exposing
    ( Model
    , Msg
    , init
    , initialModel
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, button, div, input, label, text, textarea)
import Html.Attributes exposing (class, classList, id, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import List.Extra as List


port startRunRule : Encode.Value -> Cmd msg


port ruleRunData : (Encode.Value -> msg) -> Sub msg


ruleDataDecoder : Decoder RuleData
ruleDataDecoder =
    Decode.map2 RuleData
        (Decode.field "msg" Decode.string)
        (Decode.field "percentage" Decode.int)


type alias RuleData =
    { message : String
    , percentage : Int
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    ruleRunData RuleIncomingMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RuleInput ruleInputType s ->
            let
                ruleInput_ =
                    model.input

                ruleInput =
                    case ruleInputType of
                        RuleName ->
                            { ruleInput_ | name = s }

                        RuleCode ->
                            { ruleInput_ | code = s }

                        RuleTests ->
                            { ruleInput_ | tests = s }
            in
            ( { model | input = ruleInput, err = Nothing }, Cmd.none )

        ToggleRule ruleId ->
            case model.selected of
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
                    ( { model | selected = Just ruleId, input = ruleInput }, Cmd.none )

                Just oldSelectedRuleId ->
                    if ruleId == oldSelectedRuleId then
                        ( { model | selected = Nothing, input = Rule "" "" "" 0 }, Cmd.none )

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
                        ( { model | selected = Just ruleId, input = ruleInput }, Cmd.none )

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
                ( { model | err = Just ruleErr }, Cmd.none )

            else
                ( { model | rules = rules, err = Nothing, input = Rule "" "" "" 0 }, Cmd.none )

        NewRuleResponse (Err err) ->
            let
                _ =
                    Debug.log "jasdkfljasflsdf" err
            in
            ( model, Cmd.none )

        CreateRule ->
            ( model, createRule model.input )

        GetRules ->
            ( model, getRules )

        UpdateRule ->
            ( model, updateRule model.input )

        DeleteRule rid ->
            ( { model | input = Rule "" "" "" 0, selected = Nothing }, deleteRule rid )

        RuleIncomingMsg val ->
            case Decode.decodeValue ruleDataDecoder val of
                Ok { message, percentage } ->
                    if message == "done" then
                        ( { model | syncState = NotSyncing }, Cmd.none )

                    else
                        ( { model | syncState = Syncing ( message, percentage ) }, Cmd.none )

                Err e ->
                    let
                        _ =
                            Debug.log "e:rule" e
                    in
                    ( model, Cmd.none )

        StartRuleRun rid ->
            ( model, startRunRule (Encode.int rid) )


type alias Model =
    { rules : List Rule
    , input : Rule
    , err : Maybe Rule
    , selected : Maybe Int
    , syncState : SyncState
    }


type SyncState
    = Syncing ( String, Int )
    | NotSyncing


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


type Msg
    = RuleInput RuleInputType String
    | ToggleRule Int
    | NewRules (Result Http.Error (List Rule))
    | NewRuleResponse (Result Http.Error RuleResponse)
    | GetRules
    | CreateRule
    | UpdateRule
    | DeleteRule Int
    | RuleIncomingMsg Encode.Value
    | StartRuleRun Int


type RuleInputType
    = RuleName
    | RuleCode
    | RuleTests


init : ( Model, Cmd Msg )
init =
    ( initialModel, getRules )


initialModel : Model
initialModel =
    { rules = []
    , input = Rule "" "" "" 0
    , err = Nothing
    , selected = Nothing
    , syncState = NotSyncing
    }


getRules : Cmd Msg
getRules =
    Http.get
        { url = "/api/rules"
        , expect = Http.expectJson NewRules rulesDecoder
        }


createRule : Rule -> Cmd Msg
createRule rule =
    Http.post
        { url = "/api/rules"
        , body = Http.jsonBody (ruleEncoder rule)
        , expect = Http.expectJson NewRuleResponse ruleResponseDecoder
        }


updateRule : Rule -> Cmd Msg
updateRule rule =
    Http.request
        { method = "PUT"
        , headers = []
        , url = "/api/rules/" ++ String.fromInt rule.rid
        , body = Http.jsonBody (ruleEncoder rule)
        , expect = Http.expectJson NewRuleResponse ruleResponseDecoder
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
        , expect = Http.expectJson NewRules rulesDecoder
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
                , value (ruleKey model.input)
                , id inputId
                ]
                []
            ]
        , case Maybe.withDefault "" (Maybe.map ruleKey model.err) of
            "" ->
                text ""

            e ->
                div
                    [ class "red" ]
                    [ text e
                    ]
        ]


view : Model -> Html Msg
view model =
    div
        [ class "flex items-top" ]
        [ div
            [ class "w-80 dib" ]
            [ ruleInputItem model .name "Name:" input RuleName "h2" "rules-input_name"
            , ruleInputItem model .code "Code:" textarea RuleCode "h4" "rules-input_code"
            , ruleInputItem model .tests "Tests:" textarea RuleTests "h4" "rules-input_tests"
            , case model.selected of
                Nothing ->
                    div
                        []
                        [ button
                            [ onClick CreateRule
                            , id "rules-add_new"
                            ]
                            [ text "Add New"
                            ]
                        ]

                Just ruleId ->
                    case model.syncState of
                        NotSyncing ->
                            div
                                []
                                [ button
                                    [ onClick UpdateRule
                                    , id "rules-update_rule"
                                    ]
                                    [ text "Update Rule"
                                    ]
                                , button
                                    [ onClick <| DeleteRule ruleId
                                    , id "rules-delete_rule"
                                    ]
                                    [ text "Delete Rule"
                                    ]
                                , button
                                    [ onClick <| StartRuleRun ruleId
                                    , id "rules-run_rule"
                                    ]
                                    [ text "Run Rule"
                                    ]
                                ]

                        Syncing ( message, percentage ) ->
                            div
                                []
                                [ div
                                    []
                                    [ text message
                                    ]
                                , div
                                    []
                                    [ text (String.fromInt percentage)
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
                            [ ( "bg-primary", (model.selected |> Maybe.withDefault 0) == rule.rid )
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
