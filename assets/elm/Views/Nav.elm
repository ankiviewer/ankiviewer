module Views.Nav exposing (nav)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Types exposing (Model, Views(..), Msg(ViewChange))


nav : Model -> Html Msg
nav model =
    div []
        (List.map
            (\( viewText, view ) ->
                button
                    [ onClick <| ViewChange view ]
                    [ text viewText ]
            )
            ([ ( "Home", HomeView )
             , ( "Search", SearchView )
             , ( "Rule", RuleView )
             ]
            )
        )
