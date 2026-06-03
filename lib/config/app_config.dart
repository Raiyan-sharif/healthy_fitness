import 'package:healthy_fitness/firebase_options.dart';

/// Web client ID from Firebase Console → Authentication → Google → Web SDK.
/// Required on Android for Firebase Google sign-in (fixes ApiException 10).
///
/// Set via: `--dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com`
/// or replace [googleWebClientId] below after `flutterfire configure`.
class AppConfig {
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static bool get isFirebaseConfigured {
    const String placeholder = 'YOUR_';
    return !DefaultFirebaseOptions.android.apiKey.startsWith(placeholder);
  }
}
