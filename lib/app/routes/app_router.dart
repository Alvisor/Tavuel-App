import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
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

    // Auth redirect guard — reads auth state on each evaluation
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

      // Done checking: not authenticated + still on splash → login
      if (!isAuthenticated && !isInitial && currentPath == AppRoutes.splash) {
        return AppRoutes.login;
      }

      // If user is not authenticated and trying to access a protected route
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If user is authenticated and on login/register/splash → home
      if (isAuthenticated &&
          (currentPath == AppRoutes.login ||
              currentPath == AppRoutes.register ||
              currentPath == AppRoutes.splash)) {
        return AppRoutes.home;
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

      // Main app with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.providerSearch,
                name: 'provider-search',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return _PlaceholderScreen(
                    title: 'Buscar Proveedor',
                    subtitle:
                        category != null ? 'Categoría: $category' : null,
                  );
                },
              ),
            ],
          ),

          // Tab 2: Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                name: 'bookings',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Mis Servicios'),
              ),
            ],
          ),

          // Tab 3: Notifications
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

          // Tab 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => _ProfilePlaceholder(
                  onLogout: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
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
          return _PlaceholderScreen(
            title: 'Detalle de Reserva',
            subtitle: 'ID: $bookingId',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingCreate,
        name: 'booking-create',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Crear Reserva'),
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
          return _PlaceholderScreen(
            title: 'Resenas',
            subtitle: 'Proveedor: $providerId',
          );
        },
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

/// Profile placeholder with logout button.
class _ProfilePlaceholder extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfilePlaceholder({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Mi Perfil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'En construcción',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
