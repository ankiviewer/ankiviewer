port module Home exposing
    ( Model
    , Msg
    , init
    , initialModel
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import Process
import Session exposing (Session)
import Task
import Time
import Time.Format as Time


port startSync : Encode.Value -> Cmd msg


port syncData : (Encode.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    syncData SyncIncomingMsg


syncDataDecoder : Decoder SyncData
syncDataDecoder =
    Decode.map2 SyncData
        (Decode.field "msg" Decode.string)
        (Decode.field "percentage" Decode.int)


type alias SyncData =
    { message : String
    , percentage : Int
    }


type alias Model =
    { session : Session
    , collection : Collection
    , syncState : SyncState
    }


type SyncState
    = Syncing ( String, Int )
    | NotSyncing


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


type Msg
    = StartSync
    | StopSync
    | SyncIncomingMsg Encode.Value
    | NewCollection (Result Http.Error Collection)


view : Model -> Html Msg
view { collection, syncState } =
    case syncState of
        Syncing ( message, percentage ) ->
            div
                []
                [ div
                    []
                    [ text <| message ++ "..."
                    ]
                , div
                    [ class "sync-loader"
                    , id "home-sync_loader"
                    ]
                    [ div
                        [ class "sync-bar"
                        , style "width" <| String.fromInt percentage ++ "%"
                        ]
                        []
                    ]
                , div
                    []
                    [ text <| String.fromInt percentage ++ "%"
                    ]
                ]

        NotSyncing ->
            div
                []
                [ div
                    [ class "mv2"
                    , id "home-last_modified"
                    ]
                    [ text <| "Last modified: " ++ Time.format Time.utc "Weekday, ordDay Month Year at padHour:padMinute" collection.mod
                    ]
                , div
                    [ class "mv2"
                    , id "home-number_notes"
                    ]
                    [ text <| "Number notes: " ++ String.fromInt collection.cards
                    ]
                , button
                    [ onClick StartSync
                    , class "button-primary"
                    , id "home-sync_button"
                    ]
                    [ text "Sync Database"
                    ]
                ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartSync ->
            ( model, startSync Encode.null )

        StopSync ->
            ( { model | syncState = NotSyncing }, getCollection )

        SyncIncomingMsg val ->
            case Decode.decodeValue syncDataDecoder val of
                Ok { message, percentage } ->
                    let
                        cmd =
                            if message == "done" then
                                Process.sleep 2000
                                    |> Task.perform (\_ -> StopSync)

                            else
                                Cmd.none
                    in
                    ( { model | syncState = Syncing ( message, percentage ) }
                    , cmd
                    )

                Err e ->
                    let
                        _ =
                            Debug.log "ee" e
                    in
                    ( model, Cmd.none )

        NewCollection (Ok collection) ->
            ( { model | collection = collection }, Cmd.none )

        NewCollection (Err e) ->
            let
                _ =
                    Debug.log "e" e
            in
            ( model, Cmd.none )


initialModel : Session -> Model
initialModel session =
    { session = session
    , collection = Collection 0 0 [] []
    , syncState = NotSyncing
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( initialModel session
    , getCollection
    )


getCollection : Cmd Msg
getCollection =
    Http.get
        { url = "/api/collection"
        , expect = Http.expectJson NewCollection collectionDecoder
        }


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
