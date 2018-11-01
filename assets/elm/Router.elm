module Router exposing (router, update)

import Ports exposing (urlOut)
import Rest
import Types exposing (Model, Msg(..), Url, Views(..))


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
    ( { model | view = view }
    , toString view |> Url |> urlOut
    )
