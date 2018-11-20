module View exposing (body, errorView, homeInfo, homePage, navbar, notFoundPage, pageToString, rulesPage, searchPage, syncing, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, input, label, text, textarea)
import Html.Attributes exposing (class, classList, href, style, value)
import Html.Events exposing (onClick, onInput)
import Set
import Time
import Time.Format as Time
import Types exposing (ErrorType(..), Model, Msg(..), Page(..), RuleInputType(..))
import Url
import Url.Builder


cardColumns : List String
cardColumns =
    [ "model", "mod", "ord", "tags", "deck", "type", "queue", "due", "reps", "lapses", "front", "back" ]


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
    if model.showColumns then
        div
            []
            [ div
                []
                [ text "Green is showing, red is not showing, click to toggle"
                ]
            , div
                []
                (List.map
                    (\col ->
                        div
                            [ class "dib ma1 pointer"
                            , classList
                                [ ( "red", Set.member col model.excludedColumns )
                                , ( "green", not (Set.member col model.excludedColumns) )
                                ]
                            , onClick <| ToggleColumn col
                            ]
                            [ text col ]
                    )
                    cardColumns
                )
            , div
                []
                [ button
                    [ onClick ToggleShowColumns
                    ]
                    [ text "Done"
                    ]
                ]
            ]

    else
        div
            []
            [ div
                []
                [ input
                    [ onInput SearchInput ]
                    []
                ]
            , if model.search == "" then
                div
                    []
                    [ button
                        [ onClick ToggleShowColumns
                        ]
                        [ text "Edit columns"
                        ]
                    ]

              else
                div
                    []
                    [ div
                        []
                        (let
                            columns =
                                cardColumns
                                    |> List.filter
                                        (\col ->
                                            not (Set.member col model.excludedColumns)
                                        )
                         in
                         List.map
                            (\col ->
                                div
                                    [ class "dib ma1"
                                    , style "width" <| String.fromInt (100 // List.length columns) ++ "%"
                                    ]
                                    [ text col
                                    ]
                            )
                            columns
                        )
                    , div
                        []
                        (List.map
                            (\card ->
                                cardColumns
                                    |> List.foldr
                                        (\cur acc ->
                                            if not (Set.member cur model.excludedColumns) then
                                                case cur of
                                                    "model" ->
                                                        card.model :: acc

                                                    "mod" ->
                                                        String.fromInt card.mod :: acc

                                                    "ord" ->
                                                        String.fromInt card.ord :: acc

                                                    "tags" ->
                                                        String.join ", " card.tags :: acc

                                                    "deck" ->
                                                        card.deck :: acc

                                                    "type" ->
                                                        String.fromInt card.ttype :: acc

                                                    "queue" ->
                                                        String.fromInt card.queue :: acc

                                                    "due" ->
                                                        String.fromInt card.due :: acc

                                                    "reps" ->
                                                        String.fromInt card.reps :: acc

                                                    "lapses" ->
                                                        String.fromInt card.lapses :: acc

                                                    "front" ->
                                                        card.front :: acc

                                                    "back" ->
                                                        card.back :: acc

                                                    _ ->
                                                        let
                                                            _ =
                                                                Debug.log "UNKNOWN" cur
                                                        in
                                                        acc

                                            else
                                                acc
                                        )
                                        []
                            )
                            model.cards
                            |> List.map
                                (\cards ->
                                    div
                                        [ class "ma1" ]
                                        (List.map
                                            (\card ->
                                                div
                                                    [ class "ma1 dib overflow-hidden"
                                                    , style "width" <| String.fromInt (100 // List.length cards) ++ "%"
                                                    ]
                                                    [ text card
                                                    ]
                                            )
                                            cards
                                        )
                                )
                        )
                    ]
            ]


rulesPage : Model -> Html Msg
rulesPage model =
    div
        [ class "flex items-top" ]
        [ div
            [ class "w-80 dib" ]
            [ div
                []
                [ div
                    [ class "ma4 flex items-center" ]
                    [ label
                        [ class "dib w-20"
                        ]
                        [ text "Name:"
                        ]
                    , input
                        [ class "h2 w-70 border-box ba b--gray"
                        , onInput (RuleName >> RuleInput)
                        , value model.ruleInput.name
                        ]
                        []
                    ]
                , case model.ruleErr of
                    Nothing ->
                        text ""

                    Just err ->
                        div
                            [ class "red" ]
                            [ text err.name
                            ]
                ]
            , div
                []
                [ div
                    [ class "ma4 flex items-center" ]
                    [ label
                        [ class "dib w-20"
                        ]
                        [ text "Code:"
                        ]
                    , textarea
                        [ class "h4 w-70 border-box ba b--gray"
                        , onInput (RuleCode >> RuleInput)
                        , value model.ruleInput.code
                        ]
                        []
                    ]
                , case model.ruleErr of
                    Nothing ->
                        text ""

                    Just err ->
                        div
                            [ class "red" ]
                            [ text err.code
                            ]
                ]
            , div
                []
                [ div
                    [ class "ma4 flex items-center" ]
                    [ label
                        [ class "dib w-20"
                        ]
                        [ text "Tests:"
                        ]
                    , textarea
                        [ class "h4 w-70 ba b--gray"
                        , onInput (RuleTests >> RuleInput)
                        , value model.ruleInput.tests
                        ]
                        []
                    ]
                , case model.ruleErr of
                    Nothing ->
                        text ""

                    Just err ->
                        div
                            [ class "red" ]
                            [ text err.tests
                            ]
                ]
            , case model.selectedRule of
                Nothing ->
                    div
                        []
                        [ button
                            [ onClick CreateRule
                            ]
                            [ text "Add New" ]
                        ]

                Just ruleId ->
                    div
                        []
                        [ button
                            [ onClick UpdateRule
                            ]
                            [ text "Update Rule"
                            ]
                        , button
                            [ onClick <| DeleteRule ruleId
                            ]
                            [ text "Delete Rule"
                            ]
                        , button
                            [ onClick <| RunRule ruleId ]
                            [ text "Run Rule"
                            ]
                        ]
            ]
        , div
            [ class "w-20 dib mv4 mr2" ]
            (List.map
                (\rule ->
                    div
                        [ classList
                            [ ( "bg-primary", (model.selectedRule |> Maybe.withDefault 0) == rule.rid )
                            ]
                        , class "pa1 pointer"
                        , onClick <| ToggleRule rule.rid
                        ]
                        [ text rule.name
                        ]
                )
                model.rules
            )
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
