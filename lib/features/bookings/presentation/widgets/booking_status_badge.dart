import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Badge que muestra el estado de una reserva con color semantico.
class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final (label, color, bgColor) = _statusConfig(colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
      ),
    );
  }

  (String, Color, Color) _statusConfig(AppColorsExtension colors) {
    switch (status) {
      case 'REQUESTED':
        return (
          'Solicitado',
          colors.statusPending,
          colors.statusPending.withOpacity(0.15),
        );
      case 'QUOTED':
        return (
          'Cotizado',
          colors.info,
          colors.info.withOpacity(0.15),
        );
      case 'ACCEPTED':
        return (
          'Aceptado',
          colors.statusConfirmed,
          colors.statusConfirmed.withOpacity(0.15),
        );
      case 'PROVIDER_EN_ROUTE':
        return (
          'En camino',
          colors.statusInProgress,
          colors.statusInProgress.withOpacity(0.15),
        );
      case 'IN_PROGRESS':
        return (
          'En progreso',
          colors.statusInProgress,
          colors.statusInProgress.withOpacity(0.15),
        );
      case 'EVIDENCE_UPLOADED':
        return (
          'Evidencia',
          colors.statusInProgress,
          colors.statusInProgress.withOpacity(0.15),
        );
      case 'COMPLETED':
        return (
          'Completado',
          colors.statusCompleted,
          colors.statusCompleted.withOpacity(0.15),
        );
      case 'CANCELLED':
        return (
          'Cancelado',
          colors.statusCancelled,
          colors.statusCancelled.withOpacity(0.15),
        );
      case 'DISPUTED':
        return (
          'En disputa',
          colors.error,
          colors.error.withOpacity(0.15),
        );
      default:
        return (
          status,
          colors.textSecondary,
          colors.surfaceVariant,
        );
    }
  }
}
