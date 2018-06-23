module Main exposing (main)

import Html
import State
import View
import Types exposing (Model, Msg)


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , subscriptions = State.subscriptions
        , update = State.update
        , view = View.rootView
        }
