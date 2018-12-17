port module Collection exposing
    ( Collection
    , collectionDecoder
    , encoder
    , setCollection
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


port setCollection : Encode.Value -> Cmd msg


encoder : Collection -> Encode.Value
encoder collection =
    Encode.object
        [ ( "mod", Encode.int collection.mod )
        , ( "cards", Encode.int collection.cards )
        , ( "models", modelsEncoder collection.models )
        , ( "decks", decksEncoder collection.decks )
        ]


modelsEncoder : List M -> Encode.Value
modelsEncoder ms =
    Encode.list
        (\m ->
            Encode.object
                [ ( "name", Encode.string m.name )
                , ( "mid", Encode.int m.mid )
                , ( "flds", Encode.list Encode.string m.flds )
                , ( "did", Encode.int m.did )
                ]
        )
        ms


decksEncoder : List D -> Encode.Value
decksEncoder ds =
    Encode.list
        (\d ->
            Encode.object
                [ ( "name", Encode.string d.name )
                , ( "did", Encode.int d.did )
                ]
        )
        ds


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


type alias Collection =
    { mod : Int
    , cards : Int
    , models : List M
    , decks : List D
    }


type alias M =
    { name : String
    , mid : Int
    , flds : List String
    , did : Int
    }


type alias D =
    { name : String
    , did : Int
    }
