port module Search exposing
    ( Model
    , Msg
    , init
    , initialModel
    , update
    , view
    )

import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (class, classList, id, style)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Rules
import Rules.Rule exposing (Rule)
import Session exposing (Session)
import Set exposing (Set)
import Set.Extra as Set
import Url
import Url.Builder as Url


port setColumns : Encode.Value -> Cmd msg


cardColumns : List String
cardColumns =
    [ "model", "mod", "ord", "tags", "deck", "type", "queue", "due", "reps", "lapses", "front", "back" ]


view : Model -> Html Msg
view model =
    if model.showColumns then
        div
            []
            [ div
                []
                [ text "Green is showing, red is not showing, click to toggle"
                ]
            , div
                [ id "search-columns_container"
                ]
                (List.map
                    (\col ->
                        div
                            [ class "dib pa1 pointer red"
                            , classList
                                [ ( "green", not (Set.member col model.excludedColumns) )
                                ]
                            , onClick <| ToggleColumn col
                            ]
                            [ text col ]
                    )
                    cardColumns
                )
            , div
                []
                [ button
                    [ onClick ToggleShowColumns
                    , id "search-done"
                    ]
                    [ text "Done"
                    ]
                ]
            ]

    else
        div
            []
            [ div
                []
                [ input
                    [ onInput SearchInput
                    , id "search-input"
                    ]
                    []
                , div
                    []
                    (List.map
                        (\{ name, rid, percentage } ->
                            div
                                [ class "pointer dib pa2"
                                , classList
                                    [ ( "bg-primary", Maybe.withDefault 0 model.selectedRule == rid )
                                    ]
                                , onClick (ToggleRule rid)
                                ]
                                [ text (name ++ ":" ++ String.fromInt percentage ++ "%")
                                ]
                        )
                        model.rules
                    )
                , div
                    []
                    [ div
                        []
                        (List.map
                            (\{ name } ->
                                div
                                    [ class "pointer dib pa2"
                                    , classList
                                        [ ( "bg-primary", Maybe.withDefault "" model.deck == name )
                                        ]
                                    , onClick (ToggleDeck name)
                                    ]
                                    [ text name
                                    ]
                            )
                            model.session.collection.decks
                        )
                    ]
                ]
            , if model.search == "" && model.selectedRule == Nothing then
                div
                    []
                    [ button
                        [ onClick ToggleShowColumns
                        , id "search-edit_columns"
                        ]
                        [ text "Edit columns"
                        ]
                    ]

              else
                div
                    []
                    [ div
                        []
                        [ text ("Card count: " ++ String.fromInt model.count)
                        ]
                    , div
                        [ id "search-column_headers" ]
                        (let
                            columns =
                                cardColumns
                                    |> List.filter
                                        (\col ->
                                            not (Set.member col model.excludedColumns)
                                        )
                         in
                         List.map
                            (\col ->
                                div
                                    [ class "dib pa1"
                                    , style "width" <| String.fromInt (100 // List.length columns) ++ "%"
                                    ]
                                    [ text col
                                    ]
                            )
                            columns
                        )
                    , div
                        [ id "search-result-rows" ]
                        (List.map
                            (\card ->
                                cardColumns
                                    |> List.foldr
                                        (\cur acc ->
                                            if not (Set.member cur model.excludedColumns) then
                                                case cur of
                                                    "model" ->
                                                        card.model :: acc

                                                    "mod" ->
                                                        String.fromInt card.mod :: acc

                                                    "ord" ->
                                                        String.fromInt card.ord :: acc

                                                    "tags" ->
                                                        String.join ", " card.tags :: acc

                                                    "deck" ->
                                                        card.deck :: acc

                                                    "type" ->
                                                        String.fromInt card.ttype :: acc

                                                    "queue" ->
                                                        String.fromInt card.queue :: acc

                                                    "due" ->
                                                        String.fromInt card.due :: acc

                                                    "reps" ->
                                                        String.fromInt card.reps :: acc

                                                    "lapses" ->
                                                        String.fromInt card.lapses :: acc

                                                    "front" ->
                                                        card.front :: acc

                                                    "back" ->
                                                        card.back :: acc

                                                    _ ->
                                                        let
                                                            _ =
                                                                Debug.log "UNKNOWN" cur
                                                        in
                                                        acc

                                            else
                                                acc
                                        )
                                        []
                            )
                            model.cards
                            |> List.map
                                (\cards ->
                                    div
                                        [ class "pa1" ]
                                        (List.map
                                            (\card ->
                                                div
                                                    [ class "pa1 dib overflow-hidden"
                                                    , style "width" <| String.fromInt (100 // List.length cards) ++ "%"
                                                    ]
                                                    [ text card
                                                    ]
                                            )
                                            cards
                                        )
                                )
                        )
                    ]
            ]


encodeColumns : Set String -> Encode.Value
encodeColumns excludedColumns =
    Encode.object
        [ ( "excludedColumns", Encode.set Encode.string excludedColumns )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewCards (Ok { cards, count }) ->
            ( { model | cards = cards, count = count }, Cmd.none )

        NewCards (Err err) ->
            let
                _ =
                    Debug.log "err" err
            in
            ( model, Cmd.none )

        SearchInput search ->
            ( { model | search = search }, getCards { search = search, rule = model.selectedRule, deck = model.deck } )

        ToggleShowColumns ->
            ( { model | showColumns = not model.showColumns }, Cmd.none )

        ToggleColumn col ->
            let
                excludedColumns =
                    Set.toggle col model.excludedColumns
            in
            ( { model | excludedColumns = excludedColumns }, setColumns (encodeColumns excludedColumns) )

        NewRules (Ok rules) ->
            ( { model | rules = rules }, Cmd.none )

        NewRules (Err err) ->
            let
                _ =
                    Debug.log "err" err
            in
            ( model, Cmd.none )

        ToggleRule rid ->
            case model.selectedRule of
                Just selectedRid ->
                    if selectedRid == rid then
                        ( { model | selectedRule = Nothing }, Cmd.none )

                    else
                        ( { model | selectedRule = Just rid }, getCards { search = model.search, rule = Just rid, deck = model.deck } )

                Nothing ->
                    ( { model | selectedRule = Just rid }, getCards { search = model.search, rule = Just rid, deck = model.deck } )

        ToggleDeck deck ->
            case model.deck of
                Just d ->
                    if deck == d then
                        ( { model | deck = Nothing }, Cmd.none )

                    else
                        ( { model | deck = Just deck }, Cmd.none )

                Nothing ->
                    ( { model | deck = Just deck }, Cmd.none )


type Msg
    = NewCards (Result Http.Error CardsResponse)
    | NewRules (Result Http.Error (List Rule))
    | SearchInput String
    | ToggleShowColumns
    | ToggleColumn String
    | ToggleRule Int
    | ToggleDeck String


type alias Model =
    { session : Session
    , showColumns : Bool
    , excludedColumns : Set String
    , search : String
    , cards : List Card
    , count : Int
    , rules : List Rule
    , selectedRule : Maybe Int
    , deck : Maybe String
    }


type alias Card =
    { model : String
    , mod : Int
    , ord : Int
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


type alias Search =
    { search : String
    , rule : Maybe Int
    , deck : Maybe String
    }


initialModel : Session -> Model
initialModel session =
    { session = session
    , showColumns = False
    , excludedColumns = session.excludedColumns
    , search = ""
    , cards = []
    , count = 0
    , rules = []
    , selectedRule = Nothing
    , deck = Nothing
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( initialModel session, getRules )


getRules : Cmd Msg
getRules =
    Http.get
        { url = "/api/rules"
        , expect = Http.expectJson NewRules Rules.rulesDecoder
        }


getCards : Search -> Cmd Msg
getCards { search, rule, deck } =
    let
        url =
            Url.absolute
                [ "api", "cards" ]
                [ Url.string "search" search
                , Url.string "model" ""
                , Url.string "deck" (Maybe.withDefault "" deck)
                , Url.string "tags" ""
                , Url.string "modelorder" ""
                , Url.string "rule" (Maybe.map String.fromInt rule |> Maybe.withDefault "")
                ]
    in
    Http.get
        { url = url
        , expect = Http.expectJson NewCards cardsResponseDecoder
        }


type alias CardsResponse =
    { cards : List Card
    , count : Int
    }


cardsResponseDecoder : Decoder CardsResponse
cardsResponseDecoder =
    Decode.succeed CardsResponse
        |> required "cards" (Decode.list cardsDecoder)
        |> required "count" Decode.int


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
