import { getAuth, UserRecord } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";

/** One row of the admin app's Users tab. */
export interface AdminUserRow {
  uid: string;
  email: string | null;
  anonymous: boolean;
  admin: boolean;
  disabled: boolean;
  created: string | null;
  lastSeen: string | null;
  favorites: number;
  devices: number;
  languages: string[];
  coupleCode: string | null;
  linked: boolean;
}

export interface UserFacts {
  favoritesByUid: Map<string, number>;
  devicesByUid: Map<string, string[]>; // languages, one per device
  coupleByUid: Map<string, { code: string; linked: boolean }>;
}

/** Pure: Auth record + Firestore facts → table row. */
export function toUserRow(u: Pick<UserRecord, "uid" | "email" | "disabled" | "customClaims" | "providerData" | "metadata">, facts: UserFacts): AdminUserRow {
  const langs = facts.devicesByUid.get(u.uid) ?? [];
  const couple = facts.coupleByUid.get(u.uid);
  return {
    uid: u.uid,
    email: u.email ?? null,
    anonymous: (u.providerData ?? []).length === 0,
    admin: u.customClaims?.admin === true,
    disabled: u.disabled === true,
    created: u.metadata?.creationTime ? new Date(u.metadata.creationTime).toISOString() : null,
    lastSeen: lastSeen(u.metadata),
    favorites: facts.favoritesByUid.get(u.uid) ?? 0,
    devices: langs.length,
    languages: [...new Set(langs)].sort(),
    coupleCode: couple?.code ?? null,
    linked: couple?.linked ?? false,
  };
}

function lastSeen(m: Partial<UserRecord["metadata"]> | undefined): string | null {
  const t = [m?.lastRefreshTime, m?.lastSignInTime, m?.creationTime]
    .filter((x): x is string => !!x)
    .map((x) => new Date(x).getTime())
    .filter((x) => !Number.isNaN(x));
  return t.length ? new Date(Math.max(...t)).toISOString() : null;
}

function requireAdmin(req: CallableRequest<unknown>): string {
  if (req.auth?.token?.admin !== true) {
    throw new HttpsError("permission-denied", "Admins only.");
  }
  return req.auth.uid;
}

const REGION = "europe-west1";
const MAX_USERS = 5000;

/** Users tab: every Auth user with favorites, devices and partner link. */
export const adminListUsers = onCall({ region: REGION }, async (req) => {
  requireAdmin(req);
  const db = getFirestore();
  const auth = getAuth();

  const users: UserRecord[] = [];
  let pageToken: string | undefined;
  do {
    const page = await auth.listUsers(1000, pageToken);
    users.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken && users.length < MAX_USERS);

  const [favorites, devices, couples, names, suggestions, waitlist, matches] =
    await Promise.all([
      db.collectionGroup("favorites").select("deleted").get(),
      db.collectionGroup("devices").select("language").get(),
      db.collection("couples").get(),
      db.collection("names").select("deleted").get(),
      db.collection("suggestions").count().get(),
      db.collection("ai_waitlist").count().get(),
      db.collectionGroup("matches").count().get(),
    ]);

  // users/{uid}/favorites/{id} and users/{uid}/devices/{fid}: uid = parent's parent.
  const favoritesByUid = new Map<string, number>();
  for (const d of favorites.docs) {
    if (d.get("deleted") === true) continue;
    const uid = d.ref.parent.parent?.id;
    if (uid) favoritesByUid.set(uid, (favoritesByUid.get(uid) ?? 0) + 1);
  }
  const devicesByUid = new Map<string, string[]>();
  for (const d of devices.docs) {
    const uid = d.ref.parent.parent?.id;
    if (uid) devicesByUid.set(uid, [...(devicesByUid.get(uid) ?? []), String(d.get("language") ?? "en")]);
  }
  const coupleByUid = new Map<string, { code: string; linked: boolean }>();
  let linkedCouples = 0;
  for (const c of couples.docs) {
    const members = (c.get("members") as string[] | undefined) ?? [];
    if (members.length === 2) linkedCouples++;
    for (const uid of members) coupleByUid.set(uid, { code: c.id, linked: members.length === 2 });
  }

  const rows = users
    .map((u) => toUserRow(u, { favoritesByUid, devicesByUid, coupleByUid }))
    .sort((a, b) => (b.lastSeen ?? "").localeCompare(a.lastSeen ?? ""));
  const weekAgo = Date.now() - 7 * 24 * 3600 * 1000;

  return {
    truncated: users.length >= MAX_USERS,
    stats: {
      users: rows.length,
      activeThisWeek: rows.filter((r) => r.lastSeen && Date.parse(r.lastSeen) >= weekAgo).length,
      withPush: rows.filter((r) => r.devices > 0).length,
      favorites: [...favoritesByUid.values()].reduce((a, b) => a + b, 0),
      names: names.docs.filter((d) => d.get("deleted") !== true).length,
      couplesLinked: linkedCouples,
      matches: matches.data().count,
      suggestions: suggestions.data().count,
      waitlist: waitlist.data().count,
    },
    users: rows,
  };
});

/** Users tab actions: grant/revoke admin, disable/enable an account. */
export const adminSetUser = onCall(
  { region: REGION },
  async (req: CallableRequest<{ uid?: string; admin?: boolean; disabled?: boolean }>) => {
    const me = requireAdmin(req);
    const { uid, admin, disabled } = req.data ?? {};
    if (typeof uid !== "string" || !uid) throw new HttpsError("invalid-argument", "uid is required.");
    if (uid === me && (admin === false || disabled === true)) {
      throw new HttpsError("failed-precondition", "You can't remove your own admin access or disable yourself.");
    }
    const auth = getAuth();
    const user = await auth.getUser(uid);
    if (typeof admin === "boolean") {
      if (admin && !user.email) {
        throw new HttpsError("failed-precondition", "Only email accounts can be admins.");
      }
      const claims = { ...(user.customClaims ?? {}) };
      if (admin) claims.admin = true;
      else delete claims.admin;
      await auth.setCustomUserClaims(uid, claims);
    }
    if (typeof disabled === "boolean") {
      await auth.updateUser(uid, { disabled });
      if (disabled) await auth.revokeRefreshTokens(uid);
    }
    return { ok: true };
  },
);
