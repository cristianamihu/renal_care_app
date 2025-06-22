const admin = require("firebase-admin");
admin.initializeApp();

// import trigger-ul v2 din sub-modulul firestore
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.onNewMessage = onDocumentCreated(
  "chat_rooms/{roomId}/messages/{msgId}",
  async (event) => {
    const msg = event.data; // datele din mesaj
    const roomId = event.params.roomId; // parametrii din cale
    console.log("▶ onNewMessage triggered for room:", roomId, "msg:", msg);

    // citește documentul camerei
    const roomSnap = await admin
      .firestore()
      .doc(`chat_rooms/${roomId}`)
      .get();
      console.log("→ roomSnap.exists:", roomSnap.exists);
    if (!roomSnap.exists) {
      console.log("⚠️ room not found, aborting");
      return null;
    }
    const room = roomSnap.data();
    console.log("→ room.data():", room); 

    // găsește UID-ul celuilalt
    const targetUid = (room.participants || []).find((u) => u !== msg.senderId);
    console.log("→ targetUid:", targetUid);
    if (!targetUid) {
      console.log("⚠️ no target user, aborting");
      return null;
    }

    // Citește toate token-urile din subcolecția fcm_tokens
    const tokensSnap = await admin
      .firestore()
      .collection("users")
      .doc(targetUid)
      .collection("fcm_tokens")
      .get();

    // Extrage doar valoarea `token` din fiecare document fcm_tokens/{tokenId}
    const fcmTokens = tokensSnap.docs.map((doc) => doc.data().token).filter((t) => !!t);
    console.log("→ fcmTokens:", fcmTokens);
    if (fcmTokens.length === 0) {
      console.log("⚠️ No FCM tokens, skipping");
      return null;
    }

    // Citește name-ul user-ului (opțional, pentru titlul notificării)
    const userSnap = await admin.firestore().doc(`users/${targetUid}`).get();
    const userName = userSnap.data()?.name || "New message";
    console.log("→ userName:", userName); 

    const payload = {
      notification: {
        title:userName,
        body:  msg.text  || "You have an attachment.",
      },
      data: { roomId },
    };
    console.log("→ sending payload:", payload);

    // trimite notificările cu sendEachForMulticast (înlocuiește sendMulticast)
    try {
      const batchResponse = await admin.messaging().sendEachForMulticast({
        tokens: fcmTokens,
        notification: payload.notification,
        data: payload.data,
      });

      console.log(
        `✅ sendEachForMulticast: ${batchResponse.successCount} succeeded, ${batchResponse.failureCount} failed`
      );
      batchResponse.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`   • token[${idx}] error:`, resp.error);
        }
      });
    } catch (err) {
      console.error("❌ sendEachForMulticast error:", err);
      throw err;
    }

    return null;
  }
);