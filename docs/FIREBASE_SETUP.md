# Firebase setup guide — Healthy Fitness (all platforms)

This app uses **Firebase Authentication (Google)** and **Cloud Firestore** (profiles + workout history). Follow these steps in order.

---

## Your app identifiers (use these in Firebase Console)

| Platform | ID to register in Firebase |
|----------|----------------------------|
| **Android** | Package name: `com.example.healthy_fitness` |
| **iOS** | Bundle ID: `com.example.healthyFitness` |
| **macOS** | Bundle ID: `com.example.healthyFitness` |
| **Web** | App nickname: e.g. `healthy_fitness_web` |

> **Note:** Android uses underscores (`healthy_fitness`); Apple platforms use camelCase (`healthyFitness`). They must match exactly what is in this repo.

---

## Part 1 — Firebase Console (browser)

### 1.1 Create a project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** → name it e.g. `healthy-fitness` → continue (Google Analytics optional).
3. Wait until the project is ready.

### 1.2 Enable Authentication (Google)

1. In the left menu: **Build → Authentication**.
2. Click **Get started**.
3. Open **Sign-in method** tab.
4. Enable **Google** → set a support email → **Save**.
5. Open the **Google** provider again and copy the **Web client ID** (ends with `.apps.googleusercontent.com`).  
   You will need this for Android Google Sign-In (step 3.4).

### 1.3 Create Firestore database

1. **Build → Firestore Database** → **Create database**.
2. Start in **test mode** for development (or production mode + deploy rules below).
3. Pick a region close to your users (e.g. `asia-south1`).

### 1.4 Register apps (one per platform you use)

Go to **Project settings** (gear icon) → **Your apps** → **Add app**.

#### Android app

1. Choose **Android**.
2. Android package name: `com.example.healthy_fitness`
3. Register app → download **`google-services.json`**.
4. Place the file here (exact path):

   ```
   android/app/google-services.json
   ```

5. **Do not skip:** On the same Android app page, click **Add fingerprint** and add your **SHA-1** (see Part 3.1). Without SHA-1, Google Sign-In fails on Android.

#### iOS app

1. Choose **iOS**.
2. Apple bundle ID: `com.example.healthyFitness`
3. Register → download **`GoogleService-Info.plist`**.
4. In Xcode (or Finder), put it in:

   ```
   ios/Runner/GoogleService-Info.plist
   ```

5. Open Xcode: `open ios/Runner.xcworkspace` → select **Runner** target → **Build Phases** → confirm `GoogleService-Info.plist` is under **Copy Bundle Resources** (FlutterFire usually does this).

#### Web app

1. Choose **Web** (</> icon).
2. Register app → copy the `firebaseConfig` object (FlutterFire will also generate `firebase_options.dart` for web).

#### macOS app (optional)

1. Add another **Apple** app with bundle ID: `com.example.healthyFitness` (same as iOS, or a dedicated macOS app in Firebase).
2. Download plist → place at:

   ```
   macos/Runner/GoogleService-Info.plist
   ```

#### Windows / Linux

Firebase Auth + Google Sign-In on desktop is possible but not required for this fitness app. Most teams ship **Android + iOS** first. You can skip Windows/Linux in Firebase unless you plan to ship desktop.

---

## Part 2 — FlutterFire CLI (recommended — wires all platforms)

This replaces placeholder `lib/firebase_options.dart` and links your Flutter project to Firebase.

### 2.1 Install tools

