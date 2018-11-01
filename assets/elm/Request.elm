module Request exposing (update)

import Rest
import Types exposing (Model, Msg, RequestMsg(..))


update : RequestMsg -> Model -> ( Model, Cmd Msg )
update requestMsg model =
    case requestMsg of
        GetCollection ->
            ( model
            , Rest.getCollection
            )

        NewCollection (Ok collection) ->
            ( { model | collection = collection }
            , Cmd.none
            )

        NewCollection (Err e) ->
            ( { model | syncingError = True, syncingDatabaseMsg = toString e }
            , Cmd.none
            )

        GetNotes ->
            ( model
            , Rest.getNotes model
            )

        NewNotes (Ok cards) ->
            ( { model | cards = cards }
            , Cmd.none
            )

        NewNotes (Err e) ->
            ( { model | syncingError = True, syncingDatabaseMsg = toString e }
            , Cmd.none
            )

        GetRules ->
            ( { model | ruleErr = "" }
            , Rest.getRules
            )

        NewRules (Ok rules) ->
            ( { model | rules = rules }
            , Cmd.none
            )

        NewRules (Err ruleErr) ->
            ( { model | ruleErr = toString ruleErr }
            , Cmd.none
            )

        NewRuleResponse (Ok { err, rules, ruleErr }) ->
            if err then
                ( { model | ruleValidationErr = ruleErr, ruleErr = "" }
                , Cmd.none
                )

            else
                ( { model | ruleValidationErr = ruleErr, rules = rules, ruleErr = "" }
                , Cmd.none
                )

        NewRuleResponse (Err ruleErr) ->
            ( { model | ruleErr = toString ruleErr }
            , Cmd.none
            )

        CreateRule model ->
            ( model
            , Rest.createRule model
            )

        UpdateRule model ->
            ( model
            , Rest.updateRule model
            )

        DeleteRule rid ->
            ( model
            , Rest.deleteRule rid
            )
