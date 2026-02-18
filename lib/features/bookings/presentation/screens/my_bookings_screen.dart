import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/bookings_provider.dart';
import '../widgets/booking_card.dart';

/// Pantalla principal de reservas del cliente con tabs de estado.
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  // Tabs: Todos, Pendientes, Activos, Completados, Cancelados
  static const _tabs = [
    _TabConfig(label: 'Todos', status: null),
    _TabConfig(label: 'Pendientes', status: 'REQUESTED'),
    _TabConfig(label: 'Activos', status: 'IN_PROGRESS'),
    _TabConfig(label: 'Completados', status: 'COMPLETED'),
    _TabConfig(label: 'Cancelados', status: 'CANCELLED'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    // Cargar la primera pagina
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myBookingsProvider.notifier).loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index].status;
    ref.read(myBookingsProvider.notifier).setStatusFilter(status);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myBookingsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsProvider);
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((tab) => Tab(text: tab.label))
              .toList(),
        ),
      ),
      body: _buildBody(state, colors, theme),
    );
  }

  Widget _buildBody(
    MyBookingsState state,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    // Estado de error
    if (state.errorMessage != null && state.bookings.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () {
          final status = _tabs[_tabController.index].status;
          ref.read(myBookingsProvider.notifier).loadBookings(
                statusFilter: status,
              );
        },
      );
    }

    // Estado de carga inicial
    if (state.isLoading && state.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado vacio
    if (!state.isLoading && state.bookings.isEmpty) {
      return _EmptyView(
        statusFilter: _tabs[_tabController.index].label,
      );
    }

    // Lista de reservas
    return RefreshIndicator(
      onRefresh: () async {
        final status = _tabs[_tabController.index].status;
        await ref.read(myBookingsProvider.notifier).loadBookings(
              statusFilter: status,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.bookings.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.bookings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final booking = state.bookings[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              context.push('/booking-detail/${booking.id}');
            },
          );
        },
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final String? status;

  const _TabConfig({required this.label, this.status});
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String statusFilter;

  const _EmptyView({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: colors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes servicios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando solicites un servicio, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
