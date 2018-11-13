module View exposing (nav, navItem, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, classList, href)
import Time
import Time.Format as Time
import Types exposing (Model, Msg(..), Page(..))
import Url
import Url.Builder


navItem_ : Model -> Page -> Html Msg
navItem_ model page =
    navItem
        [ href <| urlStringFromPage page
        , classList
            [ ( "selected", model.page == page )
            ]
        ]
        [ text <| pageToString page
        ]


urlStringFromPage : Page -> String
urlStringFromPage page =
    case page of
        Home ->
            "/"

        _ ->
            "/" ++ (String.toLower (pageToString page))


pageToString : Page -> String
pageToString page =
    case page of
        Home ->
            "Home"

        Search ->
            "Search"

        Rules ->
            "Rules"

        NotFound ->
            "NotFound"


view : Model -> Browser.Document Msg
view model =
    { title = "Ankiviewer - " ++ (pageToString model.page)
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    [ nav
        []
        [ navItem_ model Home
        , navItem_ model Search
        , navItem_ model Rules
        ]
    , case model.page of
        Home ->
            homePage model

        Search ->
            searchPage model

        Rules ->
            rulesPage model

        NotFound ->
            notFoundPage model

    ]


homePage : Model -> Html Msg
homePage ({ collection } as model) =
    div
        []
        [ text <| Time.format Time.utc "Weekday, ordDay Month Year at padHour:padMinute" collection.mod
        ]


searchPage : Model -> Html Msg
searchPage model =
    div
        []
        [ text "Search"
        ]


rulesPage : Model -> Html Msg
rulesPage model =
    div
        []
        [ text "Rules"
        ]


notFoundPage : Model -> Html Msg
notFoundPage model =
    div
        []
        [ text "404 - Not found"
        ]


nav : List (Html.Attribute msg) -> List (Html msg) -> Html msg
nav attributes nodes =
    let
        newAttributes =
            [ class "nav" ]
    in
    div (attributes ++ newAttributes) nodes


navItem : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navItem attributes nodes =
    let
        newAttributes =
            [ class "nav-item" ]
    in
    a (attributes ++ newAttributes) nodes
