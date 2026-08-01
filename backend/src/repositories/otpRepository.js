const admin = require('../config/firebase');

const db = admin.firestore();
const COLLECTION = 'verificationCodes';
const { FieldValue, Timestamp } = admin.firestore;

const mapDoc = (snap) => (snap.exists ? { id: snap.id, ...snap.data() } : null);

const create = async ({ email, code, type, expiresInMinutes = 10 }) => {
  const expiresAt = Timestamp.fromDate(
    new Date(Date.now() + expiresInMinutes * 60 * 1000),
  );
  const ref = await db.collection(COLLECTION).add({
    email: email.toLowerCase(),
    code,
    type,
    expiresAt,
    createdAt: FieldValue.serverTimestamp(),
  });
  const snap = await ref.get();
  return mapDoc(snap);
};

const findLatestByEmailAndType = async (email, type) => {
  const snap = await db
    .collection(COLLECTION)
    .where('email', '==', email.toLowerCase())
    .where('type', '==', type)
    .orderBy('createdAt', 'desc')
    .limit(1)
    .get();
  if (snap.empty) return null;
  return mapDoc(snap.docs[0]);
};

const isExpired = (otp) => {
  if (!otp?.expiresAt) return true;
  const expiresAt = otp.expiresAt.toDate ? otp.expiresAt.toDate() : new Date(otp.expiresAt);
  return expiresAt.getTime() < Date.now();
};

const deleteById = async (id) => {
  await db.collection(COLLECTION).doc(id).delete();
};

module.exports = {
  create,
  findLatestByEmailAndType,
  isExpired,
  deleteById,
};
