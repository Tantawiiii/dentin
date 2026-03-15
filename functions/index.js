/**
 * Firebase Cloud Functions for Push Notifications
 *
 * Triggered when a new notification document is created at:
 *   /notifications/{userId}/{notificationId}
 *
 * It reads the recipient's FCM tokens from:
 *   /users/{userId}/fcm_tokens/{tokenHash}  → { token: "...", ... }
 *
 * and sends a push notification via the modern sendEachForMulticast API.
 *
 * Deploy:
 *   firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendPushNotification = functions.database
  .ref('/notifications/{userId}/{notificationId}')
  .onCreate(async (snapshot, context) => {
    const notification = snapshot.val();
    const { userId, notificationId } = context.params;

    console.log(`📨 New notification for user ${userId}: ${notificationId}`);

    try {
      // ── 1. Fetch FCM tokens ────────────────────────────────────────────────
      const tokensSnap = await admin
        .database()
        .ref(`users/${userId}/fcm_tokens`)
        .once('value');

      if (!tokensSnap.exists()) {
        console.log(`⚠️  No FCM tokens for user ${userId}`);
        return null;
      }

      const tokensData = tokensSnap.val(); // { <hash>: { token: "...", ... }, ... }

      // Extract the actual token strings from each child object
      const fcmTokens = Object.values(tokensData)
        .map((entry) => (entry && entry.token ? entry.token : null))
        .filter(Boolean);

      if (fcmTokens.length === 0) {
        console.log(`⚠️  All FCM token entries are empty for user ${userId}`);
        return null;
      }

      // ── 2. Build the MulticastMessage ──────────────────────────────────────
      const message = {
        tokens: fcmTokens,

        notification: {
          title: notification.title || 'New Notification',
          body: notification.message || '',
        },

        // Structured data for deep-linking in the Flutter app
        data: {
          type: String(notification.type || ''),
          notification_id: notificationId,
          sender_id: String(notification.sender_id || ''),
          sender_name: String(notification.sender_name || ''),
          sender_image: String(notification.sender_image || ''),
          post_id: notification.post_id != null ? String(notification.post_id) : '',
          comment_id: String(notification.comment_id || ''),
          reply_id: String(notification.reply_id || ''),
          timestamp: String(notification.timestamp || Date.now()),
        },

        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'dentin_notifications',
            priority: 'high',
            defaultVibrateTimings: true,
          },
        },

        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              contentAvailable: true,
            },
          },
          headers: {
            'apns-priority': '10',
          },
        },
      };

      // ── 3. Send and handle partial failures ───────────────────────────────
      const response = await admin.messaging().sendEachForMulticast(message);

      console.log(
        `✅ Sent: ${response.successCount}  ❌ Failed: ${response.failureCount}`
      );

      // Remove invalid / expired tokens
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const code = resp.error && resp.error.code;
          console.error(`Token[${idx}] error: ${code}`);
          if (
            code === 'messaging/invalid-registration-token' ||
            code === 'messaging/registration-token-not-registered'
          ) {
            invalidTokens.push(fcmTokens[idx]);
          }
        }
      });

      if (invalidTokens.length > 0) {
        // Find and remove the stale token entries from the DB
        const allEntries = Object.entries(tokensData);
        const removeOps = invalidTokens.map((badToken) => {
          const entry = allEntries.find(([, v]) => v && v.token === badToken);
          if (entry) {
            return admin
              .database()
              .ref(`users/${userId}/fcm_tokens/${entry[0]}`)
              .remove();
          }
          return Promise.resolve();
        });
        await Promise.all(removeOps);
        console.log(`🗑️  Removed ${invalidTokens.length} stale FCM token(s)`);
      }

      return null;
    } catch (error) {
      console.error('❌ Error sending push notification:', error);
      return null;
    }
  });
/**
 * Broadcast Notification Trigger
 *
 * Triggered when a new record is created at:
 *   /broadcasts/{broadcastId}
 *
 * Useful for promotions, news, or new features. It sends to the 
 * 'announcements' topic which all users subscribe to on app start.
 */
exports.sendBroadcastNotification = functions.database
  .ref('/broadcasts/{broadcastId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.val();

    console.log(`📣 Sending broadcast: ${data.title}`);

    const message = {
      topic: 'announcements',
      notification: {
        title: data.title || 'New Update!',
        body: data.body || data.message || '',
      },
      data: {
        type: 'promotion',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'dentin_notifications',
          priority: 'high',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('✅ Broadcast sent successfully:', response);
      return null;
    } catch (error) {
      console.error('❌ Error sending broadcast:', error);
      return null;
    }
  });
