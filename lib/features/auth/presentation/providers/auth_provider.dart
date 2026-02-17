import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_interceptors.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// ── Dependency Injection ────────────────────────

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDatasourceProvider),
    SecureStorageHelper(ref),
  );
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.read(authRepositoryProvider));
});

// ── Auth State ──────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ── Auth Notifier ───────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthNotifier(this._repository, this._loginUsecase, this._registerUsecase)
      : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.getCurrentUser();
    result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      },
      failure: (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _loginUsecase(email: email, password: password);
    return result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
      failure: (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _registerUsecase(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    return result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
      failure: (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> googleSignIn() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.googleSignIn();
    return result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
      failure: (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(loginUsecaseProvider),
    ref.read(registerUsecaseProvider),
  );
});
