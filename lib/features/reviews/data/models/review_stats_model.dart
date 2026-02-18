import '../../domain/entities/review_stats.dart';

class StarCountModel extends StarCount {
  const StarCountModel({
    required super.stars,
    required super.count,
  });

  factory StarCountModel.fromJson(Map<String, dynamic> json) {
    return StarCountModel(
      stars: json['stars'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'count': count,
    };
  }
}

class ReviewStatsModel extends ReviewStats {
  const ReviewStatsModel({
    required super.averageRating,
    required super.totalReviews,
    required super.distribution,
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    final distributionList = (json['distribution'] as List<dynamic>?)
            ?.map((e) => StarCountModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ReviewStatsModel(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      distribution: distributionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'distribution': distribution
          .map((d) => {'stars': d.stars, 'count': d.count})
          .toList(),
    };
  }
}
