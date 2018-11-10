module Types exposing (..)

import Http

type alias Flags =
    {}

type alias Model =
    { incomingMsg : String
    , error : ErrorType
    , syncPercentage : Int
    , isSyncing : Bool
    , collection : Collection
    , page : Page
    }

type ErrorType
    = HttpError
    | SyncError
    | None


type Msg
    = NoOp
    | ChangePage Page
    | NewCollection (Result Http.Error Collection)
    | GetCollection


type Page
    = Home
    | Search
    | Rules


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


