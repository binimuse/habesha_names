// Grants (or removes) admin access to the admin web app (admin/).
//
//   cd functions
//   node scripts/set-admin.js you@example.com           # grant
//   node scripts/set-admin.js you@example.com --remove  # revoke
//
// The account must exist first: Firebase console → Authentication → Users →
// Add user (Email/Password). Sets the custom claim `admin: true`, which
// firestore.rules check (isAdmin()). Uses functions/service-account.json.
"use strict";

const path = require("node:path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const [email, flag] = process.argv.slice(2);
if (!email || !email.includes("@")) {
  console.error("Usage: node scripts/set-admin.js <email> [--remove]");
  process.exit(1);
}
const remove = flag === "--remove";

initializeApp({
  credential: cert(require(path.resolve(__dirname, "../service-account.json"))),
  projectId: "habesha-baby-names",
});

(async () => {
  const auth = getAuth();
  const user = await auth.getUserByEmail(email);
  const claims = { ...(user.customClaims ?? {}) };
  if (remove) delete claims.admin;
  else claims.admin = true;
  await auth.setCustomUserClaims(user.uid, claims);
  console.log(
    `${remove ? "Removed admin from" : "Granted admin to"} ${email} (uid ${user.uid}).`,
  );
  console.log("In the admin app, click \"Check again\" or sign in again.");
})().catch((e) => {
  console.error(e.code === "auth/user-not-found"
    ? `No account for ${email}. Create it in Firebase console → Authentication → Users.`
    : e.message);
  process.exit(1);
});
