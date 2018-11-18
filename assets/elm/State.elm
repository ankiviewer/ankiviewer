port module State exposing (init, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Process
import Task
import Types
    exposing
        ( Collection
        , ErrorType(..)
        , Flags
        , Model
        , Msg(..)
        , Page(..)
        , SyncData
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
    { key = key
    , page = urlToPage url
    , collection = Collection 0 0 [] []
    , incomingMsg = ""
    , error = None
    , syncPercentage = 0
    , isSyncing = False
    , columns = []
    , showColumns = False
    }


syncDataDecoder : Decoder SyncData
syncDataDecoder =
    Decode.map2 SyncData
        (Decode.field "msg" Decode.string)
        (Decode.field "percentage" Decode.int)


delay time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)


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
            case Decode.decodeValue syncDataDecoder val of
                Ok { message, percentage } ->
                    let
                        cmd =
                            if message == "done" then
                                delay 2000 StopSync

                            else
                                Cmd.none
                    in
                    ( { model | incomingMsg = message, syncPercentage = percentage }
                    , cmd
                    )

                Err e ->
                    let
                        _ =
                            Debug.log "e" e
                    in
                    ( { model | error = SyncError }, Cmd.none )

        StopSync ->
            ( { model | isSyncing = False }, Cmd.none )

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
