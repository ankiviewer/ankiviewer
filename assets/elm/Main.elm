module Main exposing (main)

import Html
import State
import View
import Types exposing (Model, Msg, Flags)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = State.init
        , subscriptions = State.subscriptions
        , update = State.update
        , view = View.rootView
        }
