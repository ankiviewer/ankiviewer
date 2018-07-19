module Views.Home exposing (homeView)

import Html exposing (Html, text, div, button)
import Html.Attributes exposing (classList, id, class, attribute, disabled)
import Html.Events exposing (onClick)
import Types exposing (Msg(Websocket), WebsocketMsg(Sync), SyncMsg(Start), Model)
import Date
import Date.Extra as Date
import Views.Nav exposing (nav)


homeView : Model -> Html Msg
homeView ({ syncingDatabase, syncingDatabaseMsg, error, collection } as model) =
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
