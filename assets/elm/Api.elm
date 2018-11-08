module Api exposing (..)

import Types exposing (Collection, D, M, Msg(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Http

getCollection : Cmd Msg
getCollection =
    Http.send NewCollection (Http.get "/api/collection" collectionDecoder)


collectionDecoder : Decoder Collection
collectionDecoder =
    Decode.succeed Collection
        |> required "mod" Decode.int
        |> required "cards" Decode.int
        |> required "models" modelsDecoder
        |> required "decks" decksDecoder


decksDecoder : Decoder (List D)
decksDecoder =
    Decode.list
        (Decode.succeed D
            |> required "name" Decode.string
            |> required "did" Decode.int
        )


modelsDecoder : Decoder (List M)
modelsDecoder =
    Decode.list
        (Decode.succeed M
            |> required "name" Decode.string
            |> required "mid" Decode.int
            |> required "flds" (Decode.list Decode.string)
            |> required "did" Decode.int
        )
