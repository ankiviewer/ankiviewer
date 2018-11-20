module Network.Http.Extra exposing (delete, put)

import Http
import Json.Decode as Decode exposing (Decoder)


put : String -> Http.Body -> Decoder a -> Http.Request a
put url body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


delete : String -> Decoder a -> Http.Request a
delete url decoder =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
