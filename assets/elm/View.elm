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


navItem_ : Model -> String -> Html Msg
navItem_ model urlString =
    navItem
        [ href urlString
        , classList
            [ ( "selected", Url.toString model.url == urlString )
            ]
        ]
        [ text <| urlStringToString urlString
        ]


urlStringToString : String -> String
urlStringToString urlString =
    case urlString of
        "/" ->
            "Home"

        "/search" ->
            "Search"

        "/rules" ->
            "Rules"

        _ ->
            "Unknown"


view : Model -> Browser.Document Msg
view model =
    { title = "Ankiviewer - " ++ (model.url |> Url.toString |> urlStringToString)
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    let
        _ =
            Debug.log "model.url.path" model.url.path
    in
    [ nav
        []
        [ navItem_ model "/"
        , navItem_ model "/search"
        , navItem_ model "/rules"
        ]
    , case model.url.path of
        "/search" ->
            searchPage model

        "/rules" ->
            rulesPage model

        _ ->
            homePage model
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
