module View exposing (rootView)

import Html exposing (Html, text, button, div, input)
import Types
    exposing
        ( Model
        , Msg
        , Views(HomeView, SearchView)
        )
import Views.Search exposing (searchView)
import Views.Home exposing (homeView)


rootView : Model -> Html Msg
rootView ({ view } as model) =
    case view of
        HomeView ->
            homeView model

        SearchView ->
            searchView model
