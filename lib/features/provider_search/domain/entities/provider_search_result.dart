/// Resultado de busqueda de un proveedor.
/// Entidad pura de dominio sin dependencias externas.
class ProviderSearchResult {
  final String id;
  final String userId;
  final String? bio;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final String? address;
  final double? distanceKm;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final List<ProviderCategory> categories;
  final double? minPrice;
  final double? maxPrice;
  final int servicesCount;

  const ProviderSearchResult({
    required this.id,
    required this.userId,
    this.bio,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    this.address,
    this.distanceKm,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.servicesCount = 0,
  });

  /// Nombre completo del proveedor.
  String get fullName => '$firstName $lastName';

  /// Iniciales para el avatar placeholder.
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  /// Texto formateado de precio (rango o precio unico).
  String? get priceRangeText {
    if (minPrice == null) return null;
    if (maxPrice != null && maxPrice != minPrice) {
      return '\$${_formatPrice(minPrice!)} - \$${_formatPrice(maxPrice!)}';
    }
    return 'Desde \$${_formatPrice(minPrice!)}';
  }

  /// Texto formateado de distancia.
  String? get distanceText {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  static String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}

/// Categoria de servicio asociada a un proveedor.
class ProviderCategory {
  final String id;
  final String name;
  final String slug;

  const ProviderCategory({
    required this.id,
    required this.name,
    required this.slug,
  });
}
