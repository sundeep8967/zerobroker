const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Timestamp } = require('firebase-admin/firestore');

admin.initializeApp();

// Payment verification function
exports.verifyPayment = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { paymentId, propertyId, amount } = data;
  const userId = context.auth.uid;

  try {
    // Verify payment with Razorpay (in production, add actual verification)
    // For now, we'll simulate successful payment verification
    
    // Check if user already unlocked this property
    const existingUnlock = await admin.firestore()
      .collection('unlocks')
      .where('userId', '==', userId)
      .where('propertyId', '==', propertyId)
      .get();

    if (!existingUnlock.empty) {
      throw new functions.https.HttpsError('already-exists', 'Contact already unlocked');
    }

    // Create unlock record
    const unlockData = {
      userId,
      propertyId,
      paymentId,
      amount,
      unlockedAt: Timestamp.now(),
      verified: true
    };

    await admin.firestore().collection('unlocks').add(unlockData);

    // Update property unlock count
    await admin.firestore()
      .collection('properties')
      .doc(propertyId)
      .update({
        unlocks: admin.firestore.FieldValue.increment(1)
      });

    // Send notification to property owner
    await sendNotificationToPropertyOwner(propertyId, userId);

    return { success: true, unlockId: unlockData.id };
  } catch (error) {
    console.error('Payment verification failed:', error);
    throw new functions.https.HttpsError('internal', 'Payment verification failed');
  }
});

// Send notification when new property is added
exports.onPropertyCreated = functions.firestore
  .document('properties/{propertyId}')
  .onCreate(async (snap, context) => {
    const property = snap.data();
    const propertyId = context.params.propertyId;

    try {
      // Find users with matching preferences
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where('isActive', '==', true)
        .get();

      const notifications = [];
      
      usersSnapshot.forEach(userDoc => {
        const user = userDoc.data();
        
        // Check if property matches user preferences
        if (shouldNotifyUser(user, property)) {
          notifications.push({
            userId: userDoc.id,
            type: 'new_property',
            title: 'New Property Available!',
            body: `${property.title} in ${property.location.address}`,
            data: {
              propertyId,
              type: 'property'
            },
            createdAt: Timestamp.now(),
            read: false
          });
        }
      });

      // Batch write notifications
      if (notifications.length > 0) {
        const batch = admin.firestore().batch();
        notifications.forEach(notification => {
          const notificationRef = admin.firestore().collection('notifications').doc();
          batch.set(notificationRef, notification);
        });
        await batch.commit();

        // Send push notifications
        await sendPushNotifications(notifications);
      }

      console.log(`Sent ${notifications.length} notifications for new property ${propertyId}`);
    } catch (error) {
      console.error('Error sending property notifications:', error);
    }
  });

// Auto-expire old listings
exports.expireOldListings = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    try {
      const expiredProperties = await admin.firestore()
        .collection('properties')
        .where('isActive', '==', true)
        .where('createdAt', '<', Timestamp.fromDate(thirtyDaysAgo))
        .get();

      const batch = admin.firestore().batch();
      
      expiredProperties.forEach(doc => {
        batch.update(doc.ref, {
          isActive: false,
          expiredAt: Timestamp.now(),
          expiredReason: 'auto_expired_30_days'
        });
      });

      await batch.commit();
      console.log(`Expired ${expiredProperties.size} old properties`);
    } catch (error) {
      console.error('Error expiring old listings:', error);
    }
  });

