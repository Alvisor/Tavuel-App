class StarCount {
  final int stars;
  final int count;

  const StarCount({
    required this.stars,
    required this.count,
  });
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final List<StarCount> distribution;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  /// Obtiene el porcentaje para un numero dado de estrellas.
  double percentageFor(int stars) {
    if (totalReviews == 0) return 0;
    for (final d in distribution) {
      if (d.stars == stars) {
        return (d.count / totalReviews) * 100;
      }
    }
    return 0;
  }
}
