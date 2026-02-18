/// Categoria de servicio para los filtros de busqueda.
class ServiceCategory {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final int sortOrder;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.iconUrl,
    this.isActive = true,
    this.sortOrder = 0,
  });
}
