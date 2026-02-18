import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../datasources/bookings_remote_datasource.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDatasource _datasource;

  BookingsRepositoryImpl(this._datasource);

  @override
  Future<Result<Booking>> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      final booking = await _datasource.createBooking(
        providerId: providerId,
        serviceId: serviceId,
        scheduledAt: scheduledAt,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> createOpenRequest({
    required String categoryId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    double? budget,
    String? notes,
  }) async {
    try {
      final booking = await _datasource.createOpenRequest(
        categoryId: categoryId,
        scheduledAt: scheduledAt,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        budget: budget,
        notes: notes,
      );
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<BookingsPage>> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final response = await _datasource.getMyBookings(
        page: page,
        limit: limit,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Result.success(BookingsPage(
        bookings: response.data,
        total: response.total,
        page: response.page,
        limit: response.limit,
        totalPages: response.totalPages,
      ));
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<BookingsPage>> getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final response = await _datasource.getProviderBookings(
        page: page,
        limit: limit,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Result.success(BookingsPage(
        bookings: response.data,
        total: response.total,
        page: response.page,
        limit: response.limit,
        totalPages: response.totalPages,
      ));
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<BookingsPage>> getOpenRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getOpenRequests(
        page: page,
        limit: limit,
      );
      return Result.success(BookingsPage(
        bookings: response.data,
        total: response.total,
        page: response.page,
        limit: response.limit,
        totalPages: response.totalPages,
      ));
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> getBooking(String id) async {
    try {
      final booking = await _datasource.getBooking(id);
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> acceptBooking(String bookingId) async {
    try {
      final booking = await _datasource.acceptBooking(bookingId);
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> rejectBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      final booking = await _datasource.rejectBooking(
        bookingId,
        reason: reason,
      );
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> startService(String bookingId) async {
    try {
      final booking = await _datasource.startService(bookingId);
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> completeService(String bookingId) async {
    try {
      final booking = await _datasource.completeService(bookingId);
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      final booking = await _datasource.cancelBooking(
        bookingId,
        reason: reason,
      );
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Booking>> claimOpenRequest(String bookingId) async {
    try {
      final booking = await _datasource.claimOpenRequest(bookingId);
      return Result.success(booking);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
