module State exposing (init, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Types
    exposing
        ( Collection
        , ErrorType(..)
        , Flags
        , Model
        , Msg(..)
        , Page(..)
        )
import Url exposing (Url)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel url key, Api.getCollection )


initialModel : Url -> Nav.Key -> Model
initialModel url key =
    { incomingMsg = ""
    , error = None
    , syncPercentage = 0
    , isSyncing = False
    , collection = Collection 0 0 [] []
    , key = key
    , url = url
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewCollection (Ok collection) ->
            ( { model | collection = collection }, Cmd.none )

        NewCollection (Err e) ->
            ( { model | error = HttpError, incomingMsg = "Http error has occurred" }, Cmd.none )

        GetCollection ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
