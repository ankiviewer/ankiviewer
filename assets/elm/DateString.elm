module DateString exposing (format)

import Time exposing (toMonth, utc, millisToPosix, Month(..))
import List.Extra as List

months : List Month
months =
    [ Jan
    , Feb
    , Mar
    , Apr
    , May
    , Jun
    , Jul
    , Aug
    , Sep
    , Oct
    , Nov
    , Dec
    ]

addOne : Int -> Int
addOne n =
    n + 1

millisToMonth : Int -> Month
millisToMonth millis =
    toMonth utc (millisToPosix millis)

format : String -> Int -> String
format formatString millis =
    List.elemIndex (millisToMonth millis) months
    |> Maybe.withDefault 0
    |> addOne
    |> String.fromInt

-- format : String -> Int -> String
-- format formatString millis =
--     case toMonth utc (millisToPosix millis) of
--         Jan ->
--             "Jan"
--         Feb ->
--             "Feb"
--         Mar ->
--             "Mar"
--         Apr ->
--             "Apr"
--         May ->
--             "May"
--         Jun ->
--             "Jun"
--         Jul ->
--             "Jul"
--         Aug ->
--             "Aug"
--         Sep ->
--             "Sep"
--         Oct ->
--             "Oct"
--         Nov ->
--             "Nov"
--         Dec ->
--             "Dec"
