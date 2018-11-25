module View exposing (navbar, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, input, label, text, textarea)
import Html.Attributes exposing (class, classList, href, id, style, value)
import Html.Events exposing (onClick, onInput)
import Set
import Types
    exposing
        ( ErrorType(..)
        , Model
        , Msg(..)
        , Page(..)
        , RequestMsg(..)
        , Rule
        , RuleInputType(..)
        )
import View.Home


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
            View.Home.view model

        Search ->
            searchPage model

        Rules ->
            rulesPage model

        NotFound ->
            notFoundPage model
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
                [ id "search-columns_container"
                ]
                (List.map
                    (\col ->
                        div
                            [ class "dib ma1 pointer red"
                            , classList
                                [ ( "green", not (Set.member col model.excludedColumns) )
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
                    , id "search-done"
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
                    [ onInput SearchInput
                    , id "search-input"
                    ]
                    []
                ]
            , if model.search == "" then
                div
                    []
                    [ button
                        [ onClick ToggleShowColumns
                        , id "search-edit_columns"
                        ]
                        [ text "Edit columns"
                        ]
                    ]

              else
                div
                    []
                    [ div
                        [ id "search-column_headers" ]
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
                        [ id "search-result-rows" ]
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


ruleInputItem : Model -> (Rule -> String) -> String -> (List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg) -> RuleInputType -> String -> String -> Html Msg
ruleInputItem model ruleKey labelText inputType ruleInputType heightClass inputId =
    div
        []
        [ div
            [ class "ma4 flex items-center" ]
            [ label
                [ class "dib w-20"
                ]
                [ text labelText
                ]
            , inputType
                [ class <| heightClass ++ " w-70 border-box ba b--gray"
                , onInput (RuleInput ruleInputType)
                , value (ruleKey model.ruleInput)
                , id inputId
                ]
                []
            ]
        , case Maybe.withDefault "" (Maybe.map ruleKey model.ruleErr) of
            "" ->
                text ""

            e ->
                div
                    [ class "red" ]
                    [ text e
                    ]
        ]


rulesPage : Model -> Html Msg
rulesPage model =
    div
        [ class "flex items-top" ]
        [ div
            [ class "w-80 dib" ]
            [ ruleInputItem model .name "Name:" input RuleName "h2" "rules-input_name"
            , ruleInputItem model .code "Code:" textarea RuleCode "h4" "rules-input_code"
            , ruleInputItem model .tests "Tests:" textarea RuleTests "h4" "rules-input_tests"
            , case model.selectedRule of
                Nothing ->
                    div
                        []
                        [ button
                            [ onClick <| Request CreateRule
                            , id "rules-add_new"
                            ]
                            [ text "Add New"
                            ]
                        ]

                Just ruleId ->
                    div
                        []
                        [ button
                            [ onClick <| Request UpdateRule
                            , id "rules-update_rule"
                            ]
                            [ text "Update Rule"
                            ]
                        , button
                            [ onClick <| Request (DeleteRule ruleId)
                            , id "rules-delete_rule"
                            ]
                            [ text "Delete Rule"
                            ]
                        , button
                            [ onClick <| RunRule ruleId
                            , id "rules-run_rule"
                            ]
                            [ text "Run Rule"
                            ]
                        ]
            ]
        , div
            [ class "w-20 dib mv4 mr2"
            , id "rules-rules_container"
            ]
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
        (List.map
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
        )
