module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Home
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, classList, href)
import Http
import Rules
import Search
import Skeleton
import Url
import Url.Parser as Parser exposing (Parser, oneOf, s, top)


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
    | Search Search.Model
    | Rules Rules.Model


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | SearchMsg Search.Msg
    | RuleMsg Rules.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Home home ->
            Sub.map HomeMsg (Home.subscriptions home)

        _ ->
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

        SearchMsg msg ->
            case model.page of
                Search search ->
                    stepSearch model (Search.update msg search)

                _ ->
                    ( model, Cmd.none )

        RuleMsg msg ->
            case model.page of
                Rules rule ->
                    stepRule model (Rules.update msg rule)

                _ ->
                    ( model, Cmd.none )


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                [ route top (stepHome model Home.init)
                , route (s "search") (stepSearch model Search.init)
                , route (s "rules") (stepRule model Rules.init)
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


stepSearch : Model -> ( Search.Model, Cmd Search.Msg ) -> ( Model, Cmd Msg )
stepSearch model ( search, cmds ) =
    ( { model | page = Search search }
    , Cmd.map SearchMsg cmds
    )


stepRule : Model -> ( Rules.Model, Cmd Rules.Msg ) -> ( Model, Cmd Msg )
stepRule model ( rule, cmds ) =
    ( { model | page = Rules rule }
    , Cmd.map RuleMsg cmds
    )


view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFound ->
            Skeleton.view never
                { title = "Ankiviewer - Not Found"
                , view = text "404 - Not Found"
                , nav = nav model
                }

        Home home ->
            Skeleton.view HomeMsg
                { title = "Ankiviewer - Home"
                , view = Home.view home
                , nav = nav model
                }

        Search search ->
            Skeleton.view SearchMsg
                { title = "Ankiviewer - Search"
                , view = Search.view search
                , nav = nav model
                }

        Rules rule ->
            Skeleton.view RuleMsg
                { title = "Ankiviewer - Rules"
                , view = Rules.view rule
                , nav = nav model
                }


nav : Model -> Html Msg
nav model =
    div
        [ class "nav"
        ]
        [ navItem "/" "Home" <|
            case model.page of
                Home _ ->
                    True

                _ ->
                    False
        , navItem "/search" "Search" <|
            case model.page of
                Search _ ->
                    True

                _ ->
                    False
        , navItem "/rules" "Rules" <|
            case model.page of
                Rules _ ->
                    True

                _ ->
                    False
        ]


navItem : String -> String -> Bool -> Html Msg
navItem link t selected =
    a
        [ href link
        , class "nav-item"
        , classList
            [ ( "selected", selected ) ]
        ]
        [ text t
        ]
