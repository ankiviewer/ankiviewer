module View exposing (body, errorView, homeInfo, homePage, navbar, notFoundPage, pageToString, rulesPage, searchPage, syncing, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (class, classList, href, style)
import Html.Events exposing (onClick)
import Time
import Time.Format as Time
import Types exposing (ErrorType(..), Model, Msg(..), Page(..))
import Url
import Url.Builder


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
    { title = "Ankiviewer - " ++ pageToString model.page
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    [ navbar
        { items =
            [ ( Home, "Home", "/" )
            , ( Search, "Search", "/search" )
            , ( Rules, "Rules", "/rules" )
            ]
        , selected = model.page
        }
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


errorView : String -> Html Msg
errorView errorText =
    div
        [ class "red" ]
        [ text errorText
        ]


homePage : Model -> Html Msg
homePage ({ collection } as model) =
    case model.error of
        HttpError ->
            errorView "Error fetching collection data"

        SyncError ->
            errorView "Error syncing"

        None ->
            if model.isSyncing then
                syncing
                    { message = model.incomingMsg
                    , syncPercentage = model.syncPercentage
                    }

            else
                homeInfo
                    { mod = collection.mod
                    , cards = collection.cards
                    }


syncing : { message : String, syncPercentage : Int } -> Html Msg
syncing { message, syncPercentage } =
    div
        []
        [ div
            []
            [ text <| message ++ "..."
            ]
        , div
            [ class "sync-loader" ]
            [ div
                [ class "sync-bar"
                , style "width" <| String.fromInt syncPercentage ++ "%"
                ]
                []
            ]
        , div
            []
            [ text <| String.fromInt syncPercentage ++ "%"
            ]
        ]


homeInfo : { mod : Int, cards : Int } -> Html Msg
homeInfo { mod, cards } =
    div
        []
        [ div
            [ class "mv2" ]
            [ text <| "Last modified: " ++ Time.format Time.utc "Weekday, ordDay Month Year at padHour:padMinute" mod
            ]
        , div
            [ class "mv2" ]
            [ text <| "Number notes: " ++ String.fromInt cards
            ]
        , button
            [ onClick StartSync
            , class "button-primary"
            ]
            [ text "Sync Database"
            ]
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


navbar : { items : List ( b, String, String ), selected : b } -> Html Msg
navbar { items, selected } =
    div
        [ class "nav" ]
    <|
        List.map
            (\( identifier, content, link ) ->
                a
                    [ class "nav-item"
                    , classList [ ( "selected", identifier == selected ) ]
                    , href link
                    ]
                    [ text content
                    ]
            )
            items
