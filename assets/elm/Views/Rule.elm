module Views.Rule exposing (ruleView)

import Html exposing (Html, div, text, button, input, textarea)
import Html.Events exposing (onClick, onInput, onFocus)
import Html.Attributes exposing (value, placeholder)
import Views.Nav exposing (nav)
import List.Extra as List
import Types
    exposing
        ( Model
        , Rule
        , ErrRuleResponse
        , Msg(Websocket, RuleMsg)
        , WebsocketMsg(RunRule)
        , RunRuleMsg(RunStart, RunStop)
        , Rules(..)
        )


type InputSize
    = SmallInput
    | LargeInput


type RuleInputsType
    = RuleInputsEdit
    | RuleInputsNew


sizeInput : InputSize -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
sizeInput inputSize =
    case inputSize of
        SmallInput ->
            input

        LargeInput ->
            textarea


ruleInputs : Model -> Rule -> RuleInputsType -> Html Msg
ruleInputs { ruleEditRid, ruleValidationErr } rule ruleInputsType =
    List.zip5
        [ rule.name, rule.code, rule.tests ]
        [ "NAME", "CODE", "TESTS" ]
        (case ruleInputsType of
            RuleInputsEdit ->
                [ InputEditName, InputEditCode, InputEditTests ]

            RuleInputsNew ->
                [ InputName, InputCode, InputTests ]
        )
        [ SmallInput, LargeInput, LargeInput ]
        ([ ruleValidationErr.name, ruleValidationErr.code, ruleValidationErr.tests ]
            |> List.map
                (\s ->
                    if ruleEditRid == -1 then
                        s
                    else
                        ""
                )
        )
        |> List.map
            (\( a, b, c, d, e ) ->
                let
                    focusCmd =
                        case ruleInputsType of
                            RuleInputsEdit ->
                                RuleNoOp

                            RuleInputsNew ->
                                FocusNewInputs
                in
                    ( a, b, c, d, e, focusCmd )
            )
        |> ruleInputs_


ruleInputs_ : List ( String, String, String -> Rules, InputSize, String, Rules ) -> Html Msg
ruleInputs_ inputParams =
    div
        []
        (List.map
            (\( ruleVal, rulePlaceholder, inputMsg, inputSize, validationMsg, focusMsg ) ->
                div
                    []
                    [ sizeInput inputSize
                        [ onInput <| (inputMsg >> RuleMsg)
                        , onFocus <| RuleMsg focusMsg
                        , value ruleVal
                        , placeholder rulePlaceholder
                        ]
                        []
                    , div
                        []
                        [ text validationMsg ]
                    ]
            )
            inputParams
        )


ruleView : Model -> Html Msg
ruleView model =
    div
        []
        [ nav model
        , div
            []
            [ text model.ruleErr ]
        , div
            []
            (List.map
                (\{ name, code, tests, rid } ->
                    if model.ruleEditRid == rid then
                        div
                            []
                            [ ruleInputs model model.ruleEdit RuleInputsEdit
                            , button
                                [ onClick <| RuleMsg Update ]
                                [ text "Update" ]
                            , button
                                [ onClick <| RuleMsg (ToggleEdit rid) ]
                                [ text "Cancel" ]
                            ]
                    else
                        div
                            []
                            [ div [] [ text name ]
                            , div [] [ text code ]
                            , div [] [ text tests ]
                            , button
                                [ onClick <| RuleMsg (ToggleEdit rid) ]
                                [ text "Edit" ]
                            , if model.areYouSureDelete == rid then
                                div
                                    []
                                    [ div [] [ text "Are you sure you want to delete this rule?" ]
                                    , button
                                        [ onClick <| RuleMsg (Delete rid) ]
                                        [ text "Yes" ]
                                    , button
                                        [ onClick <| RuleMsg (AreYouSureDelete -1) ]
                                        [ text "No" ]
                                    ]
                              else
                                button
                                    [ onClick <| RuleMsg (AreYouSureDelete rid) ]
                                    [ text "Delete" ]
                            , if model.ruleRunning == rid then
                                div
                                    []
                                    [ text <| "ERR: " ++ (toString model.ruleRunError)
                                    , text <| "MSG: " ++ model.ruleRunMsg
                                    , button
                                        [ onClick <| Websocket (RunRule RunStop) ]
                                        [ text "Stop" ]
                                    ]
                              else if model.ruleRunning == -1 then
                                button
                                    [ onClick <| Websocket (RunRule (RunStart rid)) ]
                                    [ text "Run" ]
                              else
                                text ""
                            ]
                )
                model.rules
            )
        , ruleInputs model model.newRule RuleInputsNew
        , button
            [ onClick <| RuleMsg Add
            ]
            [ text "ADD" ]
        ]
