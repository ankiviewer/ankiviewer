module View exposing (rootView)

import Html exposing (Html, text, button, div, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, class, classList, id, attribute, disabled)
import Types
    exposing
        ( Model
        , Msg(ViewChange, Sync, SearchInput)
        , Views(HomeView, SearchView)
        , SyncingMsg(Start)
        )
import Date
import Date.Extra as Date


rootView : Model -> Html Msg
rootView ({ view } as model) =
    case view of
        HomeView ->
            homeView model

        SearchView ->
            searchView model


homeView : Model -> Html Msg
homeView ({ syncingDatabase, syncingDatabaseMsg, error, collection } as model) =
    div []
        [ nav model
        , button
            [ onClick <| Sync Start
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
            [ div
                []
                [ collection.mod
                    * 1000
                    |> toFloat
                    |> Date.fromTime
                    |> Date.toFormattedString "'last modified: 'EEEE, MMMM d, y 'at' h:mm a"
                    |> text
                ]
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
            [ onClick <| ViewChange HomeView ]
            [ text "Home" ]
        , button
            [ onClick <| ViewChange SearchView ]
            [ text "Search" ]
        ]
