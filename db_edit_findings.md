Checks:
##### edit a tag and check db
col
+ mod change to current utc time
notes
+ mod updated to current utc time
+ usn becomes -1
+ tag updates
##### add a note (this was double sided note)
col
+ mod change to current utc time
cards (add 2)
+ id utc timestamp (ord 0 1 less than ord 1)
+ nid utc timestamp (before id) (ord 0 and 1 are same)
+ deck id
+ ord
+ usn utc timestamp (same)
+ type -1
+ due (7878 probs days)
+ everything else is 0
id|nid|did|ord|mod|usn|type|queue|due|ivl|factor|reps|lapses|left|odue|odid|flags|data
1518993388168|1518993383376|1482060876072|0|1518993388|-1|0|0|7878|0|0|0|0|0|0|0|0|
1518993388169|1518993383376|1482060876072|1|1518993388|-1|0|0|7878|0|0|0|0|0|0|0|0|
notes
  id           |guid      |mid|mod|usn|tags|flds|sfld|csum|flags|data
+ 1518993383376|s)km]Gr_tn|1482842770192|1518993388|-1||testtest|test|2840236005|0|
graves
usn|oid|type
-1|1518993388222|1
##### edit a note field
col
+ mod change
notes
+ mod updated to current utc time
+ usn becomes -1 edit is made
+ csum is updated
can be calculated with (on the first field):
```python
int(sha1("I go home".encode("utf-8")).hexdigest()[:8], 16)
```
##### remove a note (double sided)
col
+ mod updated
note
+ removed note
card
+ removed both cards
graves (for note and 2 cards)
-1|1518996121062|0 # oid is card id
-1|1518996121063|0 # oid is card id
-1|1518996116880|1 # oid is note id
