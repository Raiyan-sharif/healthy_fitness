class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.fitnessGoal = 'General fitness',
    this.dailyStepGoal = 8000,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String fitnessGoal;
  final int dailyStepGoal;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      fitnessGoal: map['fitnessGoal'] as String? ?? 'General fitness',
      dailyStepGoal: (map['dailyStepGoal'] as num?)?.toInt() ?? 8000,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'fitnessGoal': fitnessGoal,
      'dailyStepGoal': dailyStepGoal,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? fitnessGoal,
    int? dailyStepGoal,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    );
  }
}
