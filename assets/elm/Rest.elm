module Rest exposing (getNotes, getCollection, syncDatabaseMsgDecoder)

import Types exposing (Model, Note, Collection, SyncMsg, Msg(NewNotes, NewCollection))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Http


syncDatabaseMsgDecoder : Decoder SyncMsg
syncDatabaseMsgDecoder =
    required "msg" Decode.string <| decode SyncMsg


getCollection : Cmd Msg
getCollection =
    Http.send NewCollection <| Http.get "/api/collection" collectionDecoder


getNotes : Model -> Cmd Msg
getNotes model =
    let
        params =
            [ ( "search", model.search )
            , ( "model", model.model )
            , ( "deck", model.deck )
            , ( "tags", String.join "," model.tags )
            , ( "modelorder", model.order |> List.map toString |> String.join "," )
            , ( "rule", toString model.rule )
            ]
    in
        Http.send NewNotes <| Http.get ("/api/notes?" ++ (parseNoteParams params)) notesDecoder


parseNoteParams : List ( String, String ) -> String
parseNoteParams params =
    params
        |> List.map (\( k, v ) -> k ++ "=" ++ v)
        |> String.join "&"


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
