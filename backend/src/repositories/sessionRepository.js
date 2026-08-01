const admin = require('../config/firebase');

const db = admin.firestore();
const COLLECTION = 'sessions';
const { FieldValue, Timestamp } = admin.firestore;

const mapDoc = (snap) => (snap.exists ? { id: snap.id, ...snap.data() } : null);

const create = async ({ userId, refreshTokenHash, deviceInfo, expiresInDays = 7 }) => {
  const expiresAt = Timestamp.fromDate(
    new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000),
  );
  const ref = await db.collection(COLLECTION).add({
    userId,
    refreshTokenHash,
    deviceInfo: deviceInfo || null,
    expiresAt,
    createdAt: FieldValue.serverTimestamp(),
  });
  const snap = await ref.get();
  return mapDoc(snap);
};

const findByUserAndHash = async (userId, refreshTokenHash) => {
  const snap = await db.collection(COLLECTION).where('userId', '==', userId).get();
  const match = snap.docs.find((doc) => doc.data().refreshTokenHash === refreshTokenHash);
  return match ? mapDoc(match) : null;
};

const isExpired = (session) => {
  if (!session?.expiresAt) return true;
  const expiresAt = session.expiresAt.toDate
    ? session.expiresAt.toDate()
    : new Date(session.expiresAt);
  return expiresAt.getTime() < Date.now();
};

const deleteById = async (id) => {
  await db.collection(COLLECTION).doc(id).delete();
};

const deleteAllForUser = async (userId) => {
  const snap = await db.collection(COLLECTION).where('userId', '==', userId).get();
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.delete(doc.ref));
  if (!snap.empty) await batch.commit();
};

const deleteAllForUserExcept = async (userId, exceptSessionId) => {
  const snap = await db.collection(COLLECTION).where('userId', '==', userId).get();
  const batch = db.batch();
  snap.docs.forEach((doc) => {
    if (doc.id !== exceptSessionId) batch.delete(doc.ref);
  });
  if (snap.docs.some((doc) => doc.id !== exceptSessionId)) await batch.commit();
};

module.exports = {
  create,
  findByUserAndHash,
  isExpired,
  deleteById,
  deleteAllForUser,
  deleteAllForUserExcept,
};
