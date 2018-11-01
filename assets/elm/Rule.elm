module Rule exposing (update)

import List.Extra as List
import Rest
import Types exposing (Model, Msg, Rule, Rules(..))


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
            ( { model | newRule = defaultRule }
            , Rest.createRule model
            )

        Update ->
            ( model
            , Rest.updateRule model
            )

        Delete rid ->
            ( model
            , Rest.deleteRule rid
            )

        ToggleEdit ruleRid ->
            if model.ruleEditRid == ruleRid then
                ( { model | ruleEditRid = -1, ruleEdit = defaultRule }
                , Cmd.none
                )

            else
                let
                    newRuleEdit =
                        model.rules
                            |> List.find (\{ rid } -> rid == ruleRid)
                            |> Maybe.withDefault defaultRule
                in
                ( { model | ruleEditRid = ruleRid, ruleEdit = newRuleEdit }
                , Cmd.none
                )

        AreYouSureDelete rid ->
            ( { model | areYouSureDelete = rid }
            , Cmd.none
            )

        FocusNewInputs ->
            ( { model | ruleEditRid = -1 }
            , Cmd.none
            )

        InputEditCode code ->
            ( { model | ruleEdit = { ruleEdit | code = code } }
            , Cmd.none
            )

        InputEditName name ->
            ( { model | ruleEdit = { ruleEdit | name = name } }
            , Cmd.none
            )

        InputEditTests tests ->
            ( { model | ruleEdit = { ruleEdit | tests = tests } }
            , Cmd.none
            )

        InputCode code ->
            ( { model | newRule = { newRule | code = code } }
            , Cmd.none
            )

        InputName name ->
            ( { model | newRule = { newRule | name = name } }
            , Cmd.none
            )

        InputTests tests ->
            ( { model | newRule = { newRule | tests = tests } }
            , Cmd.none
            )

        RuleNoOp ->
            ( model
            , Cmd.none
            )
