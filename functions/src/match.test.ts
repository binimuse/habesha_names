import assert from "node:assert/strict";
import { test } from "node:test";

import { decideMatch, Like, matchPushText, matchRecipients } from "./match";

const members = ["alice", "bob"];
const like = (uid: string, name_id = "hiwot", superLike = false): Like => ({
  uid,
  name_id,
  super: superLike,
});

test("both partners liked the name → match", () => {
  assert.deepEqual(decideMatch(members, [like("bob"), like("alice")], "hiwot"), {
    name_id: "hiwot",
    uids: ["alice", "bob"],
    super: false,
  });
});

test("only one partner liked it → no match", () => {
  assert.equal(decideMatch(members, [like("alice")], "hiwot"), null);
});

test("likes for other names don't count", () => {
  assert.equal(
    decideMatch(members, [like("alice"), like("bob", "selam")], "hiwot"),
    null,
  );
});

test("a super-like from either partner marks the match as super", () => {
  const m = decideMatch(members, [like("alice", "hiwot", true), like("bob")], "hiwot");
  assert.equal(m?.super, true);
});

test("couple not linked yet (one member) → no match", () => {
  assert.equal(decideMatch(["alice"], [like("alice"), like("bob")], "hiwot"), null);
});

test("likes from someone who left the couple are ignored", () => {
  assert.equal(
    decideMatch(members, [like("alice"), like("mallory")], "hiwot"),
    null,
  );
});

test("duplicate likes from one person are not a match", () => {
  assert.equal(decideMatch(members, [like("alice"), like("alice")], "hiwot"), null);
});

test("only the partner who liked first is notified", () => {
  const d = decideMatch(members, [like("bob"), like("alice")], "hiwot")!;
  assert.deepEqual(matchRecipients(d, "alice"), ["bob"]);
  assert.deepEqual(matchRecipients(d, "bob"), ["alice"]);
});

test("match push text follows the recipient's language", () => {
  assert.deepEqual(matchPushText("en", "Hiwot", "ሕይወት", false), {
    title: "It's a match! 💞",
    body: "You both liked Hiwot · ሕይወት.",
  });
  assert.equal(matchPushText(undefined, "Hiwot", "", true).title, "It's a super match! 🌟");
  assert.deepEqual(matchPushText("am", "Hiwot", "ሕይወት", false), {
    title: "ተዛመዳችሁ! 💞",
    body: "ሁለታችሁም ሕይወትን ወደዳችሁት።",
  });
});
