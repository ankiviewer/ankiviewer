module Views.Rule exposing (ruleView)

import Html exposing (Html, div, text, button, input, textarea)
import Html.Events exposing (onClick, onInput, onFocus)
import Html.Attributes exposing (value, placeholder)
import Types exposing (Model, Msg(RuleMsg, NoOp), Rules(..))
import Views.Nav exposing (nav)


type InputSize
    = SmallInput
    | LargeInput


sizeInput : InputSize -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
sizeInput inputSize =
    case inputSize of
        SmallInput ->
            input

        LargeInput ->
            textarea


ruleInputs : List ( String, String, String -> Msg, InputSize, String, Msg ) -> Html Msg
ruleInputs inputParams =
    div
        []
        (List.map
            (\( ruleVal, rulePlaceholder, inputMsg, inputSize, validationMsg, focusMsg ) ->
                div
                    []
                    [ sizeInput inputSize
                        [ onInput inputMsg
                        , onFocus focusMsg
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
                            [ ruleInputs
                                [ ( model.ruleEdit.name, "NAME", InputEditName >> RuleMsg, SmallInput, model.ruleValidationErr.name, NoOp )
                                , ( model.ruleEdit.code, "CODE", InputEditCode >> RuleMsg, LargeInput, model.ruleValidationErr.code, NoOp )
                                , ( model.ruleEdit.tests, "TESTS", InputEditTests >> RuleMsg, LargeInput, model.ruleValidationErr.tests, NoOp )
                                ]
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
                            ]
                )
                model.rules
            )
        , ruleInputs
            [ ( model.newRule.name
              , "NAME"
              , InputName >> RuleMsg
              , SmallInput
              , if model.ruleEditRid == -1 then
                    model.ruleValidationErr.name
                else
                    ""
              , RuleMsg FocusNewInputs
              )
            , ( model.newRule.code
              , "CODE"
              , InputCode >> RuleMsg
              , LargeInput
              , if model.ruleEditRid == -1 then
                    model.ruleValidationErr.code
                else
                    ""
              , RuleMsg FocusNewInputs
              )
            , ( model.newRule.tests
              , "TESTS"
              , InputTests >> RuleMsg
              , LargeInput
              , if model.ruleEditRid == -1 then
                    model.ruleValidationErr.tests
                else
                    ""
              , RuleMsg FocusNewInputs
              )
            ]
        , button
            [ onClick <| RuleMsg Add
            ]
            [ text "ADD" ]
        ]
