# Tavuel App

Home services platform connecting customers with trusted service providers in Bogota, Colombia. Think of it as "Uber for home services" -- plumbers, electricians, locksmiths, cleaners, and more.

## Prerequisites

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0
- Android Studio or VS Code with Flutter extension
- Firebase CLI (for push notifications)
- Google Maps API key (for maps and tracking)

## Getting Started

```bash
# Clone the repository
git clone <repo-url>
cd Tavuel-App

# Install dependencies
flutter pub get

# Run code generation (JSON serialization, Riverpod generators)
dart run build_runner build --delete-conflicting-outputs

# Run the app in debug mode
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp.router configuration
│   ├── routes/
│   │   └── app_router.dart      # GoRouter routes and auth guard
│   └── theme/
│       └── app_theme.dart       # ThemeData, colors, typography
├── core/
│   ├── api/
│   │   ├── api_client.dart      # Dio HTTP client with interceptors
│   │   └── api_interceptors.dart # Auth token interceptor
│   ├── constants/
│   │   └── app_constants.dart   # App-wide constants
│   ├── errors/
│   │   ├── app_exception.dart   # Custom exception classes
│   │   └── failure.dart         # Failure class and Result type
│   └── utils/
│       └── validators.dart      # Form validators (email, phone, etc.)
├── features/
│   ├── auth/                    # Login, register, password reset
│   ├── bookings/                # Booking CRUD and listing
│   ├── home/                    # Home dashboard
│   ├── provider_search/         # Search and filter providers
│   ├── tracking/                # Real-time GPS tracking
│   ├── reviews/                 # Ratings and reviews
│   ├── pqrs/                    # PQRs (Colombian regulation)
│   ├── notifications/           # Push notifications
│   ├── chat/                    # In-app messaging
│   └── profile/                 # User profile management
├── shared/
│   ├── models/                  # Shared data models
│   ├── widgets/                 # Reusable UI components
│   └── providers/               # Shared Riverpod providers
├── l10n/
│   └── app_es.arb               # Spanish localization
└── assets/                      # Images, fonts, icons
```

## Architecture

The app follows a **feature-first** architecture with **Riverpod** for state management:

- **Features**: Each feature is self-contained with its own screens, providers, repositories, and models.
- **Core**: Shared infrastructure (API client, error handling, validators).
- **Shared**: Reusable widgets, models, and providers used across features.

### State Management

- **Riverpod** for dependency injection and reactive state.
- Providers are scoped per feature and composed from core providers.

### Navigation

- **GoRouter** for declarative routing with auth guards.
- Routes are defined centrally in `app_router.dart`.

### Networking

- **Dio** for HTTP requests with automatic token management.
- JWT access tokens stored in **flutter_secure_storage**.
- Automatic token refresh on 401 responses.
- **Socket.IO** for real-time features (tracking, chat).

### Error Handling

- Custom exception hierarchy (`AppException`, `NetworkException`, etc.).
- `Result<T>` type for functional error handling without exceptions in business logic.
- `Failure` classes for typed error representation.

## Key Dependencies

| Package                  | Purpose                          |
|--------------------------|----------------------------------|
| flutter_riverpod         | State management & DI            |
| dio                      | HTTP client                      |
| go_router                | Declarative routing              |
| firebase_core            | Firebase initialization          |
| firebase_messaging       | Push notifications               |
| google_sign_in           | Google OAuth login               |
| google_maps_flutter      | Maps for tracking                |
| geolocator               | GPS location                     |
| socket_io_client         | Real-time WebSocket              |
| flutter_secure_storage   | Secure token storage             |
| cached_network_image     | Image caching                    |
| image_picker             | Camera/gallery access            |
| shimmer                  | Loading skeleton UI              |
| flutter_rating_bar       | Star ratings                     |
| json_serializable        | JSON serialization (codegen)     |

## Environment Configuration

Create a `.env` file in the project root (not committed to git):

```
API_BASE_URL=https://api.tavuel.com/v1
WS_BASE_URL=wss://ws.tavuel.com
GOOGLE_MAPS_API_KEY=your_key_here
```

## Localization

The app is localized in Spanish (Colombia) as the primary language. Localization files are in `lib/l10n/` using Flutter's ARB format.

## Colombian-Specific Features

- **PQRs**: Petitions, Complaints, Claims, and Suggestions system as required by Colombian consumer protection law.
- **Cedula validation**: Colombian national ID number validation.
- **Phone format**: Colombian mobile numbers (+57 3XX XXX XXXX).
- **Currency**: Colombian Pesos (COP) formatting.
- **Location**: Default map centered on Bogota (4.7110, -74.0721).

## Running Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/

# Test with coverage
flutter test --coverage
```

## Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```
