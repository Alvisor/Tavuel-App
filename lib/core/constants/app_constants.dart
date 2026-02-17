/// Application-wide constants for the Tavuel app.
abstract class AppConstants {
  // ── App Info ───────────────────────────────────
  static const String appName = 'Tavuel';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ── API Configuration ──────────────────────────
  /// Base URL for the Tavuel REST API.
  static const String apiBaseUrl = _isDebug
      ? 'http://192.168.10.7:3000/v1'
      : 'https://api.tavuel.com/v1';
  static const String apiBaseUrlStaging = 'https://staging-api.tavuel.com/v1';

  static const bool _isDebug = bool.fromEnvironment('dart.vm.product') == false;

  /// WebSocket endpoint for real-time tracking and chat.
  static const String wsBaseUrl = 'wss://ws.tavuel.com';
  static const String wsBaseUrlStaging = 'wss://staging-ws.tavuel.com';

  // ── Timeouts (seconds) ─────────────────────────
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
  static const int sendTimeout = 10;

  // ── Pagination ─────────────────────────────────
  static const int defaultPageSize = 20;
  static const int searchResultsPageSize = 15;
  static const int reviewsPageSize = 10;

  // ── Image Constraints ──────────────────────────
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 80;
  static const int maxProfilePhotoSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxServicePhotoSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxPhotosPerBooking = 5;

  // ── Location (Bogota defaults) ─────────────────
  static const double bogotaLatitude = 4.7110;
  static const double bogotaLongitude = -74.0721;
  static const double defaultMapZoom = 13.0;
  static const double maxServiceRadiusKm = 30.0;

  // ── Booking ────────────────────────────────────
  static const int minBookingLeadTimeMinutes = 60;
  static const int maxFutureBookingDays = 30;
  static const int providerResponseTimeoutMinutes = 15;

  // ── Reviews ────────────────────────────────────
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // ── PQRs (Colombian regulation) ────────────────
  static const int pqrsMaxResponseDays = 15;
  static const int pqrsMaxDescriptionLength = 2000;

  // ── Secure Storage Keys ────────────────────────
  static const String keyAccessToken = 'tavuel_access_token';
  static const String keyRefreshToken = 'tavuel_refresh_token';
  static const String keyUserId = 'tavuel_user_id';
  static const String keyOnboardingComplete = 'tavuel_onboarding_complete';

  // ── Date / Time Formats ────────────────────────
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';

  // ── Service Categories ─────────────────────────
  static const List<String> serviceCategories = [
    'plomeria',
    'electricidad',
    'cerrajeria',
    'pintura',
    'limpieza',
    'jardineria',
    'carpinteria',
    'aire_acondicionado',
    'electrodomesticos',
    'mudanzas',
    'albanileria',
    'vidrieria',
    'fumigacion',
    'otros',
  ];

  // ── Colombia-Specific ──────────────────────────
  static const String countryCode = '+57';
  static const String currencyCode = 'COP';
  static const String currencySymbol = '\$';
  static const String locale = 'es_CO';
}
