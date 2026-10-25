# Lakshya's Hostel ERP

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen)](https://flutter.dev/multi-platform)
[![Design](https://img.shields.io/badge/Design-Material%203-blue)](https://m3.material.io)

A modern, dual-role Flutter ERP application designed for seamless hostel and flat operations. It provides a real-time portal for residents and comprehensive management controls for hostel managers and owners.

---

## Features

### Resident Portal
- **Daily Dashboard**: View live dues summaries, today's meal schedule, announcements, and next shuttle/cab timings.
- **Mess Menu**: Full weekly meal planner categorized by Breakfast, Lunch, Snacks, and Dinner with day-by-day tabs.
- **Payments & Dues**: View ledger, outstanding rent/dues, scan hostel UPI QR codes, and submit UTR confirmation proofs.
- **Support Tickets**: Raise and track maintenance/facility complaints in real time.

### Manager / Admin Portal
- **Real-Time Overview**: Live statistics powered by Cloud Firestore listeners for instant operational updates.
- **Resident Management**: Directory of registered residents, room allocations, and status tracking.
- **Payment Verification**: Review, approve, or reject resident UTR payment submissions.
- **Schedule Management**: Update weekly mess menus and transport/cab schedules.
- **Student Onboarding**: Register new residents directly into Firestore.

---

## Demo Credentials

The application features built-in self-seeding authentication for immediate testing:

| Role | Portal Tab | Email | Password |
| :--- | :--- | :--- | :--- |
| **Resident** | User | `user1@lakshya.com` | `password123` |
| **Resident** | User | `user2@lakshya.com` | `password123` |
| **Manager** | Manager | `manager@lakshya.com` | `password123` |
| **Admin** | Manager | `admin@lakshya.com` | `password123` |

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3)
- **Backend & Database**: [Firebase Auth](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **State Management**: Reactive `ChangeNotifier` pattern
- **Design System**: Material Design 3, [Google Fonts](https://fonts.google.com/specimen/Inter) (Inter)
- **Supported Targets**: Android, Web, iOS

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
- Android Studio / VS Code with Flutter extension
- An active Firebase project configured via `firebase_options.dart`

### Installation & Run

```bash
# 1. Clone the repository
git clone https://github.com/hardiktomarrr/Hostel-ERP-Application.git
cd Hostel-ERP-Application

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

### Build Commands

```bash
# Android APK
flutter build apk --release

# Web Build
flutter build web --release
```

---

## Project Structure

```text
lib/
├── controllers/    # State management & business logic (ChangeNotifier)
├── models/         # Data models (Residents, Payments, Menu, Roles)
├── screens/        # UI views (Resident dashboard, Admin panels, Auth)
├── theme/          # Design system tokens (Colors, Typography, Theme)
├── widgets/        # Reusable Material 3 components
├── firebase_options.dart
└── main.dart       # App entry point & Firebase initialization
```

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
