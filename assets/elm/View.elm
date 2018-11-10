module View exposing (nav, navItem, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Time exposing (utc)
import Time.Format as Time
import Types exposing (Model, Msg(..), Page(..))


navItem_ : Model -> Page -> Html Msg
navItem_ model page =
    navItem
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
        [ nav
            []
            [ navItem_ model Home
            , navItem_ model Search
            , navItem_ model Rules
            ]
        , case page of
            Home ->
                homePage model

            Search ->
                searchPage model

            Rules ->
                rulesPage model
        ]


homePage : Model -> Html Msg
homePage ({ collection } as model) =
    div
        []
        [ text <| Time.format utc "Weekday, ordDay Month Year at padHour:padMinute" collection.mod
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
    div (attributes ++ newAttributes) nodes
