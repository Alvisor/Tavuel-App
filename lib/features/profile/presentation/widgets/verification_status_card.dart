import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class VerificationStatusCard extends StatelessWidget {
  final String status;
  final String? rejectionReason;

  const VerificationStatusCard({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final config = _getStatusConfig(colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: config.color,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (status == 'REJECTED' &&
                      rejectionReason != null &&
                      rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colors.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rejectionReason!,
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(AppColorsExtension colors) {
    switch (status) {
      case 'PENDING_DOCUMENTS':
        return _StatusConfig(
          color: colors.warning,
          icon: Icons.pending_actions,
          title: 'Documentos Pendientes',
          description:
              'Completa el proceso de registro subiendo tus documentos para ser verificado.',
        );
      case 'DOCUMENTS_SUBMITTED':
        return _StatusConfig(
          color: colors.warning,
          icon: Icons.upload_file,
          title: 'Documentos Enviados',
          description:
              'Tus documentos fueron enviados y estan en espera de revision.',
        );
      case 'UNDER_REVIEW':
        return _StatusConfig(
          color: colors.info,
          icon: Icons.fact_check_outlined,
          title: 'En Revision',
          description:
              'Nuestro equipo esta revisando tu informacion. Te notificaremos pronto.',
        );
      case 'APPROVED':
        return _StatusConfig(
          color: colors.success,
          icon: Icons.verified,
          title: 'Verificado',
          description: 'Tu perfil de proveedor ha sido aprobado.',
        );
      case 'REJECTED':
        return _StatusConfig(
          color: colors.error,
          icon: Icons.cancel_outlined,
          title: 'Rechazado',
          description:
              'Tu solicitud fue rechazada. Revisa los detalles y vuelve a intentar.',
        );
      default:
        return _StatusConfig(
          color: colors.textHint,
          icon: Icons.help_outline,
          title: 'Estado Desconocido',
          description: 'No pudimos determinar el estado de tu verificacion.',
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String title;
  final String description;

  const _StatusConfig({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });
}
