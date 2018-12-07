module Skeleton exposing (view)

import Browser
import Html exposing (Html)


type alias Details a msg =
    { title : String
    , view : Html a
    , nav : Html msg
    }


view : (a -> msg) -> Details a msg -> Browser.Document msg
view toMsg details =
    { title = details.title
    , body =
        [ details.nav
        , Html.map toMsg details.view
        ]
    }
