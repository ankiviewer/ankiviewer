module Rules.Rule exposing
    ( Rule
    , empty
    )


type alias Rule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    , run : Bool
    }


empty : Rule
empty =
    { name = ""
    , code = ""
    , tests = ""
    , rid = 0
    , run = False
    }
