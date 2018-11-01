module Views.Home exposing (homeView)

import Date
import Date.Extra as Date
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (attribute, class, classList, disabled, id)
import Html.Events exposing (onClick)
import Types exposing (Model, Msg(..), SyncMsg(..), WebsocketMsg(..))
import Views.Nav exposing (nav)


homeView : Model -> Html Msg
homeView ({ syncingDatabase, syncingDatabaseMsg, syncingError, collection } as model) =
    div []
        [ nav model
        , button
            [ onClick <| Websocket (Sync Start)
            , disabled syncingDatabase
            , attribute "data-label" "Sync Database"
            , class "sync-button"
            , classList [ ( "syncing", syncingDatabase ) ]
            , id "load-button"
            ]
            [ text "Sync Database" ]
        , div
            [ classList
                [ ( "dn", not (syncingDatabase || syncingError) )
                , ( "red", syncingError )
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
            , div [] [ text <| "number cards: " ++ toString collection.cards ]
            ]
        ]
