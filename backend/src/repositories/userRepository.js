const { v4: uuidv4 } = require('uuid');
const admin = require('../config/firebase');

const db = admin.firestore();
const COLLECTION = 'users';
const { FieldValue } = admin.firestore;

const mapDoc = (snap) => (snap.exists ? { id: snap.id, ...snap.data() } : null);

const toPublicUser = (user) => {
  if (!user) return null;
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    isVerified: user.isVerified,
    profileImageUrl: user.profileImageUrl || null,
    createdAt: user.createdAt?.toDate?.()?.toISOString() ?? user.createdAt,
    updatedAt: user.updatedAt?.toDate?.()?.toISOString() ?? user.updatedAt,
  };
};

const findByEmail = async (email) => {
  const normalized = email.toLowerCase();
  const snap = await db.collection(COLLECTION).where('email', '==', normalized).limit(1).get();
  if (snap.empty) return null;
  return mapDoc(snap.docs[0]);
};

const findById = async (id) => {
  const snap = await db.collection(COLLECTION).doc(id).get();
  return mapDoc(snap);
};

const create = async ({ fullName, email, passwordHash }) => {
  const id = uuidv4();
  const now = FieldValue.serverTimestamp();
  const data = {
    fullName,
    email: email.toLowerCase(),
    password: passwordHash,
    isVerified: false,
    profileImageUrl: null,
    createdAt: now,
    updatedAt: now,
  };
  await db.collection(COLLECTION).doc(id).set(data);
  const created = await findById(id);
  return created;
};

const setVerified = async (userId) => {
  await db.collection(COLLECTION).doc(userId).update({
    isVerified: true,
    updatedAt: FieldValue.serverTimestamp(),
  });
};

const updatePassword = async (userId, passwordHash) => {
  await db.collection(COLLECTION).doc(userId).update({
    password: passwordHash,
    updatedAt: FieldValue.serverTimestamp(),
  });
};

const updateProfile = async (userId, fields) => {
  const update = { updatedAt: FieldValue.serverTimestamp() };
  if (fields.fullName !== undefined) update.fullName = fields.fullName;
  if (fields.profileImageUrl !== undefined) update.profileImageUrl = fields.profileImageUrl;
  await db.collection(COLLECTION).doc(userId).update(update);
};

module.exports = {
  findByEmail,
  findById,
  create,
  setVerified,
  updatePassword,
  updateProfile,
  toPublicUser,
};
