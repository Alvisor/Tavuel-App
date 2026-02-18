import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/availability_slot.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/document_upload_card.dart';

/// Paso 6: Revision y envio para verificacion.
///
/// Muestra un resumen de todos los pasos completados anteriormente
/// con indicadores de estado. Incluye un boton para enviar la solicitud
/// que solo se habilita cuando todos los pasos estan completos.
class StepReviewSubmitScreen extends ConsumerWidget {
  const StepReviewSubmitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingWizardProvider);
    final status = state.onboardingStatus;
    final colors = AppColors.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titulo
                Text(
                  'Revisa tu solicitud',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifica que toda la informacion sea correcta antes de enviar tu solicitud de verificacion.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Progreso general
                _buildProgressCard(status, colors),
                const SizedBox(height: 16),

                // Paso 1: Perfil
                _buildReviewSection(
                  context: context,
                  ref: ref,
                  colors: colors,
                  step: 0,
                  icon: Icons.person,
                  title: 'Perfil',
                  isComplete: status.profileComplete,
                  children: [
                    if (state.bio.isNotEmpty) ...[
                      _buildInfoRow('Descripcion', state.bio, colors),
                      const SizedBox(height: 8),
                    ],
                    if (state.address.isNotEmpty)
                      _buildInfoRow('Direccion', state.address, colors),
                  ],
                ),
                const SizedBox(height: 12),

                // Paso 2: Categorias
                _buildReviewSection(
                  context: context,
                  ref: ref,
                  colors: colors,
                  step: 1,
                  icon: Icons.category,
                  title: 'Categorias',
                  isComplete: status.categoriesSelected,
                  children: [
                    if (state.selectedCategoryIds.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: state.categories
                            .where((c) =>
                                state.selectedCategoryIds.contains(c.id))
                            .map((c) => Chip(
                                  label: Text(
                                    c.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor:
                                      colors.primaryLight.withOpacity(0.2),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      )
                    else
                      Text(
                        'Sin categorias seleccionadas',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textHint,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paso 3: Documentos
                _buildReviewSection(
                  context: context,
                  ref: ref,
                  colors: colors,
                  step: 2,
                  icon: Icons.description,
                  title: 'Documentos',
                  isComplete: status.documentsUploaded,
                  children: [
                    Text(
                      '${state.documents.length}/${DocumentTypeConfig.requiredDocuments.length} documentos subidos',
                      style: TextStyle(
                        fontSize: 13,
                        color: state.documents.length ==
                                DocumentTypeConfig.requiredDocuments.length
                            ? colors.success
                            : colors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paso 4: Banco
                _buildReviewSection(
                  context: context,
                  ref: ref,
                  colors: colors,
                  step: 3,
                  icon: Icons.account_balance,
                  title: 'Cuenta bancaria',
                  isComplete: status.bankAccountSet,
                  children: [
                    if (state.bankAccount != null) ...[
                      _buildInfoRow(
                          'Banco', state.bankAccount!.bankName, colors),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                          'Titular', state.bankAccount!.accountHolder, colors),
                    ] else
                      Text(
                        'Sin cuenta configurada',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textHint,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paso 5: Disponibilidad
                _buildReviewSection(
                  context: context,
                  ref: ref,
                  colors: colors,
                  step: 4,
                  icon: Icons.schedule,
                  title: 'Disponibilidad',
                  isComplete: status.availabilitySet,
                  children: [
                    if (state.availability.isNotEmpty) ...[
                      Text(
                        _buildAvailabilitySummary(state.availability),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ] else
                      Text(
                        'Sin horarios configurados',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textHint,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nota
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colors.info,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Al enviar tu solicitud, un administrador revisara '
                          'tu informacion y documentos. Este proceso normalmente '
                          'toma de 24 a 48 horas.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Boton enviar
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
                onPressed: state.isLoading
                    ? null
                    : () => _onSubmit(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                ),
                child: state.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.textOnSecondary,
                        ),
                      )
                    : const Text('Enviar para verificacion'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
      onboardingStatus, AppColorsExtension colors) {
    final completedSteps = onboardingStatus.completedSteps as int;
    final totalSteps = onboardingStatus.totalSteps as int;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Indicador circular
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: colors.textOnPrimary.withOpacity(0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colors.textOnPrimary),
                ),
                Center(
                  child: Text(
                    '$completedSteps/$totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completedSteps == totalSteps
                      ? 'Todo listo!'
                      : 'Progreso del registro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedSteps == totalSteps
                      ? 'Ya puedes enviar tu solicitud.'
                      : 'Completa los pasos faltantes para enviar.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required BuildContext context,
    required WidgetRef ref,
    required AppColorsExtension colors,
    required int step,
    required IconData icon,
    required String title,
    required bool isComplete,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          ref.read(onboardingWizardProvider.notifier).goToStep(step);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono estado
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? colors.success.withOpacity(0.1)
                          : colors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle : Icons.pending,
                      size: 18,
                      color:
                          isComplete ? colors.success : colors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Titulo
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  // Indicador de editar
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: colors.textHint,
                  ),
                ],
              ),
              if (children.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ...children,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, AppColorsExtension colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: colors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _buildAvailabilitySummary(List<AvailabilitySlot> availability) {
    final dayNames = <String>[];
    final seenDays = <int>{};
    for (final slot in availability) {
      if (!seenDays.contains(slot.dayOfWeek)) {
        seenDays.add(slot.dayOfWeek);
        dayNames.add(slot.dayName);
      }
    }
    return dayNames.join(', ');
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(onboardingWizardProvider.notifier)
        .submitForVerification();

    if (success && context.mounted) {
      context.go(AppRoutes.providerOnboardingSuccess);
    }
  }
}
