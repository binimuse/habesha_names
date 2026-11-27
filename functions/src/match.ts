/** A document in couples/{code}/likes. */
export interface Like {
  uid: string;
  name_id: string;
  super?: boolean;
}

/** What gets written to couples/{code}/matches/{name_id}. */
export interface MatchDecision {
  name_id: string;
  uids: string[];
  super: boolean;
}

/**
 * A match happens when *every* member of a linked couple (exactly two
 * people) has liked the same name. Likes from people who are no longer
 * members are ignored.
 */
export function decideMatch(
  members: readonly string[],
  likes: readonly Like[],
  nameId: string,
): MatchDecision | null {
  const couple = [...new Set(members)];
  if (couple.length !== 2) return null;

  const forName = likes.filter(
    (l) => l.name_id === nameId && couple.includes(l.uid),
  );
  const likers = new Set(forName.map((l) => l.uid));
  if (!couple.every((uid) => likers.has(uid))) return null;

  return {
    name_id: nameId,
    uids: [...couple].sort(),
    super: forName.some((l) => l.super === true),
  };
}

/**
 * Who gets the "It's a match!" push: every partner except the one whose
 * like completed the match (they already see the match screen in the app).
 */
export function matchRecipients(decision: MatchDecision, likerUid: string): string[] {
  return decision.uids.filter((uid) => uid !== likerUid);
}

export interface PushText {
  title: string;
  body: string;
}

/** Match notification text in the recipient's UI language. */
export function matchPushText(
  language: string | undefined,
  latin: string,
  geez: string,
  superLike: boolean,
): PushText {
  if (language === "am") {
    return {
      title: superLike ? "ተዛመዳችሁ! 🌟" : "ተዛመዳችሁ! 💞",
      body: `ሁለታችሁም ${geez || latin}ን ወደዳችሁት።`,
    };
  }
  const name = geez ? `${latin} · ${geez}` : latin;
  return {
    title: superLike ? "It's a super match! 🌟" : "It's a match! 💞",
    body: `You both liked ${name}.`,
  };
}
