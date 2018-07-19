port module Ports exposing (urlIn, urlOut, setColumns)

import Types exposing (Url)


port urlIn : (Url -> msg) -> Sub msg


port urlOut : Url -> Cmd msg


port setColumns : List Bool -> Cmd msg
