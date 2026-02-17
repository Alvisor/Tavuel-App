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
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'CLIENT',
      status: json['status'] as String? ?? 'ACTIVE',
      avatarUrl: json['avatarUrl'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
