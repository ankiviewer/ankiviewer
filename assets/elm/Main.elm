module Main exposing (main)

import Browser
import State
import Types exposing (Msg(..))
import View


main =
    Browser.application
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
