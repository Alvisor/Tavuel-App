import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Route path constants
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String providerSearch = '/provider-search';
  static const String bookingDetail = '/booking-detail/:id';
  static const String bookingCreate = '/booking-create';
  static const String tracking = '/tracking/:bookingId';
  static const String reviews = '/reviews/:providerId';
  static const String profile = '/profile';
  static const String pqrs = '/pqrs';
  static const String pqrsCreate = '/pqrs/create';
  static const String notifications = '/notifications';
}

// Auth state provider — replace with real auth state logic
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

// GoRouter provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Auth redirect guard
    redirect: (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;

      // Public routes that do not require authentication
      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // If user is not authenticated and trying to access a protected route
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If user is authenticated and on login/register, redirect to home
      if (isAuthenticated &&
          (currentPath == AppRoutes.login ||
              currentPath == AppRoutes.register)) {
        return AppRoutes.home;
      }

      // If user is authenticated and on splash, redirect to home
      if (isAuthenticated && currentPath == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const _PlaceholderScreen(title: 'Tavuel'),
      ),

      // Authentication
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Iniciar Sesion'),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Registrarse'),
      ),

      // Home / Dashboard
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Inicio'),
      ),

      // Provider search
      GoRoute(
        path: AppRoutes.providerSearch,
        name: 'provider-search',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return _PlaceholderScreen(
            title: 'Buscar Proveedor',
            subtitle: category != null ? 'Categoria: $category' : null,
          );
        },
      ),

      // Booking detail
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

      // Booking create
      GoRoute(
        path: AppRoutes.bookingCreate,
        name: 'booking-create',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Crear Reserva'),
      ),

      // Real-time tracking
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

      // Reviews
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

      // Profile
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Mi Perfil'),
      ),

      // PQRs (Petitions, Complaints, Claims - Colombian standard)
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

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Notificaciones'),
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
              'Pagina no encontrada',
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
/// Replace each route's builder with the actual feature screen.
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
              'En construccion',
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
