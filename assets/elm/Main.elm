module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, class, classList, style)
import Url
import Url.Parser as Parser exposing (Parser, oneOf, s, top)
import Http
import Json.Encode as Encode
import Home
import Skeleton


main =
    Browser.application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


type alias Model =
    { key : Nav.Key
    , page : Page
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    stepUrl url
        { key = key
        , page = NotFound
        }


type Page
    = NotFound
    | Home Home.Model
    | Search


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            stepUrl url model

        HomeMsg msg ->
            case model.page of
                Home home ->
                    stepHome model (Home.update msg home)

                _ ->
                    ( model, Cmd.none )


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser = oneOf
            [ route top (stepHome model Home.init)
            , route (s "search") ( { model | page = Search }, Cmd.none )
            ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
  Parser.map handler parser


stepHome : Model -> ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
stepHome model ( home, cmds ) =
    ( { model | page = Home home }
    , Cmd.map HomeMsg cmds
    )


view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFound ->
            Skeleton.view never
                (nav model)
                { title = "Ankiviewer - " ++ pageToString model.page
                , view = text "404 - Not Found"
                }

        Home home ->
            Skeleton.view HomeMsg
                (nav model)
                { title = "Ankiviewer - " ++ pageToString model.page
                , view = Home.view home
                }

        Search ->
            Skeleton.view never
                (nav model)
                { title = "Ankiviewer - " ++ pageToString model.page
                , view = text "Search"
                }


nav : Model -> Html Msg
nav model =
    div
        [ class "nav"
        ]
        [ navItem model (Home Home.initialModel)
        , navItem model Search
        ]


navItem : Model -> Page -> Html Msg
navItem model page =
    a
        [ href <| pageToLink page
        , class "nav-item"
        , classList [ ( "selected", model.page == page ) ]
        ]
        [ text <| pageToString page
        ]


pageToLink : Page -> String
pageToLink page =
    case page of
        Home _ ->
            "/"

        _ ->
            pageToString page
                |> String.toLower
                |> String.append "/"


pageToString : Page -> String
pageToString page =
    case page of
        Home _ ->
            "Home"

        Search ->
            "Search"

        NotFound ->
            "404 - Not Found"
