import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_interceptors.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

// ── Dependency Injection ────────────────────────

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(ref.read(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileRemoteDatasourceProvider));
});

// ── Profile State ───────────────────────────────

class ProfileState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Profile Notifier ────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const ProfileState());

  /// Carga el perfil del usuario autenticado.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getProfile();
    result.when(
      success: (user) {
        state = ProfileState(user: user, isLoading: false);
      },
      failure: (failure) {
        state = ProfileState(
          user: state.user,
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Actualiza los datos del perfil.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.updateProfile(data);
    return result.when(
      success: (user) {
        state = ProfileState(user: user, isLoading: false);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Alterna entre modo CLIENTE y PROVEEDOR.
  Future<bool> toggleMode() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.toggleMode();
    return result.when(
      success: (user) {
        state = ProfileState(user: user, isLoading: false);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Cierra sesion del usuario.
  Future<void> logout() async {
    await _ref.read(authProvider.notifier).logout();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ────────────────────────────────────

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(profileRepositoryProvider),
    ref,
  );
});
