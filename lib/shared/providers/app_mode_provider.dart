import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

// ── App Mode Enum ───────────────────────────────

enum AppMode { client, provider }

// ── App Mode State ──────────────────────────────

class AppModeState {
  final AppMode mode;
  final bool isSwitching;
  final String? errorMessage;

  const AppModeState({
    this.mode = AppMode.client,
    this.isSwitching = false,
    this.errorMessage,
  });

  AppModeState copyWith({
    AppMode? mode,
    bool? isSwitching,
    String? errorMessage,
  }) {
    return AppModeState(
      mode: mode ?? this.mode,
      isSwitching: isSwitching ?? this.isSwitching,
      errorMessage: errorMessage,
    );
  }
}

// ── App Mode Notifier ───────────────────────────

class AppModeNotifier extends StateNotifier<AppModeState> {
  final Ref _ref;

  AppModeNotifier(this._ref) : super(const AppModeState()) {
    _syncFromAuth();
  }

  /// Sincroniza el modo desde el usuario autenticado.
  void _syncFromAuth() {
    final authState = _ref.read(authProvider);
    if (authState.user != null) {
      final mode = authState.user!.isProviderMode
          ? AppMode.provider
          : AppMode.client;
      state = AppModeState(mode: mode);
    }
  }

  /// Alterna entre modo cliente y proveedor llamando al API.
  Future<bool> toggleMode() async {
    state = state.copyWith(isSwitching: true, errorMessage: null);

    final success = await _ref.read(profileProvider.notifier).toggleMode();

    if (success) {
      final newMode =
          state.mode == AppMode.client ? AppMode.provider : AppMode.client;
      state = AppModeState(mode: newMode, isSwitching: false);
      return true;
    } else {
      final profileState = _ref.read(profileProvider);
      state = state.copyWith(
        isSwitching: false,
        errorMessage: profileState.errorMessage ?? 'No se pudo cambiar el modo.',
      );
      return false;
    }
  }

  /// Establece el modo directamente (para sincronizar desde login).
  void setMode(AppMode mode) {
    state = AppModeState(mode: mode);
  }
}

// ── Provider ────────────────────────────────────

final appModeProvider =
    StateNotifierProvider<AppModeNotifier, AppModeState>((ref) {
  return AppModeNotifier(ref);
});

/// Provider de conveniencia que expone solo el modo actual.
final currentAppModeProvider = Provider<AppMode>((ref) {
  return ref.watch(appModeProvider).mode;
});

/// Provider que indica si el usuario esta en modo proveedor.
final isProviderModeProvider = Provider<bool>((ref) {
  return ref.watch(currentAppModeProvider) == AppMode.provider;
});
