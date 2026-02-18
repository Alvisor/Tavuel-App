import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.clientId,
    required super.providerId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.clientName,
    super.clientAvatarUrl,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      clientId: json['clientId'] as String,
      providerId: json['providerId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      clientName: json['clientName'] as String?,
      clientAvatarUrl: json['clientAvatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'clientId': clientId,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'clientName': clientName,
      'clientAvatarUrl': clientAvatarUrl,
    };
  }
}
