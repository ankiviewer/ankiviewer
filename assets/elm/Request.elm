module Request exposing (update)

import Types exposing (Msg, Model, RequestMsg(..))
import Rest


update : RequestMsg -> Model -> ( Model, Cmd Msg )
update requestMsg model =
    case requestMsg of
        GetCollection ->
            model ! [ Rest.getCollection ]

        NewCollection (Ok collection) ->
            { model | collection = collection } ! []

        NewCollection (Err e) ->
            { model | syncingError = True, syncingDatabaseMsg = toString e } ! []

        GetNotes ->
            model ! [ Rest.getNotes model ]

        NewNotes (Ok notes) ->
            { model | notes = notes } ! []

        NewNotes (Err e) ->
            { model | syncingError = True, syncingDatabaseMsg = toString e } ! []

        GetRules ->
            { model | ruleErr = "" } ! [ Rest.getRules ]

        NewRules (Ok rules) ->
            { model | rules = rules } ! []

        NewRules (Err ruleErr) ->
            { model | ruleErr = toString ruleErr } ! []

        NewRuleResponse (Ok { err, rules, ruleErr }) ->
            if err then
                { model | ruleValidationErr = ruleErr, ruleErr = "" } ! []
            else
                { model | ruleValidationErr = ruleErr, rules = rules } ! []

        NewRuleResponse (Err ruleErr) ->
            { model | ruleErr = toString ruleErr } ! []

        CreateRule model ->
            model ! [ Rest.createRule model ]

        UpdateRule model ->
            model ! [ Rest.updateRule model ]

        DeleteRule rid ->
            model ! [ Rest.deleteRule rid ]
