module Router exposing (router, update)

import Types exposing (Model, Views(HomeView, SearchView), Msg(ViewChange), Url)
import Ports exposing (urlOut)
import Rest


router : String -> Views
router viewString =
    case viewString of
        "/" ->
            HomeView

        "/search" ->
            SearchView

        _ ->
            HomeView


update : Views -> Model -> ( Model, Cmd Msg )
update viewMsg model =
    case viewMsg of
        SearchView ->
            { model | view = SearchView }
                ! [ Rest.getNotes model, toString SearchView |> Url |> urlOut ]

        view ->
            { model | view = view } ! [ toString view |> Url |> urlOut ]
