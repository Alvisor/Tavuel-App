import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../data/datasources/bookings_remote_datasource.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/bookings_repository.dart';

// Re-export para uso en screens
export '../../data/datasources/bookings_remote_datasource.dart'
    show ProviderServiceInfo, BusySlot;

// ── Dependency Injection ────────────────────────

final bookingsRemoteDatasourceProvider =
    Provider<BookingsRemoteDatasource>((ref) {
  return BookingsRemoteDatasource(ref.read(apiClientProvider));
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepositoryImpl(
    ref.read(bookingsRemoteDatasourceProvider),
  );
});

// ── My Bookings (Client) State ──────────────────

class MyBookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;
  final String? errorMessage;

  const MyBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
    this.errorMessage,
  });

  MyBookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
    String? errorMessage,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage,
    );
  }
}

// ── My Bookings Notifier ────────────────────────

class MyBookingsNotifier extends StateNotifier<MyBookingsState> {
  final BookingsRepository _repository;

  MyBookingsNotifier(this._repository)
      : super(const MyBookingsState());

  /// Carga la primera pagina de reservas del cliente.
  Future<void> loadBookings({String? statusFilter}) async {
    state = MyBookingsState(
      isLoading: true,
      statusFilter: statusFilter,
    );

    final result = await _repository.getMyBookings(
      page: 1,
      limit: AppConstants.defaultPageSize,
      status: statusFilter,
    );

    result.when(
      success: (page) {
        state = MyBookingsState(
          bookings: page.bookings,
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: 1,
          statusFilter: statusFilter,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Carga la siguiente pagina de reservas.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getMyBookings(
      page: nextPage,
      limit: AppConstants.defaultPageSize,
      status: state.statusFilter,
    );

    result.when(
      success: (page) {
        state = state.copyWith(
          bookings: [...state.bookings, ...page.bookings],
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: nextPage,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Cambia el filtro de estado y recarga.
  Future<void> setStatusFilter(String? status) async {
    await loadBookings(statusFilter: status);
  }
}

// ── Provider Bookings State ─────────────────────

class ProviderBookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;
  final String? errorMessage;

  const ProviderBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
    this.errorMessage,
  });

  ProviderBookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
    String? errorMessage,
  }) {
    return ProviderBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage,
    );
  }
}

class ProviderBookingsNotifier
    extends StateNotifier<ProviderBookingsState> {
  final BookingsRepository _repository;

  ProviderBookingsNotifier(this._repository)
      : super(const ProviderBookingsState());

  Future<void> loadBookings({String? statusFilter}) async {
    state = ProviderBookingsState(
      isLoading: true,
      statusFilter: statusFilter,
    );

    final result = await _repository.getProviderBookings(
      page: 1,
      limit: AppConstants.defaultPageSize,
      status: statusFilter,
    );

    result.when(
      success: (page) {
        state = ProviderBookingsState(
          bookings: page.bookings,
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: 1,
          statusFilter: statusFilter,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getProviderBookings(
      page: nextPage,
      limit: AppConstants.defaultPageSize,
      status: state.statusFilter,
    );

    result.when(
      success: (page) {
        state = state.copyWith(
          bookings: [...state.bookings, ...page.bookings],
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: nextPage,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> setStatusFilter(String? status) async {
    await loadBookings(statusFilter: status);
  }
}

// ── Create Booking State ────────────────────────

class CreateBookingState {
  final bool isSubmitting;
  final bool isSuccess;
  final Booking? createdBooking;
  final String? errorMessage;

  const CreateBookingState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.createdBooking,
    this.errorMessage,
  });

  CreateBookingState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    Booking? createdBooking,
    String? errorMessage,
  }) {
    return CreateBookingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      createdBooking: createdBooking ?? this.createdBooking,
      errorMessage: errorMessage,
    );
  }
}

class CreateBookingNotifier extends StateNotifier<CreateBookingState> {
  final BookingsRepository _repository;

  CreateBookingNotifier(this._repository)
      : super(const CreateBookingState());

  Future<bool> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      isSuccess: false,
    );

    final result = await _repository.createBooking(
      providerId: providerId,
      serviceId: serviceId,
      scheduledAt: scheduledAt,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );

    return result.when(
      success: (booking) {
        state = CreateBookingState(
          isSuccess: true,
          createdBooking: booking,
        );
        return true;
      },
      failure: (failure) {
        state = CreateBookingState(errorMessage: failure.message);
        return false;
      },
    );
  }

  void reset() {
    state = const CreateBookingState();
  }
}

// ── Booking Action State (accept, reject, start, complete, cancel) ──

class BookingActionState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const BookingActionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  BookingActionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return BookingActionState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class BookingActionNotifier extends StateNotifier<BookingActionState> {
  final BookingsRepository _repository;

  BookingActionNotifier(this._repository)
      : super(const BookingActionState());

  Future<bool> accept(String bookingId) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.acceptBooking(bookingId);
    return _handleResult(result);
  }

