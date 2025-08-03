# Daily Health Tips App

A Flutter application that sends personalized daily health tips using Firebase Cloud Messaging (FCM). The app provides users with customized health advice based on their age, fitness goals, and preferences.

## 🌟 Features

### Core Features

- **Personalized Health Tips**: Get health advice tailored to your age and fitness goals
- **Firebase Cloud Messaging**: Push notifications for daily health tips
- **Cross-Platform**: Works on both Android and iOS
- **User Profiles**: Customizable user profiles with age, goals, and notification preferences
- **Local Notifications**: In-app notifications when the app is in foreground
- **Notification Scheduling**: Set daily notification times (e.g., 9 AM)

### User Experience

- **Clean Material Design 3 UI**: Modern and intuitive interface
- **Custom Widgets**: Modular and reusable UI components
- **Profile Setup**: Easy onboarding with guided profile creation
- **Settings Management**: Comprehensive settings screen for user preferences
- **Real-time Updates**: Dynamic content updates and refresh functionality

## 🏗️ Architecture

### Project Structure

```
lib/
├── models/
│   └── user_profile.dart          # User profile and health tip data models
├── services/
│   ├── fcm_service.dart           # Firebase Cloud Messaging service
│   ├── health_tips_service.dart   # Health tips management service
│   └── user_profile_service.dart  # User profile storage service
├── screens/
│   ├── splash_screen.dart         # App launch screen
│   ├── profile_setup_screen.dart  # User profile creation
│   ├── home_screen.dart           # Main app screen
│   └── settings_screen.dart       # User settings and preferences
├── widgets/
│   ├── welcome_card.dart          # User welcome display
│   ├── health_tip_card.dart       # Health tip display component
│   ├── quick_action_card.dart     # Navigation action cards
│   ├── notification_buttons.dart  # Notification test buttons
│   ├── notification_status.dart   # Notification settings status
│   └── profile_item.dart          # Profile information display
└── main.dart                      # App entry point
```

### Custom Widgets

The app uses a modular widget architecture with reusable components:

- **WelcomeCard**: Displays personalized user greeting and fitness goal
- **HealthTipCard**: Shows health tips with category icons and refresh functionality
- **QuickActionCard**: Reusable action cards for navigation
- **NotificationButtons**: Test buttons for random and personalized notifications
- **NotificationStatus**: Displays current notification settings
- **ProfileItem**: Individual profile information display items

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase project setup
- Android NDK 27.0.12077973 or higher

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd daily_health_tips
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Flow

### First Launch

1. **Splash Screen**: App initialization and user profile check
2. **Profile Setup**: New users create their profile with:
   - Name
   - Age (18-100 years)
   - Health Goal (lose weight, get fit, stay healthy, etc.)
   - Notification preferences
   - Daily notification time

### Main App Experience

1. **Home Screen**:

   - Personalized welcome message
   - Daily health tip with category indicators
   - Quick action buttons for settings and more tips
   - Notification test buttons
   - Current notification status

2. **Settings Screen**:
   - View and edit profile information
   - Manage notification preferences
   - Set daily notification time
   - Reset profile option

## 🔧 Configuration

### Firebase Configuration

The app requires Firebase for push notifications:

```dart
// lib/firebase_options.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-storage-bucket',
);
```

### Android Configuration

The app includes specific Android configurations for compatibility:

```kotlin
// android/app/build.gradle.kts
android {
    ndkVersion = "27.0.12077973"
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  cloud_firestore: ^5.4.0
  shared_preferences: ^2.2.2
  http: ^1.2.0
  intl: ^0.19.0
  permission_handler: ^11.3.1
  flutter_local_notifications: ^17.2.2
```

## 🔔 Notification System

### Features

- **Personalized Topics**: Users are subscribed to topics based on their profile
- **Age Groups**: Automatic categorization (under_18, 18_25, 26_35, 36_50, 50_plus)
- **Goal-based**: Topic subscription based on fitness goals
- **Individual Users**: User-specific topic for targeted notifications

### Testing

The app includes built-in notification testing:

- **Random Tip**: Send a random health tip notification
- **Personalized Tip**: Send a tip tailored to the current user's profile

## 🎨 UI/UX Features

### Material Design 3

- Modern Material Design 3 theming
- Consistent color scheme with green primary color
- Responsive design for different screen sizes
- Smooth animations and transitions

### Accessibility

- Proper contrast ratios
- Screen reader support
- Touch target sizes following accessibility guidelines

## 🛠️ Development

### Code Organization

- **Service Layer**: Business logic and external service integration
- **Model Layer**: Data structures and serialization
- **Widget Layer**: Reusable UI components
- **Screen Layer**: Page-level UI and navigation

### Best Practices

- Singleton pattern for services
- Proper error handling with try-catch blocks
- Graceful degradation when Firebase is unavailable
- Clean separation of concerns

## 📊 Health Tips System

### Categories

- **Nutrition**: Diet and eating advice
- **Exercise**: Physical activity recommendations
- **Mental Health**: Psychological well-being tips
- **Sleep**: Sleep hygiene and rest advice

### Personalization Logic

1. **Primary Match**: Tips matching both age group and fitness goal
2. **Secondary Match**: Tips matching age group with "stay healthy" goal
3. **Age Match**: Tips matching only the age group
4. **Fallback**: Random tips if no matches found

## 🔒 Privacy & Permissions

### Required Permissions

- **Notification Permission**: For push notifications
- **Storage Permission**: For local data storage (Android)

### Data Storage

- **Local Storage**: User profiles stored locally using SharedPreferences
- **No Cloud Storage**: User data is not uploaded to external servers
- **Privacy First**: Minimal data collection and local processing

## 🚀 Deployment

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

- Create an issue in the repository
- Check the Firebase documentation for setup issues
- Review Flutter documentation for development questions

## 🔄 Version History

### Current Version

- Custom widgets architecture
- Firebase Cloud Messaging integration
- Personalized health tips system
- Material Design 3 UI
- Cross-platform support

---

**Built with ❤️ using Flutter and Firebase**
