module Types
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , WebsocketMsg(Sync)
        , SyncMsg(..)
        , Views(..)
        , Collection
        , Flags
        , Model
        , Note
        , ReceivedSyncMsg
        , Url
        )

import Phoenix.Socket as Socket exposing (Socket)
import Http
import Json.Encode exposing (Value, null)


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
    , collection : Collection
    , notes : List Note
    , error : Bool
    , syncingDatabase : Bool
    , syncingDatabaseMsg : String
    , noteColumns : List Bool
    , showingManageNoteColumns : Bool
    , view : Views
    }


type alias Collection =
    { mod : Int
    , notes : Int
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
    = PhxMsg (Socket.Msg Msg)
    | Websocket WebsocketMsg
    | Request RequestMsg
    | ViewChange Views
    | SearchInput String
    | ToggleNoteColumn Int
    | ToggleManageNotes
    | UrlIn Url
    | NoOp


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


type Views
    = HomeView
    | SearchView
