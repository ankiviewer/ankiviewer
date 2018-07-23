module Views.Rule exposing (ruleView)

import Html exposing (Html, div, text, button, input, textarea)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (value, placeholder)
import Types exposing (Model, Msg(RuleMsg), Rules(..))
import Views.Nav exposing (nav)


ruleView : Model -> Html Msg
ruleView model =
    div
        []
        [ nav model
        , div
            []
            (List.map
                (\{ name, code, tests, rid } ->
                    text <| "RULE:" ++ (toString rid)
                )
                model.rules
            )
        , div
            []
            [ input
                [ onInput <| InputName >> RuleMsg
                , value model.newRule.name
                , placeholder "NAME"
                ]
                []
            ]
        , div
            []
            [ textarea
                [ onInput <| InputCode >> RuleMsg
                , value model.newRule.code
                , placeholder "CODE"
                ]
                []
            ]
        , div
            []
            [ textarea
                [ onInput <| InputTests >> RuleMsg
                , value model.newRule.tests
                , placeholder "TESTS"
                ]
                []
            ]
        , button
            [ onClick <| RuleMsg Add
            ]
            [ text "ADD" ]
        ]
