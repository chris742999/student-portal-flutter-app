class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  // ... add other fields

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
  };
}