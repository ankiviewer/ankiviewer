module Rest
    exposing
        ( getNotes
        , getCollection
        , syncDatabaseMsgDecoder
        , getRules
        , createRule
        , updateRule
        , deleteRule
        )

import Types
    exposing
        ( Msg(Request)
        , RequestMsg(NewNotes, NewCollection, NewRules, NewRuleResponse)
        , Collection
        , Model
        , M
        , D
        , Note
        , ReceivedSyncMsg
        , Rule
        , RuleResponse
        , ErrRuleResponse
        )
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Json.Encode as Encode exposing (Value)
import Http
import HttpBuilder exposing (RequestBuilder)


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
        |> required "models" modelsDecoder
        |> required "decks" decksDecoder


decksDecoder : Decoder (List D)
decksDecoder =
    Decode.list
        (decode D
            |> required "name" Decode.string
            |> required "did" Decode.int
        )


modelsDecoder : Decoder (List M)
modelsDecoder =
    Decode.list
        (decode M
            |> required "name" Decode.string
            |> required "mid" Decode.int
            |> required "flds" (Decode.list Decode.string)
            |> required "did" Decode.int
        )


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


getRules : Cmd Msg
getRules =
    Http.get "/api/rules" (ruleRequestDecoder)
        |> Http.send (NewRules >> Request)


type alias RulesResponse =
    { rules : List Rule
    }


ruleRequestDecoder : Decoder (List Rule)
ruleRequestDecoder =
    decode RulesResponse
        |> required "rules" rulesDecoder
        |> Decode.map .rules


rulesDecoder : Decoder (List Rule)
rulesDecoder =
    Decode.list ruleDecoder


ruleDecoder : Decoder Rule
ruleDecoder =
    decode Rule
        |> required "code" Decode.string
        |> required "tests" Decode.string
        |> required "name" Decode.string
        |> required "rid" Decode.int


errRuleResponseDecoder : Decoder ErrRuleResponse
errRuleResponseDecoder =
    decode ErrRuleResponse
        |> optional "code" Decode.string ""
        |> optional "tests" Decode.string ""
        |> optional "name" Decode.string ""


ruleResponseDecoder : Model -> Decoder RuleResponse
ruleResponseDecoder model =
    Decode.field "err" Decode.bool
        |> Decode.andThen
            (\err ->
                if err then
                    decode RuleResponse
                        |> hardcoded err
                        |> hardcoded []
                        |> required "params" errRuleResponseDecoder
                else
                    decode RuleResponse
                        |> hardcoded err
                        |> required "params" (rulesDecoder)
                        |> hardcoded (ErrRuleResponse "" "" "")
            )


ruleEncoder : Rule -> Value
ruleEncoder rule =
    Encode.object
        [ ( "name", Encode.string rule.name )
        , ( "code", Encode.string rule.code )
        , ( "tests", Encode.string rule.tests )
        ]


createRule : Model -> Cmd Msg
createRule model =
    HttpBuilder.post "/api/rules"
        |> handleRuleRequest model model.newRule


updateRule : Model -> Cmd Msg
updateRule model =
    HttpBuilder.put ("/api/rules/" ++ toString model.ruleEdit.rid)
        |> handleRuleRequest model model.ruleEdit


handleRuleRequest : Model -> Rule -> RequestBuilder () -> Cmd Msg
handleRuleRequest model rule req =
    req
        |> HttpBuilder.withJsonBody (ruleEncoder rule)
        |> HttpBuilder.withExpect (Http.expectJson (ruleResponseDecoder model))
        |> HttpBuilder.send (NewRuleResponse >> Request)


deleteRule : Int -> Cmd Msg
deleteRule rid =
    HttpBuilder.delete ("/api/rules/" ++ toString rid)
        |> HttpBuilder.withExpect (Http.expectJson ruleRequestDecoder)
        |> HttpBuilder.send (NewRules >> Request)
