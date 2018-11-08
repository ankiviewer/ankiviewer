module View exposing (view)

import Html exposing (Html, text, div)
import Types exposing (Model, Msg)
import Time
import DateString


{-|Convert an int to a date string
Examples:
> dateString 1540216129594
"Monday 1st November 2018"
-}
dateString : Int -> String
dateString =
    DateString.format "dddd, Do MMMM YYYY" 


view : Model -> Html Msg
view {collection} =
    div
        []
        [ text <| dateString collection.mod
        ]
