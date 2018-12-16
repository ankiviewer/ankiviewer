module Session exposing
    ( Flags
    , Session
    , empty
    , fromFlags
    , updateCollection
    , updateRules
    )

import Collection exposing (Collection)
import Rules.Rule exposing (Rule)
import Set exposing (Set)


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


updateCollection : Session -> Collection -> Session
updateCollection session collection =
    { session | collection = collection }


updateRules : Session -> List Rule -> Session
updateRules session rules =
    { session | rules = rules }
