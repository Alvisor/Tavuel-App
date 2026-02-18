import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/booking.dart';
import 'booking_status_badge.dart';

/// Card que muestra el resumen de una reserva en una lista.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  /// Si es true, muestra el nombre del cliente (vista de proveedor).
  /// Si es false, muestra el nombre del proveedor (vista de cliente).
  final bool showClientName;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.showClientName = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'es_CO');
    final timeFormat = DateFormat('hh:mm a', 'es_CO');

    final String personName;
    if (showClientName) {
      personName = booking.clientName ?? 'Cliente';
    } else if (booking.isOpenRequest) {
      personName = 'Solicitud abierta';
    } else {
      personName = booking.providerName ?? 'Proveedor';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: servicio + status badge
              Row(
                children: [
                  // Icono de categoria
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.handyman,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre del servicio + categoria
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName ??
                              booking.categoryName ??
                              'Servicio',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (booking.categoryName != null)
                          Text(
                            booking.categoryName!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Nombre de la persona
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      personName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Fecha y hora
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(booking.scheduledAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(booking.scheduledAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Direccion
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.address,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Razon de cancelacion por SYSTEM
              if (booking.status == 'CANCELLED' &&
                  booking.cancelledBy == 'SYSTEM' &&
                  booking.cancellationReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.warning,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.cancellationReason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Solicitud abierta badge
              if (booking.isOpenRequest &&
                  booking.status == 'REQUESTED') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Esperando proveedor',
                    style: TextStyle(
                      color: colors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Precio cotizado (si existe)
              if (booking.quotedPrice != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'es_CO',
                        symbol: '\$',
                        decimalDigits: 0,
                      ).format(booking.quotedPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
