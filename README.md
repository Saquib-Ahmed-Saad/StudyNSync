# StudyNSync

## Course Information

- Course: Mobile App Development
- Project: Project 2 / Final Project
- Team Name: StudyNSync
- Based On: FocusNFlow — Campus Study Organizer
- Repository: https://github.com/Saquib-Ahmed-Saad/StudyNSync

---

## Team Members

| Name | Role |
|---|---|
| Saquib Ahmed | UI/Frontend, Navigation, Documentation |
| Brendon Huang | Backend, Firebase, Firestore, Authentication, Testing |

---

## Project Summary

StudyNSync is a campus study organizer that helps students manage schoolwork, create weekly study plans, find available study rooms, form study groups, chat with group members, schedule study sessions, receive reminders, and use a shared Pomodoro timer.

The app is designed to reduce scheduling conflicts and improve student productivity by combining planning, collaboration, and real-time campus resource information in one mobile app.

---

## Core Features

### Firebase Authentication

StudyNSync uses Firebase Authentication for user identity.

Implemented features:

- Campus email signup
- Campus email sign-in
- Password validation
- Firebase logout
- Firestore profile creation after signup

Accepted campus domains:

@student.gsu.edu
@gsu.edu

Firestore Student Profiles

Each authenticated user has a Firestore profile stored at:

users/{uid}

Profile fields include:

email
displayName
role
courseIds
createdAt
updatedAt
Study Planning Engine

The study planner allows users to create tasks with:

Task title
Course code
Deadline
Estimated effort
Course weight

The weekly study-plan assistant prioritizes tasks using:

Deadline urgency
Estimated effort
Course weight

The generated weekly plan includes:

Study blocks
Priority scores
Recommendation reasons
Conflict warnings
Auto-adjustment suggestions

Generated plans are stored in Firestore under:

users/{uid}/weeklyPlans/{weekId}/items/{itemId}
Study Room Finder

Study rooms are stored in Firestore under:

rooms/{roomId}

The room finder displays real-time room availability and uses Firestore transactions for check-in/check-out occupancy updates.

Room data includes:

name
building
capacity
occupiedSeats
isOpen
updatedAt
Study Group Formation

Study groups are stored in Firestore under:

groups/{groupId}

Group member records are stored under:

groups/{groupId}/members/{uid}

Users can:

Create a study group
Join a study group
Open group chat
Schedule a study session
Use the shared group timer
Group Chat

Group chat messages are stored in Firestore under:

groups/{groupId}/messages/{messageId}

The chat screen listens to Firestore in real time so new messages appear without refreshing.

Study Session Scheduling

Study sessions are stored in Firestore under:

sessions/{sessionId}

Each scheduled session creates a reminder request under:

notificationQueue/{notificationId}

Session data includes:

groupId
title
createdBy
participantIds
startTime
endTime
location
reminderQueued
createdAt
Firebase Cloud Messaging

StudyNSync uses Firebase Cloud Messaging for notification support.

Implemented FCM features:

Notification permission request
FCM token retrieval
FCM token printing in debug console
FCM token storage in Firestore
Foreground message logging
Firebase Console notification test

FCM tokens are stored under:

users/{uid}/fcmTokens/{token}

Successful test evidence:

FOREGROUND MESSAGE TITLE: study
FOREGROUND MESSAGE BODY: Test
Shared Pomodoro Timer and Goals

The shared Pomodoro timer stores synchronized group timer state in Firestore under:

groups/{groupId}/timer/state

Timer state includes:

mode
runState
totalSeconds
remainingSeconds
controlledBy
sessionGoal
completedCycles
updatedAt

The timer visually counts down in the app while Firestore stores the shared timer state.

## Firebase Storage

Firebase Storage service code and Storage security rules were implemented.

Storage-related files:

lib/services/storage_service.dart
firebase_rules/storage.rules

However, the Firebase Console required the Blaze/pay-as-you-go plan to create a new Storage bucket. Since this class project should not require payment, the team did not activate the Storage bucket.

