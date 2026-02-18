import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key used to persist the locale preference in secure storage.
const _kLocaleKey = 'app_locale';

/// Provides the current [Locale] for the app.
///
/// Defaults to Spanish (`es`). The user can change the locale via
/// [LocaleNotifier.setLocale], which persists the choice in secure storage.
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Manages the app locale and persists the preference.
class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;

  LocaleNotifier([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const Locale('es')) {
    _loadSavedLocale();
  }

  /// Supported locales for the app.
  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
  ];

  /// Loads the saved locale from secure storage on startup.
  Future<void> _loadSavedLocale() async {
    try {
      final savedLocale = await _storage.read(key: _kLocaleKey);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        final locale = Locale(savedLocale);
        if (supportedLocales.contains(locale)) {
          state = locale;
        }
      }
    } catch (_) {
      // If reading fails, keep the default (es).
    }
  }

  /// Changes the app locale and persists the preference.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    state = locale;
    try {
      await _storage.write(key: _kLocaleKey, value: locale.languageCode);
    } catch (_) {
      // Persist failure is non-critical; the locale is already applied in memory.
    }
  }

  /// Toggles between Spanish and English.
  Future<void> toggleLocale() async {
    final next = state.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    await setLocale(next);
  }
}
