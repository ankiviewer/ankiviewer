module Session exposing
    ( Flags
    , Session
    , empty
    , fromFlags
    )

import Set exposing (Set)


type alias Session =
    { excludedColumns : Set String
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
            Session (Set.fromList excludedColumns)

        Nothing ->
            empty


empty : Session
empty =
    { excludedColumns = Set.empty
    }
