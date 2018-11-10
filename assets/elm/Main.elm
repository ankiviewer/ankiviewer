module Main exposing (main)

import Browser
import State
import View


main =
    Browser.element
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        }
