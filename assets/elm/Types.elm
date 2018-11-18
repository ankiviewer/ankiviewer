module Types exposing
    ( Collection
    , D
    , ErrorType(..)
    , Flags
    , M
    , Model
    , Msg(..)
    , Page(..)
    , SyncData
    )

import Browser
import Browser.Navigation as Nav
import Http
import Json.Encode as Encode
import Url


type alias Flags =
    {}


type alias Model =
    { incomingMsg : String
    , error : ErrorType
    , syncPercentage : Int
    , isSyncing : Bool
    , collection : Collection
    , key : Nav.Key
    , page : Page
    }


type ErrorType
    = HttpError
    | SyncError
    | None


type Msg
    = NoOp
    | NewCollection (Result Http.Error Collection)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | StartSync
    | SyncMsg Encode.Value
    | StopSync


type Page
    = Home
    | Search
    | Rules
    | NotFound


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


type alias SyncData =
    { message : String
    , percentage : Int
    }
