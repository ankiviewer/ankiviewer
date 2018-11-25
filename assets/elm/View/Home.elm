module View.Home exposing (errorView, info, syncing, view)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Time
import Time.Format as Time
import Types exposing (ErrorType(..), Model, Msg(..), SyncMsg(..), SyncState(..))


view : Model -> Html Msg
view ({ collection } as model) =
    case model.homeMsg of
        Err (HttpError err) ->
            errorView <| "Http Error: " ++ err

        Err (SyncError err) ->
            errorView <| "Sync Error: " ++ err

        Ok (Syncing ( message, syncPercentage )) ->
            syncing
                { message = message
                , syncPercentage = syncPercentage
                }

        Ok NotSyncing ->
            info
                { mod = collection.mod
                , cards = collection.cards
                }


errorView : String -> Html Msg
errorView errorText =
    div
        [ class "red" ]
        [ text errorText
        ]


info : { mod : Int, cards : Int } -> Html Msg
info { mod, cards } =
    div
        []
        [ div
            [ class "mv2"
            , id "home-last_modified"
            ]
            [ text <| "Last modified: " ++ Time.format Time.utc "Weekday, ordDay Month Year at padHour:padMinute" mod
            ]
        , div
            [ class "mv2"
            , id "home-number_notes"
            ]
            [ text <| "Number notes: " ++ String.fromInt cards
            ]
        , button
            [ onClick <| Sync StartSync
            , class "button-primary"
            , id "home-sync_button"
            ]
            [ text "Sync Database"
            ]
        ]


syncing : { message : String, syncPercentage : Int } -> Html Msg
syncing { message, syncPercentage } =
    div
        []
        [ div
            []
            [ text <| message ++ "..."
            ]
        , div
            [ class "sync-loader"
            , id "home-sync_loader"
            ]
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
