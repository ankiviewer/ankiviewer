module View exposing (rootView)

import Html exposing (Html, button, div, input, text)
import Types
    exposing
        ( Model
        , Msg
        , Views(..)
        )
import Views.Home exposing (homeView)
import Views.Rule exposing (ruleView)
import Views.Search exposing (searchView)


rootView : Model -> Html Msg
rootView ({ view } as model) =
    case view of
        HomeView ->
            homeView model

        SearchView ->
            searchView model

        RuleView ->
            ruleView model
