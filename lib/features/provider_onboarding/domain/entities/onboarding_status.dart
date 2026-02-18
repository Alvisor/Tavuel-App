class OnboardingStatus {
  final bool hasProfile;
  final bool profileComplete;
  final bool documentsUploaded;
  final bool bankAccountSet;
  final bool availabilitySet;
  final bool categoriesSelected;
  final bool canSubmit;
  final String? verificationStatus;

  const OnboardingStatus({
    this.hasProfile = false,
    this.profileComplete = false,
    this.documentsUploaded = false,
    this.bankAccountSet = false,
    this.availabilitySet = false,
    this.categoriesSelected = false,
    this.canSubmit = false,
    this.verificationStatus,
  });

  int get completedSteps {
    int count = 0;
    if (profileComplete) count++;
    if (categoriesSelected) count++;
    if (documentsUploaded) count++;
    if (bankAccountSet) count++;
    if (availabilitySet) count++;
    return count;
  }

  int get totalSteps => 5;

  int get firstIncompleteStep {
    if (!profileComplete) return 0;
    if (!categoriesSelected) return 1;
    if (!documentsUploaded) return 2;
    if (!bankAccountSet) return 3;
    if (!availabilitySet) return 4;
    return 5; // all complete, show review
  }
}
