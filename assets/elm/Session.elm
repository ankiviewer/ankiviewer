module Session exposing
    ( Flags
    , Session
    , empty
    , fromFlags
    )

import Collection exposing (Collection)
import Set exposing (Set)
import Rules.Rule exposing (Rule)


type alias Session =
    { excludedColumns : Set String
    , collection : Collection
    , rules : List Rule
    }


type alias Flags =
    Maybe FlagData


type alias FlagData =
    { excludedColumns : List String
    }


fromFlags : Flags -> Session
fromFlags flags =
    case flags of
        Just { excludedColumns } ->
            { empty | excludedColumns = Set.fromList excludedColumns }

        Nothing ->
            empty


empty : Session
empty =
    { excludedColumns = Set.empty
    , collection = Collection 0 0 [] []
    , rules = []
    }
