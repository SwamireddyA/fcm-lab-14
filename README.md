# Cloud Courier — In-Class Activity 14 (CSC 4360)

Flutter app that receives Firebase Cloud Messaging (FCM) messages and uses custom data to change the visible title and image, across foreground, background, and terminated states.

## Structure
- `lib/main.dart` — awaits `Firebase.initializeApp`, registers the top-level `@pragma('vm:entry-point')` background handler, then `runApp`.
- `lib/services/fcm_service.dart` — `FCMService` owns all listeners: permission, token, `onMessage`, `onMessageOpenedApp`, `getInitialMessage`; `dispose()` cancels subscriptions; duplicate-init guard.
- `lib/models/payload.dart` — `PayloadValidator` allow-lists `action: update_ui` and `asset: default|promo`. Anything else is rejected with a diagnostic.
- `lib/home_screen.dart` — shows title, image, last handler, receipt count, message ID, permission, and a **Copy FCM token** button. Invalid payloads keep the previous title/image.

## Setup
1. `flutter pub get`
2. `flutterfire configure` (Android target) → generates `lib/firebase_options.dart`
3. `flutter run` on an Android emulator **with Google Play** (or a real device)
4. Allow notifications, tap **Copy FCM token**.

## Sending a test message
Firebase Console → Messaging → New campaign → Notifications. Title `New promotion`, body `Switch the screen to the promo asset`. Under **Additional options → Custom data** add `asset = promo` and `action = update_ui`. Click **Send test message**, paste the token, Test.

Valid payload:
```json
{ "notification": { "title": "New promotion", "body": "Switch the screen to the promo asset" },
  "data": { "asset": "promo", "action": "update_ui" } }
```

## Tests
- T1 Foreground → `onMessage`
- T2 Background + tap → `onMessageOpenedApp`
- T3 Swipe away from recents, send, tap → `getInitialMessage`
- T4 Foreground, `asset = unknown` → diagnostic, previous title/image kept
- `flutter test` → payload validator unit tests
