# AnkiViewer

### Quick Start

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Schemas

##### Collection
+ crt :: integer # created at
+ mod :: integer # last modified at 
+ tags :: {:array, :string} # array of strings of tags

##### Model
+ mid :: integer # model id
+ did :: integer # deck id
+ flds :: {:array, :string} # {"Front", "Back"}
+ mod :: integer # last modified at
+ name :: string # model name

##### Deck
+ did :: integer # deck id
+ name :: string # deck name
+ mod :: integer # last modified at

##### Note
+ cid :: integer # card id
+ nid :: integer # note id
+ cmod :: integer # card modified at
+ nmod :: integer # note modified at
+ mid :: integer # model id
+ tags :: {array, string} # array of strings of tags
+ flds :: string # field 1 concatenated with field 2
+ sfld :: string # just field 2
+ did :: integer # deck id
+ ord :: integer # which field was the question 0 or 1
+ type :: integer # 0=new, 1=learning, 2=due
+ queue :: integer # same as type with, -1=suspended, -2=user buried, -3=shed buried
+ due :: integer # integer day relative to collections creation time
+ reps :: integer # no of reviews
+ lapses :: integer # no of times card went from answered correctly to not

##### Rule
+ rid :: integer
+ name :: string
+ code :: text # elixir code to run to determine if note passes rule

##### NoteRule
+ nid :: integer # note id
+ rid :: integer # rule id
+ fails :: boolean # if rule fails
+ comment :: string # optional comment explaining why the rule failed
+ url :: string # optional url to external api/page scrape
+ ignore :: bool # ignore failure default false
+ solution :: string # explaining a solution to be implemented for rule failure

### Api
GET :: /api/collection
```bash
{
  crt: integer,
  mod: integer,
  tags: []string,
  model: []{
    mid: integer,
    did: integer,
    flds: []string,
    mod: integer,
    name: string
  },
  deck: []{
    did: integer,
    name: string,
    mod: integer
  },
  rules: []{
    id: integer,
    name: string,
    failures: integer
  }
}
```

#### GET :: /api/notes?search=""&model=[]mid&deck=[]did&tags=[]tags&modelorder=[]{mid:ord}&rule=id
(example: /api/notes?search=hello&model=123,456&deck=123&tags=leech&modelorder=123:0,456:1)

(state follows the conventions described in the notes schema above in type and queue)

```bash
[
  {
    "model": "deen",
    "tags": ["leech", "other"],
    "deck": "de",
    "state": -1,
    "queue": 2,
    "due": 5,
    "reps": 4,
    "lapses": 2,
    "front": "hello",
    "back": "hallo"
  }
]
```

#### GET :: /api/rules/:id?onlyfailures=bool&solution=bool

```bash
[
  {
    "front": "front",
    "back": "back",
    "comment": "comment"
  },
  {
  ...
]
```

#### POST :: /api/rules

##### body

```bash
{
  ignore: bool
}
```

```bash
{
  solution: string
}
```

##### response

```bash
{}
```

### Channels

##### sync database

```bash
{
  ttype: string, # "collection"|"note"
  number: integer,
  total: integer
}
```

##### sync rule

```bash
{
  name: string,
  number: integer,
  total: integer,
  message: string
}
```

### Sqlite

This app simply runs the squlite commands using the `sqlite3` exectuable

Locate your anki sqlite executable

(This may help: `find ~ -type f | grep \.anki2`)

Mine was found here:  `~/Library/Application\ Support/Anki2/sam/colletion.anki2`

Export it as follows:

```bash
export ANKI_SQLITE_PATH="$HOME/Library/Application Support/Anki2/sam/colletion.anki2"
```

you can open the cli with the following command

```bash
sqlite3 $ANKI_SQLITE_PATH
```

or you can have each command saved in your `bash` `history` by running:


```bash
sqlite3 $ANKI_SQLITE_PATH 'cmd'
```

useful commands are as follows:

##### list all tables
```bash
sqlite3 $ANKI_SQLITE_PATH '.tables'
```

##### see spefic table (with column headers)
```bash
sqlite3 -header $ANKI_SQLITE_PATH 'select * from col'
```

### Database structure

There is a thorough breakdown of the anki database structure [here](https://github.com/ankiviewer/ankiviewer/blob/master/DATABASE_STRUCTURE.md)

What is useful for us is the following:

#### collection

```bash
sqlite3 $ANKI_SQLITE_PATH 'select models, decks, tags, mod, crt from col'
```

#### notes
```bash
sqlite3 $ANKI_SQLITE_PATH 'SELECT
  cards.id AS cid,
  notes.id AS nid,
  cards.mod AS cmod,
  notes.mod AS nmod,
  notes.mid AS mid,
  notes.tags AS tags,
  notes.flds AS flds,
  notes.sfld AS sfld,
  cards.did AS did,
  cards.ord AS ord,
  cards.type AS type,
  cards.queue AS queue,
  cards.due AS due,
  cards.reps AS reps,
  cards.lapses AS lapses
  FROM
  notes
  INNER JOIN cards
  ON
  notes.id = cards.nid'
```

### Views

#### Home

+ Upload sqlite3 file (button to upload sqlite3 file to s3)
+ Load database
  + from local (button to load data from the local s3 file)
  + from s3 (button to load into the database, the current sqlite3 file)
  + soft reload (perform diffs on the current database which should be a lot faster).
  + hard reload (delete entire notes from database and reload them in entirely from scratch).
(separate socket for each of these operations)
+ Show last sqlite3 upload time and database load time from each s3 and local as well as local change time
+ Rules management (a list of all rules with current stats for each rule with ability to run a rule through the database)
(socket connection here)

#### Search

+ search
+ filter by model, deck, tags
+ filter by rule
+ add comment to note
+ note list
+ edit note

#### Database edits

I would also like to edit my Anki database from changing words from within the av app.
This will require doing a diff on all the tables from before making the edit to after making the edit from within the Anki desktop app.
I will document the diff from the output of:
```bash
for t in $(sqlite3 $ANKI_SQLITE_PATH '.tables');do;sqlite3 $ANKI_SQLITE_PATH "select * from $t";done
```
I would like to perform the following operations:
+ edit a notes tag
+ add a note
+ remove a note
+ edit a notes fields

Findings documented here: [!findings](./db_edit_findings.md)

