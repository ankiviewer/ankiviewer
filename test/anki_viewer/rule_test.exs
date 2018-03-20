defmodule AnkiViewer.RuleTest do
  use AnkiViewer.DataCase, async: false

  test "insert" do
    attrs = %{
      name: "duplicate front",
      code: "(deck, note) => {
        var fine = true;
        for (var i=0;i<=deck.length;i++) {
          if (deck[i].sfld == note.sfld && deck[i].nid != note.nid) {
            fine = false;
            break;
          }
        }
        return fine;
      }",
      tests: "[
        {
          deck: [
            {nid: 0, sfld: 'h'},
            {nid: 1, sfld: 'hi'}
          ],
          note: {nid: 0, sfld: 'h'},
          fine: true
        },
        {
          deck: [
            {nid: 0, sfld: 'h'},
            {nid: 1, sfld: 'h'},
          ]
        }
      ]"
    }

    Rule.insert!(attrs)

    [%Rule{name: name}] = Repo.all(Rule)
    assert name == "duplicate front"
  end
end
