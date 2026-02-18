class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isBiometricEnrolled;
  final String? profilePhotoUrl;
  final String? bio;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isBiometricEnrolled = false,
    this.profilePhotoUrl,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isBiometricEnrolled: json['isBiometricEnrolled'] ?? false,
      profilePhotoUrl: json['profilePhoto'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'isBiometricEnrolled': isBiometricEnrolled,
      'profilePhoto': profilePhotoUrl,
      'bio': bio,
    };
  }

  String get fullName => '$firstName $lastName';
}
