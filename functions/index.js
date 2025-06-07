const admin = require("firebase-admin");
admin.initializeApp();

// import trigger-ul v2 din sub-modulul firestore
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.onNewMessage = onDocumentCreated(
  "chat_rooms/{roomId}/messages/{msgId}",
  async (event) => {
    const msg = event.data; // datele din mesaj
    const roomId = event.params.roomId; // parametrii din cale

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

    // Citește toate token-urile din subcolecția fcm_tokens
    const tokensSnap = await admin
      .firestore()
      .collection("users")
      .doc(targetUid)
      .collection("fcm_tokens")
      .get();

    // Extrage doar valoarea `token` din fiecare document fcm_tokens/{tokenId}
    const fcmTokens = tokensSnap.docs
      .map((doc) => doc.data().token)
      .filter((t) => !!t);
    if (fcmTokens.length === 0) return null;

    // Citește name-ul user-ului (opțional, pentru titlul notificării)
    const userSnap = await admin.firestore().doc(`users/${targetUid}`).get();
    const userName = userSnap.data()?.name || "Mesaj nou";

    const payload = {
      notification: {
        title:userName,
        body:  msg.text  || "Ai un atașament",
      },
      data: { roomId },
    };

    return admin.messaging().sendToDevice(fcmTokens, payload);
  }
);
