module Set.Extra exposing (toggle)

import Set exposing (Set)


toggle : comparable -> Set comparable -> Set comparable
toggle elem set =
    if Set.member elem set then
        Set.remove elem set

    else
        Set.insert elem set
