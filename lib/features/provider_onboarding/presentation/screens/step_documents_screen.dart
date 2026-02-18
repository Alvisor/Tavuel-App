import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/document_upload_card.dart';

/// Paso 3: Subida de documentos de verificacion.
///
/// Muestra una lista de 6 documentos requeridos. Cada uno permite
/// seleccionar imagen desde camara o galeria y muestra el estado
/// de subida actual.
class StepDocumentsScreen extends ConsumerStatefulWidget {
  const StepDocumentsScreen({super.key});

  @override
  ConsumerState<StepDocumentsScreen> createState() =>
      _StepDocumentsScreenState();
}

class _StepDocumentsScreenState extends ConsumerState<StepDocumentsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingWizardProvider);
    final documents = state.documents;
    final uploadProgress = state.uploadProgress;
    final colors = AppColors.of(context);

    final uploadedCount = documents.length;
    final totalRequired = DocumentTypeConfig.requiredDocuments.length;

    return Column(
      children: [
        // Contenido scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documentos de verificacion',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sube los siguientes documentos para verificar tu identidad. Asegurate de que las fotos sean claras y legibles.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progreso
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: totalRequired > 0
                                    ? uploadedCount / totalRequired
                                    : 0,
                                backgroundColor: colors.surfaceVariant,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        colors.success),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$uploadedCount/$totalRequired',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de documentos
                ...DocumentTypeConfig.requiredDocuments.map((config) {
                  final doc = documents
                      .where((d) => d.type == config.type)
                      .firstOrNull;
                  final progress = uploadProgress[config.type];

                  return DocumentUploadCard(
                    config: config,
                    document: doc,
                    uploadProgress: progress,
                    onUpload: (filePath, type) {
                      ref
                          .read(onboardingWizardProvider.notifier)
                          .uploadDocument(
                            filePath: filePath,
                            documentType: type,
                          );
                    },
                  );
                }),

                const SizedBox(height: 16),

                // Nota informativa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tus documentos seran revisados por un administrador. Este proceso puede tomar de 24 a 48 horas.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Boton inferior fijo
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
                onPressed: _canContinue(documents, uploadProgress)
                    ? () {
                        ref
                            .read(onboardingWizardProvider.notifier)
                            .nextStep();
                      }
                    : null,
                child: const Text('Siguiente'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Verifica si se puede continuar: todos los documentos subidos y
  /// sin subidas en progreso.
  bool _canContinue(
    List documents,
    Map<String, double> uploadProgress,
  ) {
    if (uploadProgress.isNotEmpty) return false;
    final requiredTypes =
        DocumentTypeConfig.requiredDocuments.map((c) => c.type).toSet();
    final uploadedTypes = documents.map((d) => d.type).toSet();
    return requiredTypes.difference(uploadedTypes).isEmpty;
  }
}
