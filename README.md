# Daily Health Tips - Flutter App

A Flutter application that provides personalized daily health tips using Firebase Cloud Messaging (FCM) for push notifications.

## Features

🔔 **Personalized Daily Health Tips**

- Receive health tips tailored to your age and fitness goals
- Tips are categorized by nutrition, exercise, mental health, and sleep
- Different tips for different age groups and goals

📱 **Cross-Platform Support**

- Works on both Android and iOS
- Beautiful Material Design 3 UI
- Responsive design

⚙️ **Customizable Notifications**

- Set your preferred notification time
- Enable/disable notifications
- Personalized notification scheduling

🎯 **Goal-Based Recommendations**

- Lose weight tips
- Get fit recommendations
- Stay healthy advice
- Age-appropriate content

## Prerequisites

Before running this app, you need:

1. **Flutter SDK** (version 3.8.1 or higher)
2. **Firebase Project** with Cloud Messaging enabled
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Physical device** or **emulator** for testing

## Setup Instructions

### 1. Firebase Setup

1. **Create a Firebase Project:**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Cloud Messaging:**

   - In your Firebase project, go to "Messaging" in the left sidebar
   - Click "Get started"
   - Follow the setup instructions

3. **Add Android App:**

   - In Firebase Console, click the Android icon
   - Use package name: `com.example.daily_health_tips`
   - Download `google-services.json` and place it in `android/app/`

4. **Add iOS App (if needed):**
   - In Firebase Console, click the iOS icon
   - Use bundle ID: `com.example.dailyHealthTips`
   - Download `GoogleService-Info.plist` and add it to your iOS project

### 2. Update Firebase Configuration

1. **Update `lib/firebase_options.dart`:**

   - Replace all placeholder values with your actual Firebase project configuration
   - You can get these values from your Firebase Console

2. **Android Configuration:**

   - Ensure `google-services.json` is in `android/app/`
   - The file is already referenced in `android/app/build.gradle.kts`

3. **iOS Configuration (if needed):**
   - Add `GoogleService-Info.plist` to your iOS project
   - Update the bundle identifier in Xcode

### 3. Install Dependencies

Run the following command to install all required dependencies:

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── user_profile.dart     # User profile and health tip models
├── services/
│   ├── fcm_service.dart      # Firebase Cloud Messaging service
│   ├── health_tips_service.dart  # Health tips management
│   └── user_profile_service.dart # User profile management
└── screens/
    ├── profile_setup_screen.dart  # Initial profile setup
    ├── home_screen.dart      # Main app screen
    └── settings_screen.dart  # Settings and preferences
```

## Key Components

### FCM Service (`lib/services/fcm_service.dart`)

- Handles Firebase Cloud Messaging setup
- Manages notification permissions
- Handles foreground and background messages
- Topic subscription for personalized notifications

### Health Tips Service (`lib/services/health_tips_service.dart`)

- Contains sample health tips data
- Filters tips based on user age and goals
- Provides personalized recommendations

### User Profile Service (`lib/services/user_profile_service.dart`)

- Manages user profile data
- Handles local storage with SharedPreferences
- Manages notification preferences

## Sending Personalized Notifications

To send personalized notifications to users, you can use Firebase Cloud Messaging with topics:

### Topic-Based Notifications

Users are automatically subscribed to topics based on their profile:

- `user_{userId}` - User-specific notifications
- `goal_{goalName}` - Goal-based notifications (e.g., `goal_lose_weight`)
- `age_{ageGroup}` - Age group notifications (e.g., `age_26_35`)

### Example FCM Message

```json
{
  "to": "/topics/goal_lose_weight",
  "notification": {
    "title": "Daily Health Tip",
    "body": "Stay hydrated! Drink 8-10 glasses of water daily to boost metabolism."
  },
  "data": {
    "tipId": "1",
    "category": "nutrition"
  }
}
```

## Customization

### Adding New Health Tips

1. Edit `lib/services/health_tips_service.dart`
2. Add new `HealthTip` objects to the `_healthTips` list
3. Specify target goals and age groups

### Modifying Notification Schedule

1. Users can set their preferred time in the app
2. For server-side scheduling, implement a Cloud Function
3. Use the user's `notificationTime` preference

### Styling

The app uses Material Design 3 with a green theme. You can customize colors in `lib/main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.green,
  useMaterial3: true,
  // ... other theme settings
),
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized:**

   - Ensure `firebase_options.dart` has correct configuration
   - Check that `google-services.json` is in the right location

2. **Notifications not working:**

   - Verify notification permissions are granted
   - Check FCM token is generated correctly
   - Ensure device is connected to internet

3. **Build errors:**
   - Run `flutter clean` and `flutter pub get`
   - Check all dependencies are compatible

### Debug Mode

Enable debug logging by checking the console output for:

- FCM token generation
- Topic subscription status
- Notification delivery

## Future Enhancements

- [ ] Server-side notification scheduling
- [ ] More health tips categories
- [ ] User progress tracking
- [ ] Social sharing features
- [ ] Offline tip storage
- [ ] Analytics integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue in this repository
- Check Firebase documentation for FCM setup
- Refer to Flutter documentation for app development
