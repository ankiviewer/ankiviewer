module Tests exposing (all)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


all : Test
all =
    describe "test"
        [ test "true" <|
            \_ ->
                let
                    actual = True
                    expected = True
                in
                    Expect.equal actual expected
        ]
