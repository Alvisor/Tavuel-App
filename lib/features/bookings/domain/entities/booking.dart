/// Entidad de dominio que representa una reserva de servicio.
class Booking {
  final String id;
  final String clientId;
  final String? providerId;
  final String? serviceId;
  final String? categoryId;
  final String status;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final String description;
  final double? quotedPrice;
  final double? quotedMaterials;
  final int? estimatedDuration;
  final String? quoteNote;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones planas para la UI
  final String? clientName;
  final String? clientAvatarUrl;
  final String? clientPhone;
  final String? providerName;
  final String? providerAvatarUrl;
  final String? providerPhone;
  final String? serviceName;
  final String? categoryName;
  final String? categoryIconUrl;

  const Booking({
    required this.id,
    required this.clientId,
    this.providerId,
    this.serviceId,
    this.categoryId,
    required this.status,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.description,
    this.quotedPrice,
    this.quotedMaterials,
    this.estimatedDuration,
    this.quoteNote,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.clientAvatarUrl,
    this.clientPhone,
    this.providerName,
    this.providerAvatarUrl,
    this.providerPhone,
    this.serviceName,
    this.categoryName,
    this.categoryIconUrl,
  });

  /// Es una solicitud abierta (sin proveedor asignado).
  bool get isOpenRequest => providerId == null;

  /// Nombre legible del estado en espanol.
  String get statusLabel {
    switch (status) {
      case 'REQUESTED':
        return 'Solicitado';
      case 'QUOTED':
        return 'Cotizado';
      case 'ACCEPTED':
        return 'Aceptado';
      case 'PROVIDER_EN_ROUTE':
        return 'En camino';
      case 'IN_PROGRESS':
        return 'En progreso';
      case 'EVIDENCE_UPLOADED':
        return 'Evidencia subida';
      case 'COMPLETED':
        return 'Completado';
      case 'CANCELLED':
        return 'Cancelado';
      case 'DISPUTED':
        return 'En disputa';
      default:
        return status;
    }
  }

  /// Si la reserva esta activa (no completada ni cancelada).
  bool get isActive =>
      status != 'COMPLETED' &&
      status != 'CANCELLED' &&
      status != 'DISPUTED';

  /// Si la reserva esta pendiente de respuesta del proveedor.
  bool get isPending =>
      status == 'REQUESTED' || status == 'QUOTED';

  /// Si la reserva se puede cancelar.
  bool get isCancellable =>
      status != 'COMPLETED' &&
      status != 'CANCELLED' &&
      status != 'DISPUTED';
}
