class ProviderEntity {
  final String id;
  final String userId;
  final String? bio;
  final String verificationStatus;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime? approvedAt;

  const ProviderEntity({
    required this.id,
    required this.userId,
    this.bio,
    this.verificationStatus = 'PENDING_DOCUMENTS',
    this.rating = 0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.address,
    this.latitude,
    this.longitude,
    this.approvedAt,
  });
}
