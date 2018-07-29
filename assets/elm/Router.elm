module Router exposing (router, update)

import Types exposing (Model, Views(..), Msg(ViewChange), Url)
import Ports exposing (urlOut)
import Rest


router : String -> Views
router viewString =
    case viewString of
        "/" ->
            HomeView

        "/search" ->
            SearchView

        "/rules" ->
            RuleView

        _ ->
            HomeView


update : Views -> Model -> ( Model, Cmd Msg )
update view model =
    { model | view = view } ! [ toString view |> Url |> urlOut ]
