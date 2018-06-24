module View exposing (rootView)

import Html exposing (Html, text, button, div, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, class, classList, id, attribute, disabled)
import Types
    exposing
        ( Model
        , Msg(ViewChange, Sync, SearchInput, ToggleNoteColumn, ToggleManageNotes)
        , Views(HomeView, SearchView)
        , SyncingMsg(Start)
        )
import Date
import Date.Extra as Date
import List.Extra as List


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


noteColumns : List String
noteColumns =
    [ "model", "mod", "ord", "tags", "deck", "type", "queue", "due", "reps", "lapses", "front", "back" ]


searchView : Model -> Html Msg
searchView model =
    div []
        [ nav model
        , input [ onInput SearchInput ] []
        , button
            [ onClick ToggleManageNotes ]
            [ text "Manage Notes" ]
        , div
            [ class "justify-around"
            , classList
                [ ( "dn", not model.showingManageNoteColumns )
                , ( "flex", model.showingManageNoteColumns )
                ]
            ]
            (noteColumns
                |> List.zip model.noteColumns
                |> List.indexedMap (\i ( selected, val ) -> ( i, selected, val ))
                |> List.map
                    (\( i, selected, header ) ->
                        div
                            [ class "pointer"
                            , classList
                                [ ( "red", not selected )
                                , ( "green", selected )
                                ]
                            , style
                                [ ( "width", (toString (100 / 12)) ++ "%" )
                                ]
                            , onClick <| ToggleNoteColumn i
                            ]
                            [ text header ]
                    )
            )
        , div [ class "flex justify-around" ]
            (noteColumns
                |> List.zip model.noteColumns
                |> List.filter (\( selected, _ ) -> selected)
                |> List.map
                    (\( _, header ) ->
                        div
                            [ class ""
                            , style
                                [ ( "width", (toString (100 / 12)) ++ "%" )
                                ]
                            ]
                            [ text header ]
                    )
            )
        , div []
            (List.map
                (\note ->
                    div [ class "flex justify-around" ]
                        ([ note.model
                         , toString note.mod
                         , toString note.ord
                         , toString note.tags
                         , note.deck
                         , toString note.ttype
                         , toString note.queue
                         , toString note.due
                         , toString note.reps
                         , toString note.lapses
                         , note.front
                         , note.back
                         ]
                            |> List.zip model.noteColumns
                            |> List.filter (\( selected, _ ) -> selected)
                            |> List.map
                                (\( _, row ) ->
                                    div
                                        [ class "overflow-hidden"
                                        , style
                                            [ ( "width", (toString <| 100 / 12) ++ "%" )
                                            ]
                                        ]
                                        [ text row ]
                                )
                        )
                )
                model.notes
            )
        ]


nav : Model -> Html Msg
nav model =
    div []
        (List.map
            (\( viewText, view ) ->
                button
                    [ onClick <| ViewChange view ]
                    [ text viewText ]
            )
            ([ ( "Home", HomeView )
             , ( "Search", SearchView )
             ]
            )
        )
