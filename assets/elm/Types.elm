module Types exposing
    ( Collection
    , D
    , ErrRuleResponse
    , Flags
    , M
    , Model
    , Msg(..)
    , Note
    , ReceivedSyncMsg
    , RequestMsg(..)
    , Rule
    , RuleResponse
    , Rules(..)
    , SyncMsg(..)
    , Url
    , Views(..)
    , WebsocketMsg(..)
    )

import Http
import Json.Encode exposing (Value, null)
import Phoenix.Socket as Socket exposing (Socket)


type alias Flags =
    Maybe (List Bool)


type alias Model =
    { phxSocket : Socket Msg
    , search : String
    , model : String
    , deck : String
    , tags : List String
    , order : List Int
    , rule : Int
    , rules : List Rule
    , ruleEditRid : Int
    , ruleEdit : Rule
    , newRule : Rule
    , ruleErr : String
    , ruleValidationErr : ErrRuleResponse
    , areYouSureDelete : Int
    , collection : Collection
    , cards : List Note
    , syncingError : Bool
    , syncingDatabase : Bool
    , syncingDatabaseMsg : String
    , cardColumns : List Bool
    , showingManageNoteColumns : Bool
    , view : Views
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


type alias ErrRuleResponse =
    { code : String
    , tests : String
    , name : String
    }


type alias RuleResponse =
    { err : Bool
    , rules : List Rule
    , ruleErr : ErrRuleResponse
    }


type alias Rule =
    { code : String
    , tests : String
    , name : String
    , rid : Int
    }


type alias Collection =
    { mod : Int
    , cards : Int
    , models : List M
    , decks : List D
    }


type alias Note =
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


type alias ReceivedSyncMsg =
    { syncMsg : String
    }


type alias Url =
    { view : String
    }


type Msg
    = NoOp
    | PhxMsg (Socket.Msg Msg)
    | RuleMsg Rules
    | Request RequestMsg
    | SearchInput String
    | ToggleDeck String
    | ToggleManageNotes
    | ToggleModel String
    | ToggleNoteColumn Int
    | UrlIn Url
    | ViewChange Views
    | Websocket WebsocketMsg


type Rules
    = Add
    | Update
    | Delete Int
    | ToggleEdit Int
    | AreYouSureDelete Int
    | FocusNewInputs
    | InputEditCode String
    | InputEditName String
    | InputEditTests String
    | InputCode String
    | InputName String
    | InputTests String
    | RuleNoOp


type WebsocketMsg
    = Sync SyncMsg


type SyncMsg
    = Start
    | Receive Value
    | Stopping Value
    | Stop


type RequestMsg
    = GetCollection
    | NewCollection (Result Http.Error Collection)
    | GetNotes
    | NewNotes (Result Http.Error (List Note))
    | GetRules
    | NewRules (Result Http.Error (List Rule))
    | NewRuleResponse (Result Http.Error RuleResponse)
    | CreateRule Model
    | UpdateRule Model
    | DeleteRule Int


type Views
    = HomeView
    | SearchView
    | RuleView
