import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/provider_services_provider.dart';

/// Pantalla principal de servicios del proveedor.
///
/// Muestra los servicios actuales agrupados por categoría.
/// Si no hay servicios, muestra un estado vacío con botón para agregar.
/// Permite pull-to-refresh y navegar a la pantalla de gestión de categorías.
class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState
    extends ConsumerState<ProviderServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar servicios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerServicesProvider.notifier).loadMyServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = ref.watch(providerServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios y Precios'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Gestionar categorías',
            onPressed: () => _navigateToManage(),
          ),
        ],
      ),
      body: state.isLoading && state.services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.services.isEmpty
              ? _buildErrorState(colors, state.error!)
              : state.services.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildServicesList(colors, state),
    );
  }

  void _navigateToManage() {
    context.push(AppRoutes.manageServices);
  }

  // ──────────────────────────────────────────────
  // Estado vacío
  // ──────────────────────────────────────────────

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.handyman_outlined,
                size: 52,
                color: colors.textHint,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Sin servicios configurados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Descripción
            Text(
              'Agrega los servicios que ofreces con sus precios para que los clientes puedan encontrarte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textHint,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Botón de agregar
            ElevatedButton.icon(
              onPressed: () => _navigateToManage(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.textOnSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Estado de error
  // ──────────────────────────────────────────────

  Widget _buildErrorState(AppColorsExtension colors, String error) {
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
              'Error al cargar los servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(providerServicesProvider.notifier).loadMyServices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Lista de servicios agrupados por categoría
  // ──────────────────────────────────────────────

  Widget _buildServicesList(
    AppColorsExtension colors,
    ProviderServicesState state,
  ) {
    final grouped = state.servicesByCategory;
    final categoryNames = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(providerServicesProvider.notifier).loadMyServices(),
      color: colors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final categoryName = categoryNames[index];
          final services = grouped[categoryName]!;

          return _buildCategoryGroup(colors, categoryName, services);
        },
      ),
    );
  }

  Widget _buildCategoryGroup(
    AppColorsExtension colors,
    String categoryName,
    List<ProviderServiceItem> services,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de categoría
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${services.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de servicios en la categoría
          ...services.map((service) => _buildServiceCard(colors, service)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    AppColorsExtension colors,
    ProviderServiceItem service,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: service.isActive
              ? colors.surfaceVariant
              : colors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Indicador de estado
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: service.isActive ? colors.success : colors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Nombre del servicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (!service.isActive)
                    Text(
                      'Inactivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Precio
            if (service.price > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${_formatPrice(service.price)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.success,
                  ),
                ),
              )
            else
              Text(
                'Sin precio',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
  }
}
