// functions/index.js
const admin = require("firebase-admin");
admin.initializeApp();

// import trigger-ul v2 din sub-modulul firestore
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.onNewMessage = onDocumentCreated(
  "chat_rooms/{roomId}/messages/{msgId}",
  async (event) => {
    const msg    = event.data;             // datele din mesaj
    const roomId = event.params.roomId;     // parametrii din cale

    // citește documentul camerei
    const roomSnap = await admin
      .firestore()
      .doc(`chat_rooms/${roomId}`)
      .get();
    if (!roomSnap.exists) return null;
    const room = roomSnap.data();

    // găsește UID-ul celuilalt
    const targetUid = (room.participants || [])
      .find((u) => u !== msg.senderId);
    if (!targetUid) return null;

    // ia token-ul FCM
    const userSnap = await admin.firestore().doc(`users/${targetUid}`).get();
    const token    = userSnap.data()?.fcmToken;
    if (!token) return null;

    const payload = {
      notification: {
        title: userSnap.data()?.name || "Mesaj nou",
        body:  msg.text  || "Ai un atașament",
      },
      data: { roomId },
    };

    return admin.messaging().sendToDevice(token, payload);
  }
);
