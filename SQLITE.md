# Sqlite

This app accesses the Anki database simply by running commands using the `sqlite3` executable

You can Locate your anki sqlite executable

(This may help: `find ~ -type f | grep \.anki2`)

Mine was found here:  `~/Library/Application\ Support/Anki2/sam/colletion.anki2`

Export it as follows:

```bash
export ANKI_DB_PATH="$HOME/Library/Application Support/Anki2/sam/colletion.anki2"
```

you can open the cli with the following command

```bash
sqlite3 $ANKI_DB_PATH
```

or you can have each command saved in your `bash` `history` by running:


```bash
sqlite3 $ANKI_DB_PATH 'cmd'
```

useful commands are as follows:

##### list all tables
```bash
sqlite3 $ANKI_DB_PATH '.tables'
```

##### see spefic table (with column headers)
```bash
sqlite3 -header $ANKI_DB_PATH 'select * from col'
```

#### collection

```bash
sqlite3 $ANKI_DB_PATH 'select models, decks, tags, mod, crt from col'
```

#### notes
```bash
sqlite3 $ANKI_DB_PATH 'SELECT
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

### Monitoring database edits

After an Anki edit is made the diff can be seen by piping the output of this command into a file and doing a diff on these files after the change.

```bash
for t in $(sqlite3 $ANKI_DB_PATH '.tables');do;sqlite3 $ANKI_DB_PATH "select * from $t";done
```

Some of the db edit finding can be found here: https://github.com/ankiviewer/ankiviewer/blob/master/DB_EDIT_FINDINGS.md
