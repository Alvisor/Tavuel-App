import '../../../../core/api/api_client.dart';
import '../models/booking_model.dart';

/// Datasource remoto para las operaciones de reservas contra la API.
class BookingsRemoteDatasource {
  final ApiClient _apiClient;

  BookingsRemoteDatasource(this._apiClient);

  /// Crea una nueva reserva de servicio.
  Future<BookingModel> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/bookings',
      data: {
        'providerId': providerId,
        'serviceId': serviceId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene las reservas del cliente autenticado.
  Future<BookingsPageResponse> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _apiClient.get(
      '/bookings/me',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
        if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
      },
    );
    return BookingsPageResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene las reservas del proveedor autenticado.
  Future<BookingsPageResponse> getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _apiClient.get(
      '/bookings/provider',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
        if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
      },
    );
    return BookingsPageResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene el detalle de una reserva por su ID.
  Future<BookingModel> getBooking(String id) async {
    final response = await _apiClient.get('/bookings/$id');
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// El proveedor acepta una reserva.
  Future<BookingModel> acceptBooking(String bookingId) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/accept',
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// El proveedor rechaza una reserva.
  Future<BookingModel> rejectBooking(
    String bookingId, {
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/reject',
      data: {if (reason != null) 'reason': reason},
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// El proveedor marca el inicio del servicio.
  Future<BookingModel> startService(String bookingId) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/start',
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// El proveedor marca el servicio como completado.
  Future<BookingModel> completeService(String bookingId) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/complete',
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cancela una reserva (cliente o proveedor).
  Future<BookingModel> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/cancel',
      data: {if (reason != null) 'reason': reason},
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene los servicios que ofrece un proveedor.
  Future<List<ProviderServiceInfo>> getProviderServices(
      String providerId) async {
    final response = await _apiClient.get('/providers/$providerId');
    final data = response.data as Map<String, dynamic>;
    final services = data['services'] as List<dynamic>? ?? [];
    return services
        .map((e) =>
            ProviderServiceInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crea una solicitud abierta (sin proveedor).
  Future<BookingModel> createOpenRequest({
    required String categoryId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    double? budget,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/bookings',
      data: {
        'categoryId': categoryId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        if (budget != null) 'budget': budget,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene las solicitudes abiertas (tablón para proveedores).
  Future<BookingsPageResponse> getOpenRequests({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/bookings/open-requests',
      queryParameters: {'page': page, 'limit': limit},
    );
    return BookingsPageResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Proveedor toma una solicitud abierta.
  Future<BookingModel> claimOpenRequest(String bookingId) async {
    final response = await _apiClient.patch(
      '/bookings/$bookingId/claim',
    );
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene los slots ocupados de un proveedor en una fecha.
  Future<List<BusySlot>> getBusySlots(
      String providerId, String date) async {
    final response = await _apiClient.get(
      '/bookings/providers/$providerId/busy-slots',
      queryParameters: {'date': date},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => BusySlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Slot ocupado de un proveedor.
class BusySlot {
  final DateTime start;
  final DateTime end;

  const BusySlot({required this.start, required this.end});

  factory BusySlot.fromJson(Map<String, dynamic> json) {
    return BusySlot(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }
}

/// Info de un servicio ofrecido por un proveedor.
class ProviderServiceInfo {
  final String serviceId;
  final String name;
  final String? categoryName;
  final double price;

  const ProviderServiceInfo({
    required this.serviceId,
    required this.name,
    this.categoryName,
    required this.price,
  });

  factory ProviderServiceInfo.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? json;
    final category =
        service['category'] as Map<String, dynamic>?;
    return ProviderServiceInfo(
      serviceId: (json['serviceId'] as String?) ??
          (service['id'] as String? ?? ''),
      name: service['name'] as String? ?? '',
      categoryName: category?['name'] as String?,
      price: _parsePrice(json['price']),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Modelo auxiliar para parsear respuestas paginadas del backend.
class BookingsPageResponse {
  final List<BookingModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BookingsPageResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BookingsPageResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final items = json['data'] as List<dynamic>? ?? [];

    return BookingsPageResponse(
      data: items
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (meta['total'] as num?)?.toInt() ?? 0,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}
