import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { decideMatch, Like } from "./match";
import {
  addisDate,
  computeTrendUpdates,
  countLikes,
  LikeRef,
  NameRow,
  pickNameOfTheDay,
} from "./trends";

initializeApp();

/**
 * When a partner likes a name, check whether the other partner already
 * liked it too. If so, write couples/{code}/matches/{nameId}.
 *
 * Idempotent: the match doc id is the name id and is written with
 * `create()`, so two near-simultaneous likes produce one match.
 */
export const onSwipe = onDocumentCreated(
  { document: "couples/{code}/likes/{likeId}", region: "europe-west1" },
  async (event) => {
    const like = event.data?.data() as Like | undefined;
    if (!like?.uid || !like.name_id) return;

    const db = getFirestore();
    const { code } = event.params;
    const couple = await db.doc(`couples/${code}`).get();
    const members = (couple.get("members") as string[] | undefined) ?? [];

    const likes = await db
      .collection(`couples/${code}/likes`)
      .where("name_id", "==", like.name_id)
      .get();

    const decision = decideMatch(
      members,
      likes.docs.map((d) => d.data() as Like),
      like.name_id,
    );
    if (!decision) return;

    try {
      await db.doc(`couples/${code}/matches/${like.name_id}`).create({
        ...decision,
        created_at: FieldValue.serverTimestamp(),
      });
      logger.info("New match", { code, name: like.name_id });
    } catch (error: unknown) {
      // 6 = ALREADY_EXISTS: the other partner's like got there first.
      if ((error as { code?: number }).code !== 6) throw error;
    }
  },
);

// ---------------------------------------------------------------------------
// Scheduled jobs
// ---------------------------------------------------------------------------

const REGION = "europe-west1";
const TIME_ZONE = "Africa/Addis_Ababa";
const BATCH_LIMIT = 450;

/**
 * Daily: count likes from the last 7 days (favorites + partner likes, one per
 * person per name), then write trend_score and rarity to names/{id}.
 * Only changed names are written, and their updated_at is bumped so devices
 * pick them up in their next incremental sync.
 */
export const updateTrends = onSchedule(
  { schedule: "every day 03:00", timeZone: TIME_ZONE, region: REGION },
  async () => {
    const db = getFirestore();
    const since = Timestamp.fromMillis(Date.now() - 7 * 86_400_000);

    const [favorites, partnerLikes, names] = await Promise.all([
      db.collectionGroup("favorites").where("created_at", ">=", since).get(),
      db.collectionGroup("likes").where("created_at", ">=", since).get(),
      db.collection("names").get(),
    ]);

    const likes: LikeRef[] = [
      ...favorites.docs
        .filter((d) => d.get("deleted") !== true)
        // users/{uid}/favorites/{nameId}
        .map((d) => ({ uid: d.ref.parent.parent?.id ?? "", name_id: d.id })),
      ...partnerLikes.docs.map((d) => ({
        uid: String(d.get("uid") ?? ""),
        name_id: String(d.get("name_id") ?? ""),
      })),
    ];

    const rows: NameRow[] = names.docs
      .filter((d) => d.get("deleted") !== true)
      .map((d) => ({
        id: d.id,
        popularity: Number(d.get("popularity") ?? 0),
        trend_score: Number(d.get("trend_score") ?? 0),
        rarity: d.get("rarity") as string | undefined,
      }));

    const updates = computeTrendUpdates(rows, countLikes(likes));
    for (let i = 0; i < updates.length; i += BATCH_LIMIT) {
      const batch = db.batch();
      for (const u of updates.slice(i, i + BATCH_LIMIT)) {
        batch.update(db.doc(`names/${u.id}`), {
          trend_score: u.trend_score,
          rarity: u.rarity,
          updated_at: FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    logger.info("Trends updated", { likes: likes.length, changed: updates.length });
  },
);

/**
 * 06:00 Addis Ababa: writes daily/{yyyy-mm-dd} and notifies topic
 * `daily_name` (bilingual title/body; data carries the name id).
 */
export const nameOfTheDay = onSchedule(
  { schedule: "every day 06:00", timeZone: TIME_ZONE, region: REGION },
  async () => {
    const db = getFirestore();
    const names = await db.collection("names").get();
    const pool = names.docs
      .filter((d) => d.get("deleted") !== true)
      .map((d) => ({ id: d.id, ...d.data() }) as { id: string } & Record<string, unknown>);

    const now = new Date();
    const date = addisDate(now);
    const pick = pickNameOfTheDay(pool, new Date(`${date}T00:00:00Z`));
    if (!pick) return;

    const latin = String(pick.name_latin ?? "");
    const geez = String(pick.name_geez ?? "");
    const meaningEn = String(pick.meaning_en ?? "");
    const meaningAm = String(pick.meaning_am ?? "");

    await db.doc(`daily/${date}`).set({
      date,
      name_id: pick.id,
      name_latin: latin,
      name_geez: geez,
      meaning_en: meaningEn,
      meaning_am: meaningAm,
      created_at: FieldValue.serverTimestamp(),
    });

    await getMessaging().send({
      topic: "daily_name",
      notification: {
        title: `Name of the day · የዕለቱ ስም: ${latin} · ${geez}`,
        body: [meaningEn, meaningAm].filter(Boolean).join(" · "),
      },
      data: { type: "daily_name", name_id: pick.id, date },
    });
    logger.info("Name of the day sent", { date, name: pick.id });
  },
);
