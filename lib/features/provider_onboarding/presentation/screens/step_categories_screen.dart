import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/category_selection_chip.dart';

/// Paso 2: Selección de categorías de servicio.
///
/// Muestra una lista de categorías cargadas desde el API como cards
/// seleccionables. El usuario puede seleccionar múltiples categorías.
class StepCategoriesScreen extends ConsumerStatefulWidget {
  const StepCategoriesScreen({super.key});

  @override
  ConsumerState<StepCategoriesScreen> createState() =>
      _StepCategoriesScreenState();
}

class _StepCategoriesScreenState extends ConsumerState<StepCategoriesScreen>
    with AutomaticKeepAliveClientMixin {
  late Set<String> _selectedIds;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedIds =
        Set.from(ref.read(onboardingWizardProvider).selectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingWizardProvider);
    final categories = state.categories;
    final colors = AppColors.of(context);

    return Column(
      children: [
        // Contenido scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  '¿Qué servicios ofreces?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona las categorías de los servicios que deseas ofrecer. Puedes elegir varias.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Contador de selección
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _selectedIds.isEmpty
                        ? 'Ninguna seleccionada'
                        : '${_selectedIds.length} seleccionada${_selectedIds.length != 1 ? 's' : ''}',
                    key: ValueKey(_selectedIds.length),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedIds.isNotEmpty
                          ? colors.primary
                          : colors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de categorías
                if (categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: colors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Cargando categorías...',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...categories.map((category) {
                    final isSelected = _selectedIds.contains(category.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CategorySelectionChip(
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
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),

        // Botón inferior fijo
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.onBackground.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading || _selectedIds.isEmpty
                    ? null
                    : _onSave,
                child: state.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.textOnPrimary,
                        ),
                      )
                    : const Text('Siguiente'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    final colors = AppColors.of(context);

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Debes seleccionar al menos una categoría.'),
          backgroundColor: colors.warning,
        ),
      );
      return;
    }

    final success = await ref
        .read(onboardingWizardProvider.notifier)
        .saveCategoriesStep(_selectedIds.toList());

    if (success && mounted) {
      ref.read(onboardingWizardProvider.notifier).nextStep();
    }
  }
}