Storage implementation is included in code, but Storage deployment was skipped because billing was required.

## Firebase Collections
users
users/{uid}/tasks
users/{uid}/weeklyPlans
users/{uid}/weeklyPlans/{weekId}/items
users/{uid}/fcmTokens
rooms
groups
groups/{groupId}/members
groups/{groupId}/messages
groups/{groupId}/timer
sessions
notificationQueue


## Main Project Files

Models
lib/models/app_user.dart
lib/models/study_task.dart
lib/models/study_plan_item.dart
lib/models/study_room.dart
lib/models/study_group.dart
lib/models/group_message.dart
lib/models/study_session.dart
lib/models/pomodoro_state.dart

Services
lib/services/auth_service.dart
lib/services/firestore_service.dart
lib/services/study_planner_service.dart
lib/services/notification_service.dart
lib/services/storage_service.dart
lib/services/studynsync_backend.dart

Screens
lib/screens/login_screen.dart
lib/screens/dashboard_screen.dart
lib/screens/profile_screen.dart
lib/screens/study_planner_screen.dart
lib/screens/study_room_finder_screen.dart
lib/screens/study_groups_screen.dart
lib/screens/chat_screen.dart
lib/screens/timer_screen.dart
lib/screens/backend_test_screen.dart

Firebase Rules
firebase_rules/firestore.rules
firebase_rules/storage.rules
firebase_rules/firestore.indexes.json
firebase.json

Tests
test/auth_validation_test.dart
test/study_planner_service_test.dart


## Setup Instructions
1. Clone the Repository
git clone https://github.com/Saquib-Ahmed-Saad/StudyNSync.git
cd StudyNSync

2. Install Dependencies
flutter pub get

3. Configure Firebase
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
firebase login
flutterfire configure

Select at least:

Android
Web

4. Set Firebase Project
firebase use --add

Select:

studynsync-99bb5

Use alias:

default

5. Deploy Firestore Rules and Indexes
firebase deploy --only firestore:rules,firestore:indexes --project studynsync-99bb5

Storage deployment was skipped because Firebase Storage bucket setup required a paid Blaze plan.

Run the App
Run on Chrome
flutter run -d chrome
Run on Android Phone

Build the APK:

flutter build apk --release

Install with ADB:

adb install -r build/app/outputs/flutter-apk/app-release.apk

APK path:

build/app/outputs/flutter-apk/app-release.apk

## Testing Commands

Run Flutter analysis:

flutter analyze

Run tests:

flutter test

Build release APK:

flutter build apk --release

## Test Plan Summary

Authentication Test

Expected result:

Empty input is rejected.
Non-campus email is rejected.
Campus email signup/sign-in works.
Firebase Authentication user is created.
Firestore profile is created under users/{uid}.
Study Planner Test

## Expected result:

Tasks save to Firestore.
Weekly plan generates from Firestore tasks.
Priority reasons are shown.
Conflict warnings and adjustment suggestions are shown.
Room Finder Test

Expected result:

Rooms display from Firestore.
Check-in/check-out updates room occupancy.
Occupancy does not go below zero or above capacity.
Study Group Test

Expected result:

Group is created in Firestore.
User joins group.
Member subcollection is created.
Chat Test

Expected result:

Message saves to Firestore.
Chat updates in real time.
Session Scheduling Test

Expected result:

Session document is created.
Notification queue document is created.
FCM Test

Expected result:

Token is printed in terminal.
Token is saved in Firestore.
Firebase Console notification is received.
Timer Test

Expected result:

Timer counts down visually.
Start, pause, reset update Firestore.
Session goal saves to Firestore.


Firebase Storage bucket creation required the Blaze/pay-as-you-go plan. Since this project should not require payment, the Storage bucket was not activated.

Implemented:

lib/services/storage_service.dart
firebase_rules/storage.rules

Not activated:

Firebase Storage bucket


## Final Build Command
flutter build apk --release

Final APK:

build/app/outputs/flutter-apk/app-release.apk
