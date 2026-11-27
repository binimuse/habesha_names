import assert from "node:assert/strict";
import { test } from "node:test";

import { toUserRow, UserFacts } from "./admin";

const facts: UserFacts = {
  favoritesByUid: new Map([["a", 3]]),
  devicesByUid: new Map([["a", ["am", "en", "am"]]]),
  coupleByUid: new Map([["a", { code: "123456", linked: true }]]),
};

test("user row combines Auth record and Firestore facts", () => {
  const row = toUserRow(
    {
      uid: "a",
      email: "me@x.com",
      disabled: false,
      customClaims: { admin: true },
      providerData: [{ providerId: "password" } as never],
      metadata: {
        creationTime: "Wed, 25 Nov 2026 19:12:19 GMT",
        lastSignInTime: "Wed, 25 Nov 2026 19:12:19 GMT",
        lastRefreshTime: "Thu, 26 Nov 2026 09:00:00 GMT",
      } as never,
    },
    facts,
  );
  assert.equal(row.admin, true);
  assert.equal(row.anonymous, false);
  assert.equal(row.favorites, 3);
  assert.equal(row.devices, 3);
  assert.deepEqual(row.languages, ["am", "en"]);
  assert.equal(row.coupleCode, "123456");
  assert.equal(row.lastSeen, "2026-11-26T09:00:00.000Z"); // latest of the times
});

test("anonymous user with no data", () => {
  const row = toUserRow(
    { uid: "b", email: undefined, disabled: false, customClaims: undefined, providerData: [], metadata: { creationTime: "Thu, 26 Nov 2026 08:00:00 GMT" } as never },
    facts,
  );
  assert.equal(row.anonymous, true);
  assert.equal(row.admin, false);
  assert.equal(row.favorites, 0);
  assert.equal(row.coupleCode, null);
  assert.equal(row.lastSeen, "2026-11-26T08:00:00.000Z");
});
