# Task Tracking App

A Flutter app for Internee.pk interns to manage daily work and for admins to
assign tasks, follow progress in real time, and review performance reports.

Built with Flutter, Firebase Authentication, and Cloud Firestore.

## Features

### Intern

- Sign up and log in with email and password; request a password reset.
- Create tasks with a title, description, priority, and due date.
- Move tasks between Pending, In Progress, and Completed.
- Filter tasks by status and see overdue tasks highlighted.
- Track personal completion progress.

### Admin

- Assign tasks to interns; edit task details and delete tasks.
- View live task totals for completed, in-progress, pending, and overdue work.
- Browse interns with per-intern completion progress and task details.
- Review status charts, ranked performance, and detailed report metrics.
- Filter reports by the last seven days, this month, or all time.
- Compare on-time, late, and overdue tasks.

### Security

- User profiles have `intern` or `admin` roles. New public sign-ups are always
  created as interns.
- [`firestore.rules`](firestore.rules) limits intern task access to their own
  tasks and reserves all-task access and assignment/editing for admins.
- UI role checks are not a security boundary; deploy and test the Firestore
  rules before using a production Firebase project.

## Screenshots

Capture screenshots from a configured, running app and save them in
[`screenshots/`](screenshots/). The expected filenames and screen checklist
are in [`screenshots/README.md`](screenshots/README.md). Screenshots are not
included yet.

## Tech Stack

- Flutter / Dart
- Firebase Authentication
- Cloud Firestore
- `fl_chart`, `intl`

## Project Structure

```text
lib/
├── models/      user_model, task_model, report_stats
├── services/    auth_service, task_service, user_service
├── screens/     auth/, intern/, admin/
├── widgets/     task_card, confirm_dialog
└── utils/       auth_errors
```

## Firestore Data Model

**`users/{uid}`:** `name`, `email`, `role`, `createdAt`

**`tasks/{id}`:** `title`, `description`, `assignedTo`, `assignedBy`,
`createdBy`, `status`, `priority`, `dueDate`, `createdAt`, `completedAt`

Task document IDs are supplied to the model separately and are not duplicated
in the stored task map.

## Performance Score

`Score = 60% completion rate + 40% on-time rate`

A task is on time if completed before the end of its due date. A task becomes
overdue after that date ends and remains incomplete.

## Getting Started

### Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- A Firebase project with Email/Password Authentication and Cloud Firestore
- Android Studio / Android SDK for Android builds

### Setup

1. Clone the repository (replace `YOUR_USERNAME` with the GitHub account that
   owns the repository):

   ```sh
   git clone https://github.com/YOUR_USERNAME/task_tracking_app.git
   cd task_tracking_app
   ```

2. Fetch packages:

   ```sh
   flutter pub get
   ```

3. Configure your Firebase project:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Enable Email/Password sign-in and Cloud Firestore in Firebase Console.
   Review `firestore.rules` for your app, then deploy those rules using the
   Firebase CLI:

   ```sh
   firebase deploy --only firestore:rules
   ```

   The repository does not include `firebase_options.dart`; generate it for
   your own Firebase project with `flutterfire configure`. Android also needs
   that project's `google-services.json` at `android/app/google-services.json`.

4. Run the app:

   ```sh
   flutter run
   ```

### Creating an Admin

Create an account through the normal sign-up flow. Then use a trusted
administrative process (for example Firebase Console) to change that user's
`users/{uid}` profile role to `admin`. Client-side account creation cannot
assign admin privileges.

## Testing and Release

Run static analysis and the automated tests:

```sh
flutter analyze
flutter test
```

Build an Android release APK:

```sh
flutter build apk --release
```

The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`. Configure a production
Android signing key before distribution; never commit signing keys or
credentials.

### Manual Acceptance Test Plan

1. Create an intern account; verify it receives the `intern` role and can
   sign in and sign out.
2. Try an invalid password, invalid email, and offline sign-in; confirm useful
   errors are shown. Request a password reset using a valid email.
3. Create a task with whitespace-only title (must be rejected), an 80
   character title, each priority, and a due date; verify it appears without
   restarting the app.
4. Change task status; verify tabs, progress, completion timestamp, and
   overdue display update in real time.
5. Confirm an incomplete task due today is not overdue before the due date
   ends, but becomes overdue after the due date.
6. Sign in as an admin; assign a task, edit its details, change its status,
   and delete it after confirmation.
7. Verify Overview counts and assignee names update; verify Interns shows
   each intern's task completion progress and task list.
8. Verify weekly, monthly, and all-time Reports filters, charts, and ranking
   values against known tasks; confirm on-time completion includes the entire
   due date.
9. With two accounts, verify an intern cannot read or modify another
   intern's task and cannot change a profile role. Also verify admin-only
   reads and writes using the deployed Firestore rules.

## Download and Demo

No GitHub Releases page or live demo URL has been configured yet. After
publishing the repository, create a GitHub Release and attach the
production-signed APK. Add the deployed web app URL here if/when one is
available.

## Author

Ateeq Ur Rahman  
Computer Engineering, COMSATS University Islamabad, Abbottabad Campus  
Add your LinkedIn and GitHub profile links here.
