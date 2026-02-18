import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/providers/app_mode_provider.dart';
import '../../domain/entities/booking.dart';
import '../providers/bookings_provider.dart';
import '../widgets/booking_status_badge.dart';

/// Pantalla de detalle de una reserva con informacion completa y acciones.
class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reserva')),
      body: bookingAsync.when(
        data: (booking) => _BookingDetailBody(
          booking: booking,
          bookingId: bookingId,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(bookingDetailProvider(bookingId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingDetailBody extends ConsumerWidget {
  final Booking booking;
  final String bookingId;

  const _BookingDetailBody({
    required this.booking,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isProvider = ref.watch(isProviderModeProvider);
    final actionState = ref.watch(bookingActionProvider);
    final dateFormat = DateFormat('EEEE dd MMMM yyyy', 'es_CO');
    final timeFormat = DateFormat('hh:mm a', 'es_CO');
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bookingDetailProvider(bookingId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y servicio
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName ?? 'Servicio',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        BookingStatusBadge(status: booking.status),
                      ],
                    ),
                    if (booking.categoryName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        booking.categoryName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      booking.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fecha, hora y direccion
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: dateFormat.format(booking.scheduledAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.access_time_outlined,
                      label: 'Hora',
                      value: timeFormat.format(booking.scheduledAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Dirección',
                      value: booking.address,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Persona (proveedor o cliente segun el modo)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.primaryLight.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isProvider ? 'Cliente' : 'Proveedor',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isProvider
                                ? (booking.clientName ?? 'Cliente')
                                : (booking.providerName ?? 'Proveedor'),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    // Boton de llamar si esta activo
                    if (booking.isActive)
                      IconButton(
                        onPressed: () {
                          // TODO: Implementar llamada telefonica
                        },
                        icon: Icon(
                          Icons.phone_outlined,
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Precio cotizado
            if (booking.quotedPrice != null) ...[
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cotización',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.attach_money,
                        label: 'Precio',
                        value: currencyFormat.format(booking.quotedPrice),
                      ),
                      if (booking.quotedMaterials != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.build_outlined,
                          label: 'Materiales',
                          value: currencyFormat.format(
                            booking.quotedMaterials,
                          ),
                        ),
                      ],
                      if (booking.estimatedDuration != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.timer_outlined,
                          label: 'Duración est.',
                          value:
                              '${booking.estimatedDuration} min',
                        ),
                      ],
                      if (booking.quoteNote != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.note_outlined,
                          label: 'Nota',
                          value: booking.quoteNote!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Razon de cancelacion
            if (booking.status == 'CANCELLED' &&
                booking.cancellationReason != null) ...[
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: colors.statusCancelled.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: colors.statusCancelled,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Motivo de cancelación',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.statusCancelled,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.cancellationReason!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Acciones segun el estado y el modo (proveedor/cliente)
            if (actionState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildActions(context, ref, isProvider, colors),

            // Mensaje de error de acciones
            if (actionState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                actionState.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Boton para dejar resena si esta completado y es cliente
            if (booking.status == 'COMPLETED' && !isProvider) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/reviews/create/${booking.id}');
                  },
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Dejar reseña'),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    bool isProvider,
    AppColorsExtension colors,
  ) {
    final actions = <Widget>[];

    if (isProvider) {
      // Acciones del proveedor
      if (booking.status == 'REQUESTED' || booking.status == 'QUOTED') {
        actions.addAll([
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onAccept(context, ref),
              child: const Text('Aceptar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onReject(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              ),
              child: const Text('Rechazar'),
            ),
          ),
        ]);
      } else if (booking.status == 'ACCEPTED' ||
          booking.status == 'PROVIDER_EN_ROUTE') {
        actions.add(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onStart(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar servicio'),
            ),
          ),
        );
      } else if (booking.status == 'IN_PROGRESS' ||
          booking.status == 'EVIDENCE_UPLOADED') {
        actions.add(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onComplete(context, ref),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Completar servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.success,
              ),
            ),
          ),
        );
      }
    }

    // Boton de cancelar (disponible para ambos si es cancelable)
    if (booking.isCancellable) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _onCancel(context, ref),
              style: TextButton.styleFrom(foregroundColor: colors.error),
              child: const Text('Cancelar reserva'),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    // Si los primeros botones son accept/reject (Row)
    if (isProvider &&
        (booking.status == 'REQUESTED' || booking.status == 'QUOTED')) {
      return Column(
        children: [
          Row(children: actions.sublist(0, 2)),
          if (actions.length > 2) ...actions.sublist(2),
        ],
      );
    }

    return Column(children: actions);
  }

  Future<void> _onAccept(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(bookingActionProvider.notifier)
        .accept(bookingId);
    if (success && context.mounted) {
      ref.invalidate(bookingDetailProvider(bookingId));
      _showSnackBar(context, '¡Reserva aceptada!');
    }
  }

  Future<void> _onReject(BuildContext context, WidgetRef ref) async {
    final reason = await _showReasonDialog(
      context,
      title: '¿Rechazar esta reserva?',
      hint: 'Motivo del rechazo (opcional)',
    );
    if (reason == null) return; // Dialogo cancelado

    final success = await ref
        .read(bookingActionProvider.notifier)
        .reject(bookingId, reason: reason.isEmpty ? null : reason);
    if (success && context.mounted) {
      ref.invalidate(bookingDetailProvider(bookingId));
      _showSnackBar(context, 'Reserva rechazada');
    }
  }

  Future<void> _onStart(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(bookingActionProvider.notifier)
        .start(bookingId);
    if (success && context.mounted) {
      ref.invalidate(bookingDetailProvider(bookingId));
      _showSnackBar(context, '¡Servicio iniciado!');
    }
  }

  Future<void> _onComplete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Completar servicio?'),
        content: const Text(
          'Confirma que el servicio ha sido completado satisfactoriamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref
        .read(bookingActionProvider.notifier)
        .complete(bookingId);
    if (success && context.mounted) {
      ref.invalidate(bookingDetailProvider(bookingId));
      _showSnackBar(context, '¡Servicio completado!');
    }
  }

  Future<void> _onCancel(BuildContext context, WidgetRef ref) async {
    final reason = await _showReasonDialog(
      context,
      title: '¿Cancelar esta reserva?',
      hint: 'Motivo de cancelación (opcional)',
    );
    if (reason == null) return; // Dialogo cancelado

    final success = await ref
        .read(bookingActionProvider.notifier)
        .cancel(bookingId, reason: reason.isEmpty ? null : reason);
    if (success && context.mounted) {
      ref.invalidate(bookingDetailProvider(bookingId));
      _showSnackBar(context, 'Reserva cancelada');
    }
  }

  /// Muestra un dialogo con campo de texto para ingresar un motivo.
  /// Retorna null si se cancela, o el string ingresado si se confirma.
  Future<String?> _showReasonDialog(
    BuildContext context, {
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          maxLines: 3,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
