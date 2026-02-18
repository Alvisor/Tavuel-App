class ServiceCategory {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? iconUrl;
  final int serviceCount;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.iconUrl,
    this.serviceCount = 0,
  });
}
