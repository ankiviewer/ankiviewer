module Dev exposing (Model, Msg(..), Page(..), init, main, navItem_, pageToString, update, view, viewWithCss)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (onClick)
import View


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = viewWithCss
        }


type Msg
    = NoOp
    | ChangePage Page


type Page
    = Home
    | Search
    | Rules


type alias Model =
    { page : Page
    }


init : Model
init =
    { page = Home
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        ChangePage page ->
            { model | page = page }


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
        ]


navItem_ : Model -> Page -> Html Msg
navItem_ model page =
    View.navItem
        [ onClick <| ChangePage page
        , classList
            [ ( "selected", model.page == page )
            ]
        ]
        [ text <| pageToString page
        ]


pageToString : Page -> String
pageToString page =
    case page of
        Home ->
            "Home"

        Search ->
            "Search"

        Rules ->
            "Rules"


view : Model -> Html Msg
view ({ page } as model) =
    div
        []
        [ View.nav
            []
            [ navItem_ model Home
            , navItem_ model Search
            , navItem_ model Rules
            ]
        , div
            []
            [ text <| pageToString page
            ]
        ]
