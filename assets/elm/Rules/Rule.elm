module Rules.Rule exposing
    ( Rule
    , SafeRule
    , empty
    , fromSafeRule
    )

import Set exposing (Set)


type alias Rule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    , run : Bool
    , dids : Set Int
    }


fromSafeRule : SafeRule -> Rule
fromSafeRule safeRule =
    { name = safeRule.name
    , code = safeRule.code
    , tests = safeRule.tests
    , rid = safeRule.rid
    , run = safeRule.run
    , dids = Set.fromList safeRule.dids
    }


type alias SafeRule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    , run : Bool
    , dids : List Int
    }


empty : List Int -> Rule
empty dids =
    { name = ""
    , code = ""
    , tests = ""
    , rid = 0
    , run = False
    , dids = Set.fromList dids
    }
