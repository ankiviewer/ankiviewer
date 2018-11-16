module Dev exposing (HomeView(..), Model, Msg(..), Page(..), control, errorView, home, homeInfo, init, main, navbar, rules, search, update, view, viewWithCss)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Types
import View


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = viewWithCss
        }


type alias Model =
    { page : Page
    , homeView : HomeView
    }


init : Model
init =
    { page = Home
    , homeView = Syncing
    }


type Msg
    = NoOp
    | ChangePage Page
    | ChangeHome HomeView


type Page
    = Home
    | Search
    | Rules


type HomeView
    = Error
    | Syncing
    | Info


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        ChangePage page ->
            { model | page = page }

        ChangeHome homeView ->
            { model | homeView = homeView }


viewWithCss : Model -> Html Msg
viewWithCss model =
    div
        []
        [ Html.node "link"
            [ Html.Attributes.rel "stylesheet"
            , Html.Attributes.href "app.css"
            ]
            []
        , view model
        , control model
        ]


navbar : { items : List ( a, String, String ), selected : a } -> Html Msg
navbar args =
    Html.map (\_ -> NoOp) <| View.navbar args


syncing : { message : String, syncPercentage : Int } -> Html Msg
syncing args =
    Html.map (\_ -> NoOp) <| View.syncing args


homeInfo : { mod : Int, cards : Int } -> Html Msg
homeInfo args =
    Html.map (\_ -> NoOp) <| View.homeInfo args


errorView : String -> Html Msg
errorView str =
    Html.map (\_ -> NoOp) <| View.errorView str


view : Model -> Html Msg
view model =
    div
        []
        [ navbar
            { items =
                [ ( Home, "Home", "#" )
                , ( Search, "Search", "#" )
                , ( Rules, "Rules", "#" )
                ]
            , selected = model.page
            }
        , case model.page of
            Home ->
                home model

            Search ->
                search model

            Rules ->
                rules model
        ]


home : Model -> Html Msg
home model =
    case model.homeView of
        Error ->
            errorView "Error fetching collection data"

        Syncing ->
            syncing
                { message = "Updating Cards", syncPercentage = 2 }

        Info ->
            homeInfo
                { mod = 1514764800000, cards = 6123 }


search : Model -> Html Msg
search model =
    text "searchView"


rules : Model -> Html Msg
rules model =
    text "rulesView"


control : Model -> Html Msg
control model =
    div
        [ style "margin-top" "5rem"
        , style "padding" "1rem"
        ]
        [ div
            []
            [ text "Page:"
            ]
        , div
            []
            [ button [ onClick <| ChangePage Home ] [ text "Home" ]
            , button [ onClick <| ChangePage Search ] [ text "Search" ]
            , button [ onClick <| ChangePage Rules ] [ text "Rules" ]
            ]
        , div
            []
            [ text "Home:"
            ]
        , div
            []
            [ button
                [ onClick <| ChangeHome Error
                ]
                [ text "Error"
                ]
            , button
                [ onClick <| ChangeHome Syncing
                ]
                [ text "Syncing"
                ]
            , button
                [ onClick <| ChangeHome Info
                ]
                [ text "Info"
                ]
            ]
        ]