  Future<bool> reject(String bookingId, {String? reason}) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.rejectBooking(
      bookingId,
      reason: reason,
    );
    return _handleResult(result);
  }

  Future<bool> start(String bookingId) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.startService(bookingId);
    return _handleResult(result);
  }

  Future<bool> complete(String bookingId) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.completeService(bookingId);
    return _handleResult(result);
  }

  Future<bool> cancel(String bookingId, {String? reason}) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.cancelBooking(
      bookingId,
      reason: reason,
    );
    return _handleResult(result);
  }

  bool _handleResult(Result<Booking> result) {
    return result.when(
      success: (_) {
        state = const BookingActionState(isSuccess: true);
        return true;
      },
      failure: (failure) {
        state = BookingActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  void reset() {
    state = const BookingActionState();
  }
}

// ── Riverpod Providers ──────────────────────────

/// Provider para las reservas del cliente autenticado.
final myBookingsProvider =
    StateNotifierProvider<MyBookingsNotifier, MyBookingsState>(
  (ref) {
    return MyBookingsNotifier(ref.read(bookingsRepositoryProvider));
  },
);

/// Provider para las reservas del proveedor autenticado.
final providerBookingsProvider =
    StateNotifierProvider<ProviderBookingsNotifier, ProviderBookingsState>(
  (ref) {
    return ProviderBookingsNotifier(
      ref.read(bookingsRepositoryProvider),
    );
  },
);

/// Provider para crear una nueva reserva.
final createBookingProvider =
    StateNotifierProvider<CreateBookingNotifier, CreateBookingState>(
  (ref) {
    return CreateBookingNotifier(ref.read(bookingsRepositoryProvider));
  },
);

/// Provider para acciones sobre una reserva (aceptar, rechazar, etc.)
final bookingActionProvider =
    StateNotifierProvider<BookingActionNotifier, BookingActionState>(
  (ref) {
    return BookingActionNotifier(ref.read(bookingsRepositoryProvider));
  },
);

/// Provider para obtener el detalle de una reserva por ID.
final bookingDetailProvider =
    FutureProvider.family<Booking, String>((ref, bookingId) async {
  final repository = ref.read(bookingsRepositoryProvider);
  final result = await repository.getBooking(bookingId);
  return result.when(
    success: (booking) => booking,
    failure: (failure) => throw Exception(failure.message),
  );
});

/// Provider para obtener los servicios de un proveedor.
final providerServicesProvider = FutureProvider.family<
    List<ProviderServiceInfo>, String>((ref, providerId) async {
  final datasource = ref.read(bookingsRemoteDatasourceProvider);
  return datasource.getProviderServices(providerId);
});

/// Provider para obtener los slots ocupados de un proveedor en una fecha.
/// Key: "providerId|YYYY-MM-DD"
final busySlotsProvider =
    FutureProvider.family<List<BusySlot>, String>((ref, key) async {
  final parts = key.split('|');
  if (parts.length != 2) return [];
  final providerId = parts[0];
  final date = parts[1];
  final datasource = ref.read(bookingsRemoteDatasourceProvider);
  return datasource.getBusySlots(providerId, date);
});

// ── Open Requests State ─────────────────────────

class OpenRequestsState {
  final List<Booking> bookings;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  const OpenRequestsState({
    this.bookings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  OpenRequestsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return OpenRequestsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

class OpenRequestsNotifier extends StateNotifier<OpenRequestsState> {
  final BookingsRepository _repository;

  OpenRequestsNotifier(this._repository)
      : super(const OpenRequestsState());

  Future<void> loadRequests() async {
    state = const OpenRequestsState(isLoading: true);

    final result = await _repository.getOpenRequests(page: 1);

    result.when(
      success: (page) {
        state = OpenRequestsState(
          bookings: page.bookings,
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: 1,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getOpenRequests(page: nextPage);

    result.when(
      success: (page) {
        state = state.copyWith(
          bookings: [...state.bookings, ...page.bookings],
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: nextPage,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}

/// Provider para las solicitudes abiertas (tablón de proveedores).
final openRequestsProvider =
    StateNotifierProvider<OpenRequestsNotifier, OpenRequestsState>(
  (ref) {
    return OpenRequestsNotifier(ref.read(bookingsRepositoryProvider));
  },
);

// ── Claim Open Request Notifier ──────────────────

class ClaimRequestNotifier extends StateNotifier<BookingActionState> {
  final BookingsRepository _repository;

  ClaimRequestNotifier(this._repository)
      : super(const BookingActionState());

  Future<bool> claim(String bookingId) async {
    state = const BookingActionState(isLoading: true);
    final result = await _repository.claimOpenRequest(bookingId);
    return result.when(
      success: (_) {
        state = const BookingActionState(isSuccess: true);
        return true;
      },
      failure: (failure) {
        state = BookingActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  void reset() {
    state = const BookingActionState();
  }
}

/// Provider para reclamar una solicitud abierta.
final claimRequestProvider =
    StateNotifierProvider<ClaimRequestNotifier, BookingActionState>(
  (ref) {
    return ClaimRequestNotifier(ref.read(bookingsRepositoryProvider));
  },
);

// ── Create Open Request State ───────────────────

class CreateOpenRequestNotifier extends StateNotifier<CreateBookingState> {
  final BookingsRepository _repository;

  CreateOpenRequestNotifier(this._repository)
      : super(const CreateBookingState());

  Future<bool> createOpenRequest({
    required String categoryId,
    required DateTime scheduledAt,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    double? budget,
    String? notes,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      isSuccess: false,
    );

    final result = await _repository.createOpenRequest(
      categoryId: categoryId,
      scheduledAt: scheduledAt,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      budget: budget,
      notes: notes,
    );

    return result.when(
      success: (booking) {
        state = CreateBookingState(
          isSuccess: true,
          createdBooking: booking,
        );
        return true;
      },
      failure: (failure) {
        state = CreateBookingState(errorMessage: failure.message);
        return false;
      },
    );
  }

  void reset() {
    state = const CreateBookingState();
  }
}

/// Provider para crear una solicitud abierta.
final createOpenRequestProvider =
    StateNotifierProvider<CreateOpenRequestNotifier, CreateBookingState>(
  (ref) {
    return CreateOpenRequestNotifier(
      ref.read(bookingsRepositoryProvider),
    );
  },
);
