import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.role,
    super.status,
    super.avatarUrl,
    super.phoneVerified,
    super.wantsToBeProvider,
    super.activeMode,
    super.createdAt,
    super.verificationStatus,
    super.providerUpdatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'CLIENT',
      status: json['status'] as String? ?? 'ACTIVE',
      avatarUrl: json['avatarUrl'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      wantsToBeProvider: json['wantsToBeProvider'] as bool? ?? false,
      activeMode: json['activeMode'] as String? ?? 'CLIENT',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      verificationStatus:
          provider?['verificationStatus'] as String?,
      providerUpdatedAt: provider?['updatedAt'] != null
          ? DateTime.parse(provider!['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'status': status,
      'avatarUrl': avatarUrl,
      'phoneVerified': phoneVerified,
      'wantsToBeProvider': wantsToBeProvider,
      'activeMode': activeMode,
      'createdAt': createdAt?.toIso8601String(),
      'verificationStatus': verificationStatus,
      'providerUpdatedAt': providerUpdatedAt?.toIso8601String(),
    };
  }
}