```bash
# Firebase CLI (login to Google)
npm install -g firebase-tools
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

Ensure `dart pub global` bin is on your `PATH` (add to `~/.zshrc` if needed):

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### 2.2 Configure the project

From the app root (`healthy_fitness/`):

```bash
cd /Users/synesis/Documents/RaiyanGit/healthy_fitness
flutter pub get
flutterfire configure
```

You will be asked to:

1. Select your Firebase project (`healthy-fitness`).
2. Select platforms: at minimum **android**, **ios**; add **web**, **macos** if you use them.
3. Confirm Android package `com.example.healthy_fitness` and iOS bundle `com.example.healthyFitness`.

**After this command you should have:**

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Real API keys (replaces `YOUR_*` placeholders) |
| `android/app/google-services.json` | Android native config |
| `ios/Runner/GoogleService-Info.plist` | iOS native config |
| `macos/Runner/GoogleService-Info.plist` | macOS (if selected) |

### 2.3 Firestore security rules (required for production)

Install Firebase CLI in the project (optional but useful):

```bash
firebase init firestore
# Choose existing project, use firestore.rules in repo root
```

Deploy rules from this repo:

```bash
firebase deploy --only firestore:rules
```

Rules file: `firestore.rules` (users can only access their own `users/{uid}` and `workoutHistory`).

---

## Part 3 — Platform-specific steps

### 3.1 Android — SHA-1 fingerprint (required for Google Sign-In)

```bash
cd android
./gradlew signingReport
```

Under **Variant: debug**, copy **SHA-1**.  
Firebase Console → **Project settings** → your **Android app** → **Add fingerprint** → paste SHA-1 → Save.

For **release** builds later, add the release keystore SHA-1 too.

### 3.2 Android — Web Client ID when running the app

After `flutterfire configure`, run with the Web client ID from Authentication → Google:

```bash
flutter run -d <android-device-id> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Or add the ID to `lib/config/app_config.dart` as the default `googleWebClientId` (not recommended for secrets in git — prefer `--dart-define`).

### 3.3 iOS — URL scheme for Google Sign-In

1. Open `ios/Runner/GoogleService-Info.plist`.
2. Find key `REVERSED_CLIENT_ID` (value like `com.googleusercontent.apps.123456-abcdef`).
3. Open `ios/Runner/Info.plist` and add **before** the closing `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID_FROM_PLIST</string>
    </array>
  </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID_FROM_PLIST` with the actual `REVERSED_CLIENT_ID` value.

`flutterfire configure` sometimes adds this automatically; verify it exists.

### 3.4 iOS — Apple capabilities (if using physical device)

- In Xcode: **Runner** → **Signing & Capabilities** → select your **Team**.
- No extra capability is required for Google Sign-In beyond the URL scheme above.

### 3.5 Web — run the app

```bash
flutter run -d chrome \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

In Firebase Console → **Authentication** → **Settings** → **Authorized domains**, ensure `localhost` is listed (usually added by default).

### 3.6 macOS — same as iOS

- `GoogleService-Info.plist` in `macos/Runner/`
- Add `REVERSED_CLIENT_ID` URL scheme in `macos/Runner/Info.plist` (same structure as iOS).
- Run: `flutter run -d macos`

---

## Part 4 — Verify everything works

### 4.1 Clean rebuild

```bash
flutter clean
flutter pub get
flutter run -d <device> --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

### 4.2 Checklist

| Check | Expected |
|-------|----------|
| Login screen | No yellow “Firebase is not set up” banner |
| Tap **Continue with Google** | Account picker → returns to app |
| After sign-in | Home screen with workouts |
| Profile | Shows your Google name/email |
| Complete a workout | **History** shows the entry |
| Firebase Console → Authentication → Users | Your Google user appears |
| Firestore → `users` collection | Document with your `uid` |

### 4.3 Common errors

| Symptom | Fix |
|---------|-----|
| `google-services.json is missing` | Run `flutterfire configure` or download plist/json manually |
| `ApiException: 10` / sign_in_failed | Add Android **SHA-1** + set **GOOGLE_WEB_CLIENT_ID** |
| `invalid-api-key` | Re-run `flutterfire configure`; don’t use `YOUR_*` placeholders |
| Firestore permission denied | Deploy `firestore.rules`; sign in first |
| iOS sign-in loops | Add `REVERSED_CLIENT_ID` URL scheme to `Info.plist` |

---

## Part 5 — Quick reference commands

```bash
# One-time setup
firebase login
dart pub global activate flutterfire_cli
flutterfire configure

# Android SHA-1
cd android && ./gradlew signingReport

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Run on phone (Android)
flutter run -d OVLN9PFUNR65ZP4L \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com

# Run on iPhone
flutter run -d 00008020-000D0C840A02003A \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com

# Run on Chrome
flutter run -d chrome \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
```

---

## What you do **not** need for a minimal mobile setup

- Windows / Linux Firebase apps (unless you target desktop)
- Separate Firebase projects for dev/prod (optional later)
- Cloud Functions (not used by this app yet)

**Minimum for your phone (Android):** Firebase project + Google Auth + Firestore + `flutterfire configure` + `google-services.json` + SHA-1 + `GOOGLE_WEB_CLIENT_ID` when running.

---

## Next step

After setup, remove test-mode Firestore rules before production and add release SHA-1 for Play Store builds.

For app-specific troubleshooting, see the main [README.md](../README.md).
