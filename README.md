[![Build Status](https://travis-ci.org/ankiviewer/ankiviewer.svg?branch=master)](https://travis-ci.org/ankiviewer/ankiviewer)
[![codecov](https://codecov.io/gh/ankiviewer/ankiviewer/branch/master/graph/badge.svg)](https://codecov.io/gh/ankiviewer/ankiviewer)
[![Cypress.io tests](https://img.shields.io/badge/cypress.io-tests-green.svg)](https://cypress.io)

# AnkiViewer

An app for viewing and optimising Anki flashcards

### Requirements

|Tech|Version|
|---|---|
|Node|>=8.10|
|Elm|0.19|
|Elixir|1.7.4|
|Phoenix|1.3|
|Sqlite|>=3.4|
|Postgres|>=10.5|

### Quick Start

Make sure you have the following environment variables in your `$PATH`:

`ANKI_SQLITE_PATH` - See https://github.com/ankiviewer/ankiviewer/blob/master/SQLITE.md for infor on this

```bash
# Clone the repo
git clone https://github.com/ankiviewer/ankiviewer.git && cd ankiviewer
# Install the dependencies
mix deps.get # elixir deps
(cd assets && npm install) # node deps
```

In one terminal window run `elm-live`
```bash
cd assets && npm run elm:watch
```

In the other terminal window run the phoenix server
```bash
mix phx.server
```

Now you can visit http://localhost:5000 from your browser.

### Tests

The Elixir tests can be run with:

```bash
mix test
```

The cypress tests can be run by running the above dev environment, then

```bash
cd assets && npm run cypress
# npm run cypress:open is also good when developing
```

Elm tests can be run with:

```bash
cd assets && node_modules/.bin/elm-test
```

### Designs

TODO

### Development

When developing the elm files in obsqure states make use of the `Dev.elm` entry point.

This is meant to easily work with difficult to reach states of the `View` sections of the app.

This can be run with:

```bash
elm reactor
```

Then visit http://localhost:8000/elm/Dev/Dev.elm

### Sqlite

How we interact with sqlite: https://github.com/ankiviewer/ankiviewer/blob/master/SQLITE.md

### Database structure

A breakdown of anki database structure: https://github.com/ankiviewer/ankiviewer/blob/master/DATABASE_STRUCTURE.md
