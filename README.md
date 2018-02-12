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
+ mod :: last modified at
##### Note
+ cid :: integer # card id
+ nid :: integer # note id
+ cmod :: integer # card modified at
+ nmod :: integer # note modified at
+ mid :: integer # model id
+ tags :: {array, string} # space seperated list of tags
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
+ id :: integer
+ name :: string
+ code :: text # elixir code to run to determine if note passes rule
##### NoteRule
+ nid :: integer # note id
+ rid :: integer # rule id
+ fails :: boolean # if rule fails

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
  }
}
```

#### GET :: /api/notes?search=""&model=[]mid&deck=[]did&tags=[]tags&modelorder=[]{mid:ord}
(example: /api/notes?search=hello&model=123,456&deck=123&tags=leech&modelorder=123:0,456:1

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

#### GET :: /api/rules

```bash
[
  {
    "id": 1,
    "name": "rule name",
    "failures": 44
  },
  {
  ...
]
```

#### GET :: /api/rules/:id
[
  {

  }
]

### Sqlite

This app simply runs the squlite commands using the `sqlite3` exectuable

Locate your anki sqlite executable

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

