module State exposing (init, update, subscriptions)

import Types exposing
    ( Model
    , Flags
    , Collection
    , Msg(..)
    , ErrorType(..)
    )
import Api

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Api.getCollection )

initialModel : Model
initialModel =
    { incomingMsg = ""
    , error = None
    , syncPercentage = 0
    , isSyncing = False
    , collection = Collection 0 0 [] []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewCollection (Ok collection) ->
            ( { model | collection = collection }, Cmd.none )

        NewCollection (Err e) ->
            ( { model | error = HttpError, incomingMsg = "Http error has occurred" }, Cmd.none)

        GetCollection ->
            ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
