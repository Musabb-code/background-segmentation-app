const admin = require('../config/firebase');

const uploadProfileImage = async (userId, buffer, contentType) => {
  const path = `profile-images/${userId}/avatar.jpg`;
  const b = admin.storage().bucket();
  const file = b.file(path);
  await file.save(buffer, { metadata: { contentType }, resumable: false });
  await file.makePublic();
  return `https://storage.googleapis.com/${b.name}/${path}`;
};

module.exports = {
  uploadProfileImage,
};
