import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_fitness/models/user_profile.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<void> ensureProfileForUser(User user) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _doc(user.uid).get();

    if (snapshot.exists) {
      return;
    }

    final UserProfile profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Fitness User',
      photoUrl: user.photoURL,
    );
    await _doc(user.uid).set(profile.toMap());
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserProfile.fromMap(uid, doc.data()!);
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }
}
