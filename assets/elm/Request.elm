module Request exposing (update)

import Types exposing (Msg, Model, RequestMsg(..))
import Rest


update : RequestMsg -> Model -> ( Model, Cmd Msg )
update requestMsg model =
    case requestMsg of
        NewCollection (Ok collection) ->
            { model | collection = collection } ! []

        NewCollection (Err e) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        GetCollection ->
            model ! [ Rest.getCollection ]

        GetNotes ->
            model ! [ Rest.getNotes model ]

        NewNotes (Ok notes) ->
            { model | notes = notes } ! []

        NewNotes (Err e) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []
