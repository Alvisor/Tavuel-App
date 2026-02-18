import '../../../../core/errors/failure.dart';
import '../entities/booking.dart';

/// Contrato del repositorio de reservas.
abstract class BookingsRepository {
  /// Crea una nueva reserva de servicio.
  Future<Result<Booking>> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
  });

  /// Crea una solicitud abierta (sin proveedor).
  Future<Result<Booking>> createOpenRequest({
    required String categoryId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    double? budget,
    String? notes,
  });

  /// Obtiene las reservas del cliente autenticado con paginacion y filtros.
  Future<Result<BookingsPage>> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// Obtiene las reservas del proveedor autenticado con paginacion y filtros.
  Future<Result<BookingsPage>> getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// Obtiene solicitudes abiertas (tablón para proveedores).
  Future<Result<BookingsPage>> getOpenRequests({
    int page = 1,
    int limit = 20,
  });

  /// Obtiene el detalle de una reserva por su ID.
  Future<Result<Booking>> getBooking(String id);

  /// El proveedor acepta una reserva.
  Future<Result<Booking>> acceptBooking(String bookingId);

  /// El proveedor rechaza una reserva.
  Future<Result<Booking>> rejectBooking(String bookingId, {String? reason});

  /// El proveedor marca el inicio del servicio.
  Future<Result<Booking>> startService(String bookingId);

  /// El proveedor marca el servicio como completado.
  Future<Result<Booking>> completeService(String bookingId);

  /// Cancela una reserva (cliente o proveedor).
  Future<Result<Booking>> cancelBooking(String bookingId, {String? reason});

  /// Proveedor toma una solicitud abierta.
  Future<Result<Booking>> claimOpenRequest(String bookingId);
}

/// Wrapper para respuestas paginadas de reservas.
class BookingsPage {
  final List<Booking> bookings;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BookingsPage({
    required this.bookings,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
