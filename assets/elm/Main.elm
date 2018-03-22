module Main exposing (..)

import Html exposing (Html, program, text, div, button)
import Html.Events exposing (onClick)


main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = NoOp


type alias Model =
    { txt : String }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { txt = "hello world" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick NoOp ] [ text "Load Database" ]
        ]
