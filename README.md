# Todo Tracker

A professional Flutter mobile application for tracking tasks, managing progress, and receiving reminders.

## Features

- User authentication (login, register, password reset)
- User roles (admin and regular users)
- Task management (create, update, delete)
- Progress tracking with subtasks
- Task prioritization (high, medium, low)
- Task status tracking (to-do, in progress, completed)
- Task reminders and notifications
- Due date management
- Filter and search tasks
- Dark and light themes

## Project Structure

The project follows a feature-based architecture with separation of concerns:

```
lib/
├── core/                  # Core application code
│   ├── constants/         # App-wide constants
│   ├── services/          # Shared services
│   ├── utils/             # Utility functions
│   └── widgets/           # Shared widgets
│
├── features/              # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── models/        # Auth models
│   │   ├── providers/     # Auth state management
│   │   ├── screens/       # Auth UI screens
│   │   └── widgets/       # Auth-specific widgets
│   │
│   ├── tasks/             # Tasks feature
│   │   ├── models/        # Task models
│   │   ├── providers/     # Task state management
│   │   ├── screens/       # Task UI screens
│   │   └── widgets/       # Task-specific widgets
│   │
│   └── profile/           # User profile feature
│       ├── models/        # Profile models
│       ├── providers/     # Profile state management
│       ├── screens/       # Profile UI screens
│       └── widgets/       # Profile-specific widgets
│
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.2 or higher)
- Firebase account

### Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Create a Firebase project and add your configuration files
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
4. Run the app with `flutter run`

## Firebase Configuration

This app uses the following Firebase services:

- Firebase Authentication for user management
- Cloud Firestore for data storage
- Firebase Cloud Messaging (optional) for push notifications

## Dependencies

- firebase_core, firebase_auth, cloud_firestore: Firebase integration
- provider: State management
- flutter_local_notifications: Local notifications
- intl: Date formatting
- shared_preferences: Local storage
- google_fonts: Custom typography
- flutter_svg: SVG support
- cached_network_image: Image caching
- percent_indicator: Progress visualization
- flutter_slidable: Swipeable UI components
- uuid: Unique ID generation
- table_calendar: Calendar widget
- timezone, flutter_timezone: Timezone management

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
