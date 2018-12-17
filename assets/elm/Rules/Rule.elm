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
    , percentage : Int
    , dids : Set Int
    }


fromSafeRule : SafeRule -> Rule
fromSafeRule safeRule =
    { name = safeRule.name
    , code = safeRule.code
    , tests = safeRule.tests
    , rid = safeRule.rid
    , percentage = safeRule.percentage
    , dids = Set.fromList safeRule.dids
    }


type alias SafeRule =
    { name : String
    , code : String
    , tests : String
    , rid : Int
    , percentage : Int
    , dids : List Int
    }


empty : List Int -> Rule
empty dids =
    { name = ""
    , code = ""
    , tests = ""
    , rid = 0
    , percentage = 0
    , dids = Set.fromList dids
    }
