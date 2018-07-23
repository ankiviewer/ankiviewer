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
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        GetNotes ->
            model ! [ Rest.getNotes model ]

        NewNotes (Ok notes) ->
            { model | notes = notes } ! []

        NewNotes (Err e) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        GetRules ->
            model ! [ Rest.getRules ]

        NewRules (Ok rules) ->
            let
                _ =
                    Debug.log "rules" rules
            in
                model ! []

        NewRules (Err e) ->
            let
                _ =
                    Debug.log "NewRules Err" e
            in
                model ! []

        CreateRule model ->
            model ! [ Rest.createRule model ]

        UpdateRule model ->
            model ! [ Rest.updateRule model ]

        DeleteRule model ->
            model ! [ Rest.deleteRule model ]
