module Rule exposing (update)

import Types exposing (Model, Rule, Msg, Rules(..))
import Rest
import List.Extra as List


defaultRule : Rule
defaultRule =
    { rid = -1
    , name = ""
    , code = ""
    , tests = ""
    }


update : Rules -> Model -> ( Model, Cmd Msg )
update rules ({ newRule, ruleEdit } as model) =
    case rules of
        Add ->
            { model | newRule = defaultRule } ! [ Rest.createRule model ]

        Update ->
            model ! [ Rest.updateRule model ]

        Delete rid ->
            model ! [ Rest.deleteRule rid ]

        ToggleEdit ruleRid ->
            if model.ruleEditRid == ruleRid then
                { model | ruleEditRid = -1, ruleEdit = defaultRule } ! []
            else
                let
                    newRuleEdit =
                        model.rules
                            |> List.find (\{ rid } -> rid == ruleRid)
                            |> Maybe.withDefault defaultRule
                in
                    { model | ruleEditRid = ruleRid, ruleEdit = newRuleEdit } ! []

        AreYouSureDelete rid ->
            { model | areYouSureDelete = rid } ! []

        FocusNewInputs ->
            { model | ruleEditRid = -1 } ! []

        InputEditCode code ->
            { model | ruleEdit = { ruleEdit | code = code } } ! []

        InputEditName name ->
            { model | ruleEdit = { ruleEdit | name = name } } ! []

        InputEditTests tests ->
            { model | ruleEdit = { ruleEdit | tests = tests } } ! []

        InputCode code ->
            { model | newRule = { newRule | code = code } } ! []

        InputName name ->
            { model | newRule = { newRule | name = name } } ! []

        InputTests tests ->
            { model | newRule = { newRule | tests = tests } } ! []

        RuleNoOp ->
            model ! []
