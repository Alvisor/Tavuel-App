import '../../domain/entities/provider_search_result.dart';

class ProviderSearchResultModel extends ProviderSearchResult {
  const ProviderSearchResultModel({
    required super.id,
    required super.userId,
    super.bio,
    required super.rating,
    required super.totalReviews,
    required super.totalBookings,
    super.address,
    super.distanceKm,
    required super.firstName,
    required super.lastName,
    super.avatarUrl,
    super.categories,
    super.minPrice,
    super.maxPrice,
    super.servicesCount,
  });

  factory ProviderSearchResultModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    final categoriesJson = json['categories'] as List<dynamic>? ?? [];
    final categories = categoriesJson
        .map((c) => ProviderCategoryModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ProviderSearchResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      bio: json['bio'] as String?,
      rating: _toDouble(json['rating']),
      totalReviews: _toInt(json['totalReviews']),
      totalBookings: _toInt(json['totalBookings']),
      address: json['address'] as String?,
      distanceKm: _toDoubleOrNull(json['distanceKm']),
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      avatarUrl: user['avatarUrl'] as String?,
      categories: categories,
      minPrice: _toDoubleOrNull(json['minPrice']),
      maxPrice: _toDoubleOrNull(json['maxPrice']),
      servicesCount: _toInt(json['servicesCount']),
    );
  }
}

class ProviderCategoryModel extends ProviderCategory {
  const ProviderCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory ProviderCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProviderCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

/// Helpers para parsear campos Decimal de Prisma que pueden venir como String o num.
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
