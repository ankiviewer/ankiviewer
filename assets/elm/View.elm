module View exposing (rootView)

import Html exposing (Html, text, button, div, input)
import Types
    exposing
        ( Model
        , Msg
        , Views(..)
        )
import Views.Search exposing (searchView)
import Views.Home exposing (homeView)
import Views.Rule exposing (ruleView)


rootView : Model -> Html Msg
rootView ({ view } as model) =
    case view of
        HomeView ->
            homeView model

        SearchView ->
            searchView model

        RuleView ->
            ruleView model
