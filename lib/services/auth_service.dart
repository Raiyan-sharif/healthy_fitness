import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthy_fitness/config/app_config.dart';
import 'package:healthy_fitness/services/profile_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    ProfileService? profileService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const <String>['email'],
              serverClientId: AppConfig.googleWebClientId.isEmpty
                  ? null
                  : AppConfig.googleWebClientId,
            ),
        _profileService = profileService ?? ProfileService();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final ProfileService _profileService;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthCancelledException();
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    await _profileService.ensureProfileForUser(userCredential.user!);
    return userCredential;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class AuthCancelledException implements Exception {
  @override
  String toString() => 'Google sign-in was cancelled.';
}

String formatAuthError(Object error) {
  if (error is AuthCancelledException) {
    return error.toString();
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-api-key':
      case 'app-not-authorized':
        return 'Firebase is not configured. Run flutterfire configure and add google-services.json.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return error.message ?? error.code;
    }
  }
  if (error is PlatformException) {
    if (error.code == 'sign_in_failed' &&
        (error.message?.contains('10') ?? false)) {
      return 'Google Sign-In setup incomplete. Add Android SHA-1 in Firebase Console and set GOOGLE_WEB_CLIENT_ID (Web client ID).';
    }
    return error.message ?? '${error.code}: sign-in failed';
  }
  return error.toString();
}
