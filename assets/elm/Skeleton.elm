module Skeleton exposing (view)

import Browser
import Html exposing (Html)


type alias Details msg =
    { title : String
    , view : Html msg
    }


view : (a -> msg) -> Html msg -> Details a -> Browser.Document msg
view toMsg nav details =
  { title = details.title
  , body =
      [ nav
      , Html.map toMsg details.view
      ]
  }
