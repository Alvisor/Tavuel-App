import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../../features/bookings/presentation/screens/create_booking_screen.dart';
import '../../features/bookings/presentation/screens/create_open_request_screen.dart';
import '../../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/provider_dashboard/presentation/screens/provider_dashboard_screen.dart';
import '../../features/provider_dashboard/presentation/screens/provider_requests_screen.dart';
import '../../features/provider_dashboard/presentation/screens/provider_services_screen.dart';
import '../../features/provider_onboarding/presentation/screens/onboarding_success_screen.dart';
import '../../features/provider_onboarding/presentation/screens/provider_onboarding_screen.dart';
import '../../features/provider_search/presentation/screens/provider_profile_screen.dart';
import '../../features/provider_search/presentation/screens/provider_search_screen.dart';
import '../../features/reviews/presentation/screens/create_review_screen.dart';
import '../../features/reviews/presentation/screens/provider_reviews_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

// Route path constants
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String providerSearch = '/provider-search';
  static const String bookings = '/bookings';
  static const String bookingDetail = '/booking-detail/:id';
  static const String bookingCreate = '/booking-create';
  static const String tracking = '/tracking/:bookingId';
  static const String reviews = '/reviews/:providerId';
  static const String profile = '/profile';
  static const String pqrs = '/pqrs';
  static const String pqrsCreate = '/pqrs/create';
  static const String notifications = '/notifications';

  // Provider onboarding
  static const String providerOnboarding = '/provider-onboarding';
  static const String providerOnboardingSuccess =
      '/provider-onboarding/success';

  // Provider mode tabs
  static const String providerDashboard = '/provider-dashboard';
  static const String providerMyServices = '/provider-my-services';
  static const String providerRequests = '/provider-requests';

  // Provider profile & reviews
  static const String providerProfile = '/provider-profile/:id';
  static const String createReview = '/reviews/create/:bookingId';

  // Open requests
  static const String openRequest = '/open-request';
}

// Notifier that triggers GoRouter refresh when auth state changes,
// without recreating the entire GoRouter instance.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final _authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  return _AuthChangeNotifier(ref);
});

// GoRouter provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.read(_authChangeNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,

    // Auth redirect guard
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final currentPath = state.matchedLocation;
      final isInitial = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;

      // Public routes that do not require authentication
      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // While checking auth, stay on splash
      if (isInitial && currentPath == AppRoutes.splash) {
        return null;
      }

      // Done checking: not authenticated + still on splash -> login
      if (!isAuthenticated && !isInitial && currentPath == AppRoutes.splash) {
        return AppRoutes.login;
      }

      // If user is not authenticated and trying to access a protected route
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If user is authenticated and on login/register/splash -> home or onboarding
      if (isAuthenticated &&
          (currentPath == AppRoutes.login ||
              currentPath == AppRoutes.register ||
              currentPath == AppRoutes.splash)) {
        // If user just registered and wants to be provider, go to onboarding
        final user = authState.user;
        if (currentPath == AppRoutes.register &&
            user != null &&
            user.wantsToBeProvider &&
            user.role != 'PROVIDER') {
          return AppRoutes.providerOnboarding;
        }
        return AppRoutes.home;
      }

      // Guard: si el usuario ya envió onboarding, no puede re-entrar al wizard
      if (isAuthenticated &&
          (currentPath == AppRoutes.providerOnboarding ||
              currentPath == AppRoutes.providerOnboardingSuccess)) {
        final user = authState.user;
        if (user != null &&
            user.verificationStatus != null &&
            user.verificationStatus != 'PENDING_DOCUMENTS') {
          return AppRoutes.profile;
        }
      }

      return null;
    },

    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Provider onboarding (standalone, outside bottom nav)
      GoRoute(
        path: AppRoutes.providerOnboarding,
        name: 'provider-onboarding',
        builder: (context, state) => const ProviderOnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.providerOnboardingSuccess,
        name: 'provider-onboarding-success',
        builder: (context, state) => const OnboardingSuccessScreen(),
      ),

      // Main app with Bottom Navigation
      // Branches:
      //   0: Home (client)
      //   1: Search (client)
      //   2: Bookings (client)
      //   3: Dashboard (provider)
      //   4: My Services (provider)
      //   5: Requests (provider)
      //   6: Notifications (shared)
      //   7: Profile (shared)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (client)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Search (client)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.providerSearch,
                name: 'provider-search',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return ProviderSearchScreen(
                    initialCategory: category,
                  );
                },
              ),
            ],
          ),

          // Branch 2: Bookings (client)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                name: 'bookings',
                builder: (context, state) =>
                    const MyBookingsScreen(),
              ),
            ],
          ),

          // Branch 3: Dashboard (provider)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.providerDashboard,
                name: 'provider-dashboard',
                builder: (context, state) =>
                    const ProviderDashboardScreen(),
              ),
            ],
          ),

          // Branch 4: My Services (provider)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.providerMyServices,
                name: 'provider-my-services',
                builder: (context, state) =>
                    const ProviderServicesScreen(),
              ),
            ],
          ),

          // Branch 5: Requests (provider)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.providerRequests,
                name: 'provider-requests',
                builder: (context, state) =>
                    const ProviderRequestsScreen(),
              ),
            ],
          ),

          // Branch 6: Notifications (shared)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: 'notifications',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Notificaciones'),
              ),
            ],
          ),

          // Branch 7: Profile (shared)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone routes (pushed on top of bottom nav)
      GoRoute(
        path: AppRoutes.bookingDetail,
        name: 'booking-detail',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return BookingDetailScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingCreate,
        name: 'booking-create',
        builder: (context, state) {
          final providerId =
              state.uri.queryParameters['providerId'] ?? '';
          final rawServiceId =
              state.uri.queryParameters['serviceId'];
          final serviceId =
              (rawServiceId != null && rawServiceId.isNotEmpty)
                  ? rawServiceId
                  : null;
          return CreateBookingScreen(
            providerId: providerId,
            serviceId: serviceId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tracking,
        name: 'tracking',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return _PlaceholderScreen(
            title: 'Seguimiento',
            subtitle: 'Reserva: $bookingId',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reviews,
        name: 'reviews',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return ProviderReviewsScreen(providerId: providerId);
        },
      ),
      GoRoute(
        path: AppRoutes.providerProfile,
        name: 'provider-profile',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ProviderProfileScreen(
            providerId: id,
            providerName: extra?['providerName'] as String?,
            providerAvatarUrl: extra?['providerAvatarUrl'] as String?,
            providerRating: (extra?['providerRating'] as num?)?.toDouble(),
            providerBio: extra?['providerBio'] as String?,
            categories: (extra?['categories'] as List<dynamic>?)
                ?.cast<String>(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createReview,
        name: 'create-review',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return CreateReviewScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.openRequest,
        name: 'open-request',
        builder: (context, state) =>
            const CreateOpenRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.pqrs,
        name: 'pqrs',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'PQRs'),
        routes: [
          GoRoute(
            path: 'create',
            name: 'pqrs-create',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Crear PQR'),
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Temporary placeholder screen used during initial setup.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _PlaceholderScreen({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'En construcción',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
