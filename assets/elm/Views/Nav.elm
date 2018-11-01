module Views.Nav exposing (nav)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Types exposing (Model, Msg(..), Views(..))


nav : Model -> Html Msg
nav model =
    div []
        (List.map
            (\( viewText, view ) ->
                button
                    [ onClick <| ViewChange view ]
                    [ text viewText ]
            )
            [ ( "Home", HomeView )
            , ( "Search", SearchView )
            , ( "Rule", RuleView )
            ]
        )
