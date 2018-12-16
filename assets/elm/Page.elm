module Page exposing
    ( Page(..)
    , session
    , sessionMap
    )

import Home
import Rules
import Search
import Session exposing (Session)


type Page
    = NotFound Session
    | Home Home.Model
    | Search Search.Model
    | Rules Rules.Model


session : Page -> Session
session page =
    case page of
        NotFound session_ ->
            session_

        Home m ->
            m.session

        Search m ->
            m.session

        Rules m ->
            m.session


sessionMap : (Session -> Session) -> Page -> Page
sessionMap fn page =
    case page of
        NotFound session_ ->
            NotFound (fn session_)

        Home m ->
            Home { m | session = fn m.session }

        Search m ->
            Search { m | session = fn m.session }

        Rules m ->
            Rules { m | session = fn m.session }
