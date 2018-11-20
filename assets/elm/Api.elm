module Api exposing
    ( createRule
    , deleteRule
    , getCards
    , getCollection
    , getRules
    , updateRule
    )

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import Types exposing (Card, CardSearchParams, Collection, D, M, Msg(..), RequestMsg(..), Rule, RuleResponse)
import Url.Builder as Url


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


getRules : Cmd Msg
getRules =
    Http.send (NewRules >> Request) (Http.get "/api/rules" rulesDecoder)


createRule : Rule -> Cmd Msg
createRule rule =
    Http.send (NewRuleResponse >> Request) (Http.post "/api/rules" (Http.jsonBody (ruleEncoder rule)) ruleResponseDecoder)


updateRule : Rule -> Cmd Msg
updateRule rule =
    Http.send (NewRuleResponse >> Request) (put ("/api/rules/" ++ String.fromInt rule.rid) (Http.jsonBody (ruleEncoder rule)) ruleResponseDecoder)


deleteRule : Int -> Cmd Msg
deleteRule rid =
    Http.send (NewRules >> Request) (delete ("/api/rules/" ++ String.fromInt rid) rulesDecoder)


ruleEncoder : Rule -> Encode.Value
ruleEncoder rule =
    Encode.object
        [ ( "name", Encode.string rule.name )
        , ( "code", Encode.string rule.code )
        , ( "tests", Encode.string rule.tests )
        ]


rulesDecoder : Decoder (List Rule)
rulesDecoder =
    Decode.field "rules" (Decode.list ruleDecoder)


ruleDecoder : Decoder Rule
ruleDecoder =
    Decode.succeed Rule
        |> required "name" Decode.string
        |> required "code" Decode.string
        |> required "tests" Decode.string
        |> required "rid" Decode.int


ruleErrDecoder : Decoder Rule
ruleErrDecoder =
    Decode.succeed Rule
        |> optional "name" Decode.string ""
        |> optional "code" Decode.string ""
        |> optional "tests" Decode.string ""
        |> hardcoded 0


ruleResponseDecoder : Decoder RuleResponse
ruleResponseDecoder =
    Decode.field "err" Decode.bool
        |> Decode.andThen
            (\err ->
                if err then
                    Decode.succeed RuleResponse
                        |> hardcoded err
                        |> hardcoded []
                        |> required "params" ruleErrDecoder

                else
                    Decode.succeed RuleResponse
                        |> hardcoded err
                        |> required "params" (Decode.list ruleDecoder)
                        |> hardcoded (Rule "" "" "" 0)
            )


getCollection : Cmd Msg
getCollection =
    Http.send (NewCollection >> Request) (Http.get "/api/collection" collectionDecoder)


getCards : CardSearchParams -> Cmd Msg
getCards { search } =
    let
        url =
            Url.absolute
                [ "api", "cards" ]
                [ Url.string "search" search
                , Url.string "model" ""
                , Url.string "deck" ""
                , Url.string "tags" ""
                , Url.string "modelorder" ""
                , Url.string "rule" ""
                ]
    in
    Http.send (NewCards >> Request) (Http.get url (Decode.list cardsDecoder))


cardsDecoder : Decoder Card
cardsDecoder =
    Decode.succeed Card
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
