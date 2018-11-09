module View exposing (view)

import Html exposing (Html, text, div)
import Types exposing (Model, Msg)
import Time exposing (utc)
import Time.Format as Time


view : Model -> Html Msg
view {collection} =
    div
        []
        [ text <| Time.format utc "Weekday, ordDay Month Year at padHour:padMinute" collection.mod
        ]
