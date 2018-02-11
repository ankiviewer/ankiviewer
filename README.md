# AnkiViewer

### Quick Start

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Models

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
+ tags :: string # space seperated list of tags
+ flds :: string # field 1 concatenated with field 2
+ sfld :: string # just field 2
+ did :: integer # deck id
+ ord :: integer # which field was the question 0 or 1
+ type :: integer # 0=new, 1=learning, 2=due
+ queue :: integer # same as type with, -1=suspended, -2=user buried, -3=shed buried
+ due :: integer # integer day relative to collections creation time
+ reps :: integer # no of reviews
+ lapses :: integer # no of times card went from answered correctly to not

### Api

GET :: /api/collection
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

GET :: /api/notes?search=""&model=[]mid&deck=[]did&tags=[]tags&modelorder=[]{mid:ord}
{

}
