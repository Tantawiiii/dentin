/**
 * Firebase Cloud Functions for Push Notifications
 * 
 * This function automatically sends push notifications when a new notification
 * is created in Firebase Realtime Database.
 * 
 * Setup:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login: firebase login
 * 3. Initialize: firebase init functions
 * 4. Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Triggered when a new notification is created in Realtime Database
 * Automatically sends push notification to the user
 */
exports.sendPushNotification = functions.database
        .ref('/notifications/{userId}/{notificationId}')
        .onCreate(async (snapshot, context) => {
                const notification = snapshot.val();
                const userId = context.params.userId;
                const notificationId = context.params.notificationId;

                console.log(`📨 New notification created for user ${userId}: ${notificationId}`);

                try {
                        // Get user's FCM tokens from Realtime Database
                        const userTokensRef = admin.database().ref(`users/${userId}/fcm_tokens`);
                        const tokensSnapshot = await userTokensRef.once('value');

                        if (!tokensSnapshot.exists()) {
                                console.log(`⚠️ No FCM tokens found for user ${userId}`);
                                return null;
                        }

                        const tokensData = tokensSnapshot.val();
                        const fcmTokens = Object.keys(tokensData);

                        if (fcmTokens.length === 0) {
                                console.log(`⚠️ No FCM tokens available for user ${userId}`);
                                return null;
                        }

                        // Prepare notification payload
                        const notificationPayload = {
                                notification: {
                                        title: notification.title || 'New Notification',
                                        body: notification.message || '',
                                        sound: 'default',
                                },
                                data: {
                                        type: notification.type || '',
                                        notification_id: notificationId,
                                        sender_id: String(notification.sender_id || ''),
                                        sender_name: notification.sender_name || '',
                                        sender_image: notification.sender_image || '',
                                        post_id: notification.post_id ? String(notification.post_id) : '',
                                        comment_id: notification.comment_id || '',
                                        reply_id: notification.reply_id || '',
                                        timestamp: String(notification.timestamp || Date.now()),
                                },
                                android: {
                                        priority: 'high',
                                        notification: {
                                                sound: 'default',
                                                channelId: 'default',
                                                priority: 'high',
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

                        // Send push notification to all user's devices
                        const responses = await admin.messaging().sendToDevice(fcmTokens, notificationPayload);

                        // Check for failures
                        const failedTokens = [];
                        responses.results.forEach((result, index) => {
                                if (result.error) {
                                        console.error(`❌ Failed to send to token ${fcmTokens[index]}:`, result.error);
                                        if (
                                                result.error.code === 'messaging/invalid-registration-token' ||
                                                result.error.code === 'messaging/registration-token-not-registered'
                                        ) {
                                                failedTokens.push(fcmTokens[index]);
                                        }
                                } else {
                                        console.log(`✅ Successfully sent to token ${fcmTokens[index]}`);
                                }
                        });

                        // Remove invalid tokens
                        if (failedTokens.length > 0) {
                                const removePromises = failedTokens.map((token) =>
                                        userTokensRef.child(token).remove()
                                );
                                await Promise.all(removePromises);
                                console.log(`🗑️ Removed ${failedTokens.length} invalid FCM tokens`);
                        }

                        console.log(`✅ Push notification sent to ${fcmTokens.length} device(s) for user ${userId}`);
                        return null;
                } catch (error) {
                        console.error(`❌ Error sending push notification:`, error);
                        return null;
                }
        });

