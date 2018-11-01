module Main exposing (main)

import Html
import State
import Types exposing (Flags, Model, Msg)
import View


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = State.init
        , subscriptions = State.subscriptions
        , update = State.update
        , view = View.rootView
        }
