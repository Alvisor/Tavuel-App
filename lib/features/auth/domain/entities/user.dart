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
  final bool wantsToBeProvider;
  final String activeMode;
  final DateTime? createdAt;
  final String? verificationStatus;
  final DateTime? providerUpdatedAt;

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
    this.wantsToBeProvider = false,
    this.activeMode = 'CLIENT',
    this.createdAt,
    this.verificationStatus,
    this.providerUpdatedAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isProvider => role == 'PROVIDER';
  bool get isProviderMode => activeMode == 'PROVIDER';
}
