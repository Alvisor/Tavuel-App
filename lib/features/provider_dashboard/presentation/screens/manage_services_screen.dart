import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../provider_onboarding/domain/entities/service_category.dart';
import '../../../provider_onboarding/presentation/providers/provider_onboarding_provider.dart';
import '../../../provider_onboarding/presentation/widgets/category_selection_chip.dart';
import '../providers/provider_services_provider.dart';

/// Pantalla para gestionar las categorías de servicio del proveedor.
///
/// Reutiliza [CategorySelectionChip] del onboarding y permite al proveedor
/// seleccionar/deseleccionar categorías. Los cambios se guardan vía
/// PATCH /providers/me con serviceCategoryIds.
class ManageServicesScreen extends ConsumerStatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  ConsumerState<ManageServicesScreen> createState() =>
      _ManageServicesScreenState();
}

class _ManageServicesScreenState extends ConsumerState<ManageServicesScreen> {
  late Set<String> _selectedIds;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final selectedIdsAsync = ref.watch(mySelectedCategoryIdsFutureProvider);
    final servicesState = ref.watch(providerServicesProvider);

    // Inicializar los IDs seleccionados una sola vez cuando los datos llegan.
    if (!_initialized) {
      selectedIdsAsync.whenData((ids) {
        if (!_initialized) {
          _selectedIds = Set.from(ids);
          _initialized = true;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
        centerTitle: true,
        elevation: 0,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(colors, error.toString()),
        data: (categories) {
          if (!_initialized) {
            return selectedIdsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  _buildErrorState(colors, error.toString()),
              data: (_) => _buildCategoryList(categories, colors),
            );
          }
          return _buildCategoryList(categories, colors);
        },
      ),
      bottomNavigationBar: _initialized
          ? _buildBottomBar(colors, servicesState.isSaving)
          : null,
    );
  }

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
              'Error al cargar las categorías',
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
                ref.invalidate(serviceCategoriesProvider);
                ref.invalidate(mySelectedCategoryIdsFutureProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List<ServiceCategory> categories,
    AppColorsExtension colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header descriptivo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Selecciona las categorías de servicios que ofreces. '
            'Puedes cambiar esto en cualquier momento.',
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        // Contador de selección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${_selectedIds.length} categoría${_selectedIds.length != 1 ? 's' : ''} seleccionada${_selectedIds.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Lista de categorías
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedIds.contains(category.id);

              return CategorySelectionChip(
                category: category,
                isSelected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIds.add(category.id);
                    } else {
                      _selectedIds.remove(category.id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppColorsExtension colors, bool isSaving) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isSaving || _selectedIds.isEmpty ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.secondary,
            foregroundColor: colors.textOnSecondary,
            disabledBackgroundColor: colors.surfaceVariant,
            disabledForegroundColor: colors.textHint,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _selectedIds.isEmpty
                      ? 'Selecciona al menos una categoría'
                      : 'Guardar Cambios',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final success = await ref
        .read(providerServicesProvider.notifier)
        .updateCategories(_selectedIds.toList());

    if (!mounted) return;

    if (success) {
      // Invalidar para que se recarguen al volver
      ref.invalidate(mySelectedCategoryIdsFutureProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categorías actualizadas correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(providerServicesProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al guardar los cambios'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
