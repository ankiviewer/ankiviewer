module Main exposing (..)

import Html exposing (Html, program, text, div, button, input)
import Html.Attributes exposing (classList, class, attribute, disabled, id)
import Html.Events exposing (onClick, onInput)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode exposing (Value, null)
import Json.Decode exposing (Decoder, string, int, decodeValue, list)
import Json.Decode.Pipeline exposing (decode, required)
import Task
import Process
import Http
import Date


main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = PhxMsg (Socket.Msg Msg)
    | SyncDatabase
    | StopSpinner
    | SyncDatabaseLeave Value
    | SyncDatabaseMsg Value
    | GetCollection
    | NewCollection (Result Http.Error Collection)
    | GetNotes
    | NewNotes (Result Http.Error (List Note))
    | PageChange Page
    | SearchInput String
    | NoOp


type alias Model =
    { phxSocket : Socket Msg
    , search : String
    , model : String
    , deck : String
    , tags : List String
    , order : List Int
    , rule : Int
    , collection : Collection
    , notes : List Note
    , error : Bool
    , syncingDatabase : Bool
    , syncingDatabaseMsg : String
    , page : Page
    }


type Page
    = Home
    | Search


initialModel : Model
initialModel =
    { phxSocket = initialPhxSocket
    , search = ""
    , model = ""
    , deck = ""
    , tags = []
    , order = []
    , rule = 0
    , collection = { mod = 0, notes = 0 }
    , notes = []
    , error = False
    , syncingDatabase = False
    , syncingDatabaseMsg = ""
    , page = Home
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    ( initialModel, getCollection )


initialPhxSocket : Socket Msg
initialPhxSocket =
    Socket.init socketServer
        |> Socket.on "sync:msg" "sync:database" SyncDatabaseMsg
        |> Socket.on "done" "sync:database" SyncDatabaseLeave


type alias SyncMsg =
    { syncMsg : String
    }


syncDatabaseMsgDecoder : Decoder SyncMsg
syncDatabaseMsgDecoder =
    required "msg" string <| decode SyncMsg


getCollection : Cmd Msg
getCollection =
    Http.send NewCollection <| Http.get "/api/collection" collectionDecoder


getNotes : Model -> Cmd Msg
getNotes model =
    let
        params = [ ( "search", model.search )
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
    |> List.map (\(k, v) -> k ++ "=" ++ v)
    |> String.join "&"


type alias Collection =
    { mod : Int
    , notes : Int
    }

type alias Note =
    { model : String
    , tags : List String
    , deck : String
    , ttype : Int
    , queue : Int
    , due : Int
    , reps : Int
    , lapses : Int
    , front : String
    , back : String
    }


collectionDecoder : Decoder Collection
collectionDecoder =
    decode Collection
        |> required "mod" int
        |> required "notes" int


notesDecoder : Decoder ( List Note )
notesDecoder =
    list noteDecoder

noteDecoder : Decoder Note
noteDecoder =
    decode Note
        |> required "mod" string
        |> required "tags" (list string)
        |> required "deck" string
        |> required "ttype" int
        |> required "queue" int
        |> required "due" int
        |> required "reps" int
        |> required "lapses" int
        |> required "front" string
        |> required "back" string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.update msg model.phxSocket
            in
                { model | phxSocket = phxSocket } ! [ Cmd.map PhxMsg phxCmd ]

        SyncDatabase ->
            let
                channel =
                    Channel.init "sync:database"

                ( phxSocket, phxCmd ) =
                    Socket.join channel initialPhxSocket
            in
                { model | phxSocket = phxSocket, syncingDatabase = True } ! [ Cmd.map PhxMsg phxCmd ]

        SyncDatabaseMsg raw ->
            if model.error then
                model ! []
            else
                case decodeValue syncDatabaseMsgDecoder raw of
                    Ok { syncMsg } ->
                        { model | syncingDatabaseMsg = syncMsg } ! []

                    Err err ->
                        update (SyncDatabaseLeave null) { model | syncingDatabaseMsg = err, error = True }

        StopSpinner ->
            { model | syncingDatabase = False } ! []

        SyncDatabaseLeave _ ->
            let
                ( phxSocket, phxCmd ) =
                    Socket.leave "sync:database" model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhxMsg phxCmd
                      , getCollection
                      , Process.sleep 600 |> Task.perform (always StopSpinner)
                      ]

        NewCollection (Ok collection) ->
            { model | collection = collection } ! []

        NewCollection (Err e) ->
            { model | error = True, syncingDatabaseMsg = toString e } ! []

        GetCollection ->
            model ! [ getCollection ]

        GetNotes ->
            model ! [ getNotes model ]

        NewNotes (Ok notes) ->
            let
                _ = Debug.log "hi" (toString notes)
            in
                model ! []

        NewNotes (Err e) ->
            let
                _ = Debug.log "hi" (toString e)
            in
                model ! []

        SearchInput search ->
            let
                newModel = { model | search = search }
            in
                newModel ! [ getNotes newModel ]


        PageChange page ->
            { model | page = page } ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view ({ page} as model) =
    case page of
        Home ->
            homeView model
        Search ->
            searchView model


homeView : Model -> Html Msg
homeView ({ syncingDatabase, syncingDatabaseMsg, error, collection } as model) =
    div []
        [ nav model
        , button
            [ onClick SyncDatabase
            , disabled syncingDatabase
            , attribute "data-label" "Sync Database"
            , class "sync-button"
            , classList [ ( "syncing", syncingDatabase ) ]
            , id "load-button"
            ]
            [ text "Sync Database" ]
        , div
            [ classList
                [ ( "dn", (not (syncingDatabase || error)) )
                , ( "red", error )
                ]
            ]
            [ text syncingDatabaseMsg ]
        , div
            []
            [ div [] [ text <| "last modified: " ++ formatDate collection.mod ]
            , div [] [ text <| "number notes: " ++ toString collection.notes ]
            ]
        ]


searchView : Model -> Html Msg
searchView model =
    div []
        [ nav model
        , input [ onInput SearchInput ] []
        , div [] [ text "hi" ]
        ]


nav : Model -> Html Msg
nav model =
    div []
        [ button [ onClick <| PageChange Home ] [ text "Home" ]
        , button [ onClick <| PageChange Search ] [ text "Search" ]
        ]


formatDate : Int -> String
formatDate mod =
    let
        date =
            mod
                * 1000
                |> toFloat
                |> Date.fromTime
    in
        (toString <| Date.dayOfWeek date) ++ " " ++ (toString <| Date.day date) ++ " " ++ (toString <| Date.month date) ++ " " ++ (toString <| Date.hour date) ++ ":" ++ (toString <| Date.minute date)


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.phxSocket PhxMsg