// Generate analytics data
exports.generateAnalytics = functions.pubsub
  .schedule('0 1 * * *') // Run daily at 1 AM
  .onRun(async (context) => {
    try {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      // Get daily stats
      const [propertiesSnapshot, usersSnapshot, unlocksSnapshot] = await Promise.all([
        admin.firestore().collection('properties').get(),
        admin.firestore().collection('users').get(),
        admin.firestore()
          .collection('unlocks')
          .where('unlockedAt', '>=', Timestamp.fromDate(yesterday))
          .where('unlockedAt', '<', Timestamp.fromDate(today))
          .get()
      ]);

      const analytics = {
        date: Timestamp.fromDate(yesterday),
        totalProperties: propertiesSnapshot.size,
        activeProperties: propertiesSnapshot.docs.filter(doc => doc.data().isActive).length,
        totalUsers: usersSnapshot.size,
        activeUsers: usersSnapshot.docs.filter(doc => doc.data().isActive).length,
        dailyUnlocks: unlocksSnapshot.size,
        dailyRevenue: unlocksSnapshot.docs.reduce((sum, doc) => sum + (doc.data().amount || 0), 0),
        generatedAt: Timestamp.now()
      };

      await admin.firestore()
        .collection('analytics')
        .doc(yesterday.toISOString().split('T')[0])
        .set(analytics);

      console.log('Analytics generated for', yesterday.toISOString().split('T')[0]);
    } catch (error) {
      console.error('Error generating analytics:', error);
    }
  });

// Helper functions
async function sendNotificationToPropertyOwner(propertyId, interestedUserId) {
  try {
    const propertyDoc = await admin.firestore()
      .collection('properties')
      .doc(propertyId)
      .get();

    if (!propertyDoc.exists) return;

    const property = propertyDoc.data();
    const ownerId = property.ownerId;

    const notification = {
      userId: ownerId,
      type: 'contact_unlocked',
      title: 'Someone unlocked your contact!',
      body: `A user is interested in ${property.title}`,
      data: {
        propertyId,
        interestedUserId,
        type: 'unlock'
      },
      createdAt: Timestamp.now(),
      read: false
    };

    await admin.firestore().collection('notifications').add(notification);
  } catch (error) {
    console.error('Error sending notification to property owner:', error);
  }
}

function shouldNotifyUser(user, property) {
  // Check if user has preferences that match the property
  const preferences = user.preferences || {};
  
  // Check price range
  if (preferences.maxRent && property.rent > preferences.maxRent) {
    return false;
  }
  
  if (preferences.minRent && property.rent < preferences.minRent) {
    return false;
  }
  
  // Check property type
  if (preferences.propertyTypes && preferences.propertyTypes.length > 0) {
    if (!preferences.propertyTypes.includes(property.propertyType)) {
      return false;
    }
  }
  
  // Check location preferences
  if (preferences.preferredAreas && preferences.preferredAreas.length > 0) {
    const propertyArea = property.location.address.toLowerCase();
    const hasMatchingArea = preferences.preferredAreas.some(area => 
      propertyArea.includes(area.toLowerCase())
    );
    if (!hasMatchingArea) {
      return false;
    }
  }
  
  return true;
}

async function sendPushNotifications(notifications) {
  try {
    // Group notifications by user
    const userNotifications = {};
    notifications.forEach(notification => {
      if (!userNotifications[notification.userId]) {
        userNotifications[notification.userId] = [];
      }
      userNotifications[notification.userId].push(notification);
    });

    // Send push notifications to each user
    const pushPromises = Object.entries(userNotifications).map(async ([userId, userNotifs]) => {
      try {
        // Get user's FCM tokens
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();
        
        if (!userData || !userData.fcmTokens || userData.fcmTokens.length === 0) {
          return;
        }

        // Send to all user's devices
        const messages = userData.fcmTokens.map(token => ({
          token,
          notification: {
            title: userNotifs[0].title,
            body: userNotifs[0].body,
          },
          data: userNotifs[0].data,
          android: {
            notification: {
              icon: 'ic_notification',
              color: '#007AFF',
              sound: 'default',
            },
          },
          apns: {
            payload: {
              aps: {
                badge: userNotifs.length,
                sound: 'default',
              },
            },
          },
        }));

        await admin.messaging().sendAll(messages);
      } catch (error) {
        console.error(`Error sending push notification to user ${userId}:`, error);
      }
    });

    await Promise.all(pushPromises);
  } catch (error) {
    console.error('Error sending push notifications:', error);
  }
}