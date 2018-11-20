module Main exposing (main)

import Browser
import State
import Types exposing (Flags, Model, Msg(..))
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
