port module State exposing (init, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode
import Json.Encode as Encode
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
import Url.Parser as Parser exposing (Parser, oneOf, s, top)


port startSync : Encode.Value -> Cmd msg


port syncMsg : (Encode.Value -> msg) -> Sub msg


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
    , page = urlToPage url
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

        StartSync ->
            ( { model | isSyncing = True }, startSync Encode.null )

        SyncMsg val ->
            case Decode.decodeValue (Decode.field "msg" Decode.string) val of
                Ok "done" ->
                    ( { model | isSyncing = False }, Cmd.none )

                Ok message ->
                    ( { model | incomingMsg = message }, Cmd.none )

                Err e ->
                    ( { model | error = SyncError }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | page = urlToPage url }, Cmd.none )


urlToPage : Url.Url -> Page
urlToPage url =
    Parser.parse parser url
        |> Maybe.withDefault NotFound


parser : Parser (Page -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Search (s "search")
        , Parser.map Rules (s "rules")
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    syncMsg SyncMsg
