import '../../domain/entities/onboarding_status.dart';

class OnboardingStatusModel extends OnboardingStatus {
  const OnboardingStatusModel({
    super.hasProfile,
    super.profileComplete,
    super.documentsUploaded,
    super.bankAccountSet,
    super.availabilitySet,
    super.categoriesSelected,
    super.canSubmit,
    super.verificationStatus,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      hasProfile: json['hasProfile'] as bool? ?? false,
      profileComplete: json['profileComplete'] as bool? ?? false,
      documentsUploaded: json['documentsUploaded'] as bool? ?? false,
      bankAccountSet: json['bankAccountSet'] as bool? ?? false,
      availabilitySet: json['availabilitySet'] as bool? ?? false,
      categoriesSelected: json['categoriesSelected'] as bool? ?? false,
      canSubmit: json['canSubmit'] as bool? ?? false,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
}
