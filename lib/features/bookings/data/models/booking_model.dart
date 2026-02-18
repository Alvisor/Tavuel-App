import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.clientId,
    super.providerId,
    super.serviceId,
    super.categoryId,
    required super.status,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.scheduledAt,
    required super.description,
    super.quotedPrice,
    super.quotedMaterials,
    super.estimatedDuration,
    super.quoteNote,
    super.startedAt,
    super.completedAt,
    super.cancelledAt,
    super.cancellationReason,
    super.cancelledBy,
    required super.createdAt,
    required super.updatedAt,
    super.clientName,
    super.clientAvatarUrl,
    super.clientPhone,
    super.providerName,
    super.providerAvatarUrl,
    super.providerPhone,
    super.serviceName,
    super.categoryName,
    super.categoryIconUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Extraer datos de relaciones anidadas del backend
    final client = json['client'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final providerUser =
        provider?['user'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    final category =
        service?['category'] as Map<String, dynamic>? ??
        json['category'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      providerId: json['providerId'] as String?,
      serviceId: json['serviceId'] as String?,
      categoryId: json['categoryId'] as String?,
      status: json['status'] as String,
      address: json['address'] as String,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      description: json['description'] as String? ?? '',
      quotedPrice: _toNullableDouble(json['quotedPrice']),
      quotedMaterials: _toNullableDouble(json['quotedMaterials']),
      estimatedDuration: json['estimatedDuration'] as int?,
      quoteNote: json['quoteNote'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      // Relaciones planas
      clientName: client != null
          ? '${client['firstName'] ?? ''} ${client['lastName'] ?? ''}'.trim()
          : null,
      clientAvatarUrl: client?['avatarUrl'] as String?,
      clientPhone: client?['phone'] as String?,
      providerName: providerUser != null
          ? '${providerUser['firstName'] ?? ''} ${providerUser['lastName'] ?? ''}'
              .trim()
          : null,
      providerAvatarUrl: providerUser?['avatarUrl'] as String?,
      providerPhone: providerUser?['phone'] as String?,
      serviceName: service?['name'] as String?,
      categoryName: category?['name'] as String?,
      categoryIconUrl: category?['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'providerId': providerId,
      'serviceId': serviceId,
      'categoryId': categoryId,
      'status': status,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledAt': scheduledAt.toIso8601String(),
      'description': description,
      'quotedPrice': quotedPrice,
      'quotedMaterials': quotedMaterials,
      'estimatedDuration': estimatedDuration,
      'quoteNote': quoteNote,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Prisma Decimal viene como string en el JSON.
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
