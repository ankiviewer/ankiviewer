module View exposing (rootView)

import Html exposing (Html, text, button, div, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, class, classList, id, attribute, disabled)
import Types exposing (Model, Msg(..), Page(Search, Home))
import Date


rootView : Model -> Html Msg
rootView ({ page } as model) =
    case page of
        Home ->
            homeView model

        Search ->
            searchView model


homeView : Model -> Html Msg
homeView ({ syncingDatabase, syncingDatabaseMsg, error, collection } as model) =
    div []
        [ nav model
        , button
            [ onClick SyncDatabase
            , disabled syncingDatabase
            , attribute "data-label" "Sync Database"
            , class "sync-button"
            , classList [ ( "syncing", syncingDatabase ) ]
            , id "load-button"
            ]
            [ text "Sync Database" ]
        , div
            [ classList
                [ ( "dn", (not (syncingDatabase || error)) )
                , ( "red", error )
                ]
            ]
            [ text syncingDatabaseMsg ]
        , div
            []
            [ div [] [ text <| "last modified: " ++ formatDate collection.mod ]
            , div [] [ text <| "number notes: " ++ toString collection.notes ]
            ]
        ]


searchView : Model -> Html Msg
searchView model =
    div []
        [ nav model
        , input [ onInput SearchInput ] []
        , div [ class "flex justify-around" ]
            (List.map
                (\header ->
                    div
                        [ class ""
                        , style
                            [ ( "width", (toString <| 100 / 12) ++ "%" )
                            ]
                        ]
                        [ text header ]
                )
                [ "model", "mod", "ord", "tags", "deck", "ttype", "queue", "due", "reps", "lapses", "front", "back" ]
            )
        , div []
            (List.map
                (\note ->
                    div [ class "flex justify-around" ]
                        (List.map
                            (\row ->
                                div
                                    [ class "overflow-hidden"
                                    , style
                                        [ ( "width", (toString <| 100 / 12) ++ "%" )
                                        ]
                                    ]
                                    [ text row ]
                            )
                            [ toString note.model
                            , toString note.mod
                            , toString note.ord
                            , toString note.tags
                            , note.deck
                            , toString note.ttype
                            , toString note.queue
                            , toString note.due
                            , toString note.reps
                            , toString note.lapses
                            , toString note.front
                            , toString note.back
                            ]
                        )
                )
                model.notes
            )
        ]


nav : Model -> Html Msg
nav model =
    div []
        [ button
            [ onClick <| PageChange Home ]
            [ text "Home" ]
        , button
            [ onClick PageChangeToSearch ]
            [ text "Search" ]
        ]


formatDate : Int -> String
formatDate mod =
    let
        date =
            mod
                * 1000
                |> toFloat
                |> Date.fromTime

        ( dayOfWeek, day, month, hour, minute ) =
            ( Date.dayOfWeek date |> toString
            , Date.day date |> toString
            , Date.month date |> toString
            , Date.hour date |> toString
            , Date.minute date |> toString
            )
    in
        dayOfWeek ++ " " ++ day ++ " " ++ month ++ " " ++ hour ++ ":" ++ minute
