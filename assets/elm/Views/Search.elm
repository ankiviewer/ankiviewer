module Views.Search exposing (searchView)

import Html exposing (Html, text, div, button, input)
import Html.Attributes exposing (style, class, classList)
import Html.Events exposing (onClick, onInput)
import Types exposing (Model, Msg(..))
import List.Extra as List
import Views.Nav exposing (nav)


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
            [ classList [ ( "dn", not model.showingManageNoteColumns ) ] ]
            [ div
                []
                [ text "Deck:"
                , div
                    []
                    (List.map
                        (\{ name, did } ->
                            div
                                [ class "pointer"
                                , classList [ ( "red", name == model.deck ) ]
                                , onClick <| ToggleDeck name
                                ]
                                [ text name ]
                        )
                        model.collection.decks
                    )
                ]
            , div
                []
                [ text "Model:"
                , div
                    []
                    (model.collection.models
                        |> List.filter
                            (\collectionModels ->
                                case List.find (\{ name } -> name == model.deck) model.collection.decks of
                                    Just { did } ->
                                        collectionModels.did == did

                                    Nothing ->
                                        True
                            )
                        |> List.map
                            (\{ name } ->
                                div
                                    [ class "pointer"
                                    , classList [ ( "red", name == model.model ) ]
                                    , onClick <| ToggleModel name
                                    ]
                                    [ text name ]
                            )
                    )
                ]
            , div
                [ class "justify-around flex" ]
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
            ]
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
