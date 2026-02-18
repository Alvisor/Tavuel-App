import '../../domain/entities/service_category.dart';

class ServiceCategoryModel extends ServiceCategory {
  const ServiceCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
    super.iconUrl,
    super.serviceCount,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final services = json['services'];
    final count = services is List ? services.length : 0;

    return ServiceCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      serviceCount: count,
    );
  }
}
