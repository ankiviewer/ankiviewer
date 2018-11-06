module Main exposing (Flags, Model, Msg(..), init, initialModel, main, update, view)

import Browser
import Html exposing (Html, div, text)


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { syncMsg = ""
    , syncError = False
    , syncPercentage = 0
    , isSyncing = False
    , numberCards = 0
    }


type alias Model =
    { syncMsg : String
    , syncError : Bool
    , syncPercentage : Int
    , isSyncing : Bool
    , numberCards : Int
    }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text "hi" ]
