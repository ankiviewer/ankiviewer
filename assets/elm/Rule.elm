module Rule exposing (update)

import Types exposing (Model, Msg, Rules(..))
import Rest


update : Rules -> Model -> ( Model, Cmd Msg )
update rules ({ newRule } as model) =
    case rules of
        Add ->
            model ! [ Rest.createRule model ]

        InputCode code ->
            { model | newRule = { newRule | code = code } } ! []

        InputName name ->
            { model | newRule = { newRule | name = name } } ! []

        InputTests tests ->
            { model | newRule = { newRule | tests = tests } } ! []
