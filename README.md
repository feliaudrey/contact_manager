# Contact Manager

A modern Flutter contact management application with birthday reminders and multilingual support.

## Author
**Felicia Audrey (2210101030)**

## Features

### Contact Management
- Create, edit, and delete contacts
- Store contact details including name, phone number, email, and birthday
- Profile picture support with base64 image encoding
- Organized contact list with alphabetical sorting

### Birthday Reminders
- Calendar view of upcoming birthdays
- Birthday notifications and reminders
- Send birthday wishes via SMS or email
- Customized birthday card templates

### Multilingual Support
- Multiple language options:
  - English
  - Indonesian (Bahasa Indonesia)
  - Spanish (Español)
  - Chinese (中文)
- Language-specific birthday card templates
- Localized interface elements

### User Interface
- Modern Material Design
- Dark mode support
- Intuitive navigation
- Responsive layout for various screen sizes

## Technical Details

### Built With
- Flutter - Cross-platform UI framework
- Firebase - Backend and authentication
- Provider - State management
- table_calendar - Calendar widget
- url_launcher - Email and SMS functionality
- intl - Internationalization support

### Firebase Features
- Authentication
- Cloud Firestore for data storage
- Real-time data synchronization

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/feliaudrey/contact_manager.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
- Download and add the configuration files (not included in repository for security):
  - Add `google-services.json` to `android/app/`
  - Add `GoogleService-Info.plist` to `ios/Runner/`
  - Create `lib/firebase_options.dart` using Firebase CLI
- Enable Authentication and Firestore in Firebase Console
- Set up security rules for Firestore

4. Run the app
```bash
flutter run
```

## Security Note
For security reasons, Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart`) are not included in this repository. You will need to set up your own Firebase project and add these files locally.


This project is for educational purposes as part of a university assignment.
