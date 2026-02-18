class Review {
  final String id;
  final String bookingId;
  final String clientId;
  final String providerId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? clientName;
  final String? clientAvatarUrl;

  const Review({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.clientName,
    this.clientAvatarUrl,
  });
}
