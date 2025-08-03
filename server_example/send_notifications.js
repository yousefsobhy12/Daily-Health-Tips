// Example Node.js script to send personalized notifications
// This demonstrates how to send notifications to different user groups

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// You need to download your service account key from Firebase Console
const serviceAccount = require('./path-to-your-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Function to send notification to a specific topic
async function sendNotificationToTopic(topic, title, body, data = {}) {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data,
      topic: topic,
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.log('Error sending message:', error);
    throw error;
  }
}

// Function to send notification to specific user
async function sendNotificationToUser(userId, title, body, data = {}) {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data,
      topic: `user_${userId}`,
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message to user:', response);
    return response;
  } catch (error) {
    console.log('Error sending message to user:', error);
    throw error;
  }
}

// Example: Send daily health tip to users with "lose weight" goal
async function sendDailyWeightLossTip() {
  const tip = {
    title: "Daily Weight Loss Tip",
    body: "Start your day with a protein-rich breakfast to boost metabolism and reduce cravings throughout the day.",
    data: {
      tipId: "4",
      category: "nutrition",
      goal: "lose_weight"
    }
  };

  await sendNotificationToTopic('goal_lose_weight', tip.title, tip.body, tip.data);
}

// Example: Send exercise tip to users aged 26-35
async function sendExerciseTipForAgeGroup() {
  const tip = {
    title: "Fitness Tip for You",
    body: "Try high-intensity interval training (HIIT) for maximum fat burning in minimum time.",
    data: {
      tipId: "2",
      category: "exercise",
      ageGroup: "26_35"
    }
  };

  await sendNotificationToTopic('age_26_35', tip.title, tip.body, tip.data);
}

// Example: Send personalized tip to specific user
async function sendPersonalizedTip(userId, userName, userGoal) {
  const tip = {
    title: `Hello ${userName}!`,
    body: `Here's your personalized tip for ${userGoal}: Stay hydrated and drink 8-10 glasses of water daily.`,
    data: {
      tipId: "1",
      category: "nutrition",
      personalized: "true"
    }
  };

  await sendNotificationToUser(userId, tip.title, tip.body, tip.data);
}

// Example: Send notification at scheduled time
async function sendScheduledNotification() {
  const currentHour = new Date().getHours();
  
  // Send different tips based on time of day
  if (currentHour >= 6 && currentHour < 12) {
    // Morning tip
    await sendNotificationToTopic('goal_stay_healthy', 
      "Good Morning! 🌅", 
      "Start your day with 10 minutes of stretching to boost energy and flexibility.",
      { tipId: "morning_1", category: "exercise" }
    );
  } else if (currentHour >= 12 && currentHour < 18) {
    // Afternoon tip
    await sendNotificationToTopic('goal_stay_healthy',
      "Afternoon Boost! ☀️",
      "Take a 5-minute walk to refresh your mind and improve productivity.",
      { tipId: "afternoon_1", category: "mental_health" }
    );
  } else {
    // Evening tip
    await sendNotificationToTopic('goal_stay_healthy',
      "Evening Wellness! 🌙",
      "Practice 10 minutes of meditation before bed for better sleep quality.",
      { tipId: "evening_1", category: "sleep" }
    );
  }
}

// Example: Send category-specific tips
async function sendCategoryTips() {
  const categories = [
    {
      topic: 'nutrition',
      title: 'Nutrition Tip',
      body: 'Include more vegetables in your meals for better health and weight management.',
      data: { tipId: "nutrition_1", category: "nutrition" }
    },
    {
      topic: 'exercise',
      title: 'Exercise Tip',
      body: 'Aim for 150 minutes of moderate exercise per week for optimal health.',
      data: { tipId: "exercise_1", category: "exercise" }
    },
    {
      topic: 'mental_health',
      title: 'Mental Health Tip',
      body: 'Practice gratitude daily - write down 3 things you\'re thankful for.',
      data: { tipId: "mental_1", category: "mental_health" }
    },
    {
      topic: 'sleep',
      title: 'Sleep Tip',
      body: 'Create a consistent bedtime routine to improve sleep quality.',
      data: { tipId: "sleep_1", category: "sleep" }
    }
  ];

  for (const category of categories) {
    await sendNotificationToTopic(category.topic, category.title, category.body, category.data);
  }
}

// Main function to run examples
async function main() {
  try {
    console.log('Sending personalized notifications...');
    
    // Send different types of notifications
    await sendDailyWeightLossTip();
    await sendExerciseTipForAgeGroup();
    await sendPersonalizedTip('user123', 'John', 'lose weight');
    await sendScheduledNotification();
    await sendCategoryTips();
    
    console.log('All notifications sent successfully!');
  } catch (error) {
    console.error('Error in main function:', error);
  }
}

// Run the examples
if (require.main === module) {
  main();
}

module.exports = {
  sendNotificationToTopic,
  sendNotificationToUser,
  sendDailyWeightLossTip,
  sendExerciseTipForAgeGroup,
  sendPersonalizedTip,
  sendScheduledNotification,
  sendCategoryTips
}; 