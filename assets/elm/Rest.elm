module Rest exposing (getNotes, getCollection, syncDatabaseMsgDecoder)

import Types
    exposing
        ( Msg(Request)
        , RequestMsg(NewNotes, NewCollection)
        , Collection
        , Model
        , Note
        , ReceivedSyncMsg
        )
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Http
import HttpBuilder


syncDatabaseMsgDecoder : Decoder ReceivedSyncMsg
syncDatabaseMsgDecoder =
    required "msg" Decode.string <| decode ReceivedSyncMsg


getCollection : Cmd Msg
getCollection =
    Http.get "/api/collection" collectionDecoder
        |> Http.send (NewCollection >> Request)


getNotes : Model -> Cmd Msg
getNotes model =
    HttpBuilder.get "/api/notes"
        |> HttpBuilder.withQueryParams
            [ ( "search", model.search )
            , ( "model", model.model )
            , ( "deck", model.deck )
            , ( "tags", String.join "," model.tags )
            , ( "modelorder", model.order |> List.map toString |> String.join "," )
            , ( "rule", toString model.rule )
            ]
        |> HttpBuilder.withExpect (Http.expectJson notesDecoder)
        |> HttpBuilder.send (NewNotes >> Request)


collectionDecoder : Decoder Collection
collectionDecoder =
    decode Collection
        |> required "mod" Decode.int
        |> required "notes" Decode.int


notesDecoder : Decoder (List Note)
notesDecoder =
    Decode.list
        (decode Note
            |> required "model" Decode.string
            |> required "mod" Decode.int
            |> required "ord" Decode.int
            |> required "tags" (Decode.list Decode.string)
            |> required "deck" Decode.string
            |> required "ttype" Decode.int
            |> required "queue" Decode.int
            |> required "due" Decode.int
            |> required "reps" Decode.int
            |> required "lapses" Decode.int
            |> required "front" Decode.string
            |> required "back" Decode.string
        )
