module Types exposing
    ( Card
    , CardSearchParams
    , Collection
    , D
    , ErrorType(..)
    , Flags
    , M
    , Model
    , Msg(..)
    , Page(..)
    , RequestMsg(..)
    , Rule
    , RuleInputType(..)
    , RuleResponse
    , SyncData
    , SyncMsg(..)
    , SyncState(..)
    )

import Browser
import Browser.Navigation as Nav
import Http
import Json.Encode as Encode
import Set exposing (Set)
import Url


type alias Flags =
    {}


type alias Model =
    { key : Nav.Key
    , page : Page
    , collection : Collection
    , homeMsg : Result ErrorType SyncState
    , showColumns : Bool
    , excludedColumns : Set String
    , search : String
    , cards : List Card
    , rules : List Rule
    , ruleInput : Rule
    , ruleErr : Maybe Rule
    , selectedRule : Maybe Int
    }


type alias Rule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    }


type alias RuleResponse =
    { err : Bool
    , rules : List Rule
    , ruleErr : Rule
    }


type SyncState
    = Syncing ( String, Int )
    | NotSyncing


type ErrorType
    = HttpError String
    | SyncError String


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Request RequestMsg
    | Sync SyncMsg
    | ToggleShowColumns
    | ToggleColumn String
    | SearchInput String
    | RuleInput RuleInputType String
    | ToggleRule Int
    | RunRule Int


type SyncMsg
    = StartSync
    | StopSync
    | SyncIncomingMsg Encode.Value


type RequestMsg
    = NewCollection (Result Http.Error Collection)
    | NewRules (Result Http.Error (List Rule))
    | NewRuleResponse (Result Http.Error RuleResponse)
    | NewCards (Result Http.Error (List Card))
    | GetRules
    | CreateRule
    | UpdateRule
    | DeleteRule Int


type RuleInputType
    = RuleName
    | RuleCode
    | RuleTests


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


type alias CardSearchParams =
    { search : String
    }
