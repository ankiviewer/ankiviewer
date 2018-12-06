module Home exposing
    ( Model
    , init
    , initialModel
    , Msg
    , update
    , view
    )


import Http
import Json.Encode as Encode
import Html exposing (Html, text)


type alias Model =
    { collection : Collection
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
view model =
    text "Home"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


initialModel : Model
initialModel =
    { collection = Collection 0 0 [] []
    , syncState = NotSyncing
    }

init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )
