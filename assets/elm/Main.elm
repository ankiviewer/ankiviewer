module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Collection exposing (Collection)
import Home
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, classList, href)
import Http
import Page exposing (Page(..))
import Rules
import Rules.Rule exposing (Rule)
import Search
import Session exposing (Flags, Session)
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


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    stepUrl flags
        url
        { key = key
        , page = NotFound Session.empty
        }


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | SearchMsg Search.Msg
    | RuleMsg Rules.Msg
    | NewCollection (Result Http.Error Collection)
    | NewRules (Result Http.Error (List Rule))


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Home home ->
            Sub.map HomeMsg (Home.subscriptions home)

        Rules rule ->
            Sub.map RuleMsg (Rules.subscriptions rule)

        _ ->
            Sub.none


withCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withCmd newCmd ( model, cmd ) =
    ( model, Cmd.batch [ newCmd, cmd ] )


withCmds : List (Cmd Msg) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withCmds newCmds ( model, cmd ) =
    ( model, Cmd.batch (cmd :: newCmds) )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Cmd.batch [ Nav.pushUrl model.key (Url.toString url), getCollection ] )

                Browser.External href ->
                    ( model, Cmd.batch [ Nav.load href, getCollection ] )

        UrlChanged url ->
            stepUrl Nothing url model

        HomeMsg msg ->
            case model.page of
                Home home ->
                    case msg of
                        Home.StopSync ->
                            withCmd getCollection (stepHome model (Home.update Home.StopSync home))

                        _ ->
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

        NewCollection (Ok collection) ->
            ( { model | page = Page.sessionMap (Session.updateCollection collection) model.page }
            , Cmd.none
            )

        NewCollection (Err e) ->
            let
                _ =
                    Debug.log "e" e
            in
            ( model, Cmd.none )

        NewRules (Ok rules) ->
            ( { model | page = Page.sessionMap (Session.updateRules rules) model.page }
            , Cmd.none
            )

        NewRules (Err e) ->
            let
                _ =
                    Debug.log "e" e
            in
            ( model, Cmd.none )


getCollection : Cmd Msg
getCollection =
    Http.get
        { url = "/api/collection"
        , expect = Http.expectJson NewCollection Collection.collectionDecoder
        }


getRules : Cmd Msg
getRules =
    Http.get
        { url = "/api/rules"
        , expect = Http.expectJson NewRules Rules.rulesDecoder
        }


stepUrl : Flags -> Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl flags url model =
    let
        session =
            case flags of
                Nothing ->
                    Page.session model.page

                _ ->
                    Session.fromFlags flags

        parser =
            oneOf
                [ route top (stepHome model (Home.init session))
                , route (s "search") (stepSearch model (Search.init session))
                , route (s "rules") (stepRule model (Rules.init session))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            withCmds [ getCollection, getRules ] answer

        Nothing ->
            ( { model | page = NotFound Session.empty }
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
        NotFound _ ->
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
