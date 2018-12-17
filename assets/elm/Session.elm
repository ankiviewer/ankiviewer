module Session exposing
    ( Flags
    , Session
    , empty
    , fromFlags
    , updateCollection
    , updateRules
    )

import Collection exposing (Collection)
import Rules.Rule as Rule exposing (Rule, SafeRule)
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
    , collection : Collection
    , rules : List SafeRule
    }


fromFlags : Flags -> Session
fromFlags flags =
    case flags of
        Just { excludedColumns, collection, rules } ->
            { empty
                | excludedColumns = Set.fromList excludedColumns
                , collection = collection
                , rules = List.map Rule.fromSafeRule rules
            }

        Nothing ->
            empty


empty : Session
empty =
    { excludedColumns = Set.empty
    , collection = Collection 0 0 [] []
    , rules = []
    }


updateCollection : Collection -> Session -> Session
updateCollection collection session =
    { session | collection = collection }


updateRules : List Rule -> Session -> Session
updateRules rules session =
    { session | rules = rules }
