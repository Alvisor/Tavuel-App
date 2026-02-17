class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final String status;
  final String? avatarUrl;
  final bool phoneVerified;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.role = 'CLIENT',
    this.status = 'ACTIVE',
    this.avatarUrl,
    this.phoneVerified = false,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';
}
