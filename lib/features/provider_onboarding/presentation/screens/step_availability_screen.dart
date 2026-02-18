import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/availability_slot.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/availability_day_picker.dart';

/// Paso 5: Configuracion de disponibilidad horaria semanal.
///
/// Muestra 7 tarjetas (una por dia de la semana). Cada dia se puede
/// activar/desactivar e incluir multiples franjas horarias con pickers
/// de hora inicio/fin. Por defecto: Lunes a Viernes 08:00-17:00.
class StepAvailabilityScreen extends ConsumerStatefulWidget {
  const StepAvailabilityScreen({super.key});

  @override
  ConsumerState<StepAvailabilityScreen> createState() =>
      _StepAvailabilityScreenState();
}

class _StepAvailabilityScreenState
    extends ConsumerState<StepAvailabilityScreen>
    with AutomaticKeepAliveClientMixin {
  late List<DayAvailabilityData> _days;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeDays();
  }

  void _initializeDays() {
    final existingSlots = ref.read(onboardingWizardProvider).availability;

    if (existingSlots.isNotEmpty) {
      // Reconstruir desde slots existentes
      _days = List.generate(7, (dayIndex) {
        final slotsForDay =
            existingSlots.where((s) => s.dayOfWeek == dayIndex).toList();
        return DayAvailabilityData(
          dayOfWeek: dayIndex,
          isActive: slotsForDay.isNotEmpty,
          timeSlots: slotsForDay.isNotEmpty
              ? slotsForDay
                  .map((s) => TimeSlotData(
                        startTime: s.startTime,
                        endTime: s.endTime,
                      ))
                  .toList()
              : const [],
        );
      });
    } else {
      // Valores por defecto: Lun-Vie 08:00-17:00
      _days = List.generate(7, (dayIndex) {
        final isWeekday = dayIndex < 5;
        return DayAvailabilityData(
          dayOfWeek: dayIndex,
          isActive: isWeekday,
          timeSlots: isWeekday
              ? const [TimeSlotData(startTime: '08:00', endTime: '17:00')]
              : const [],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingWizardProvider);
    final colors = AppColors.of(context);

    final activeDays = _days.where((d) => d.isActive).length;

    return Column(
      children: [
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
                        'Tu disponibilidad',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configura los dias y horarios en los que estas disponible para prestar servicios.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Resumen
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$activeDays dia${activeDays != 1 ? 's' : ''} activo${activeDays != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Lista de dias
                ..._days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dayData = entry.value;
                  return AvailabilityDayPicker(
                    dayData: dayData,
                    onChanged: (updated) {
                      setState(() {
                        _days[index] = updated;
                      });
                    },
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Boton inferior
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
                onPressed: state.isLoading || activeDays == 0
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

    // Recopilar todos los slots activos
    final List<AvailabilitySlot> slots = [];
    for (final day in _days) {
      slots.addAll(day.toSlots());
    }

    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes activar al menos un dia con horario.'),
          backgroundColor: colors.warning,
        ),
      );
      return;
    }

    // Validar que las horas de inicio sean menores que las de fin
    for (final slot in slots) {
      if (slot.startTime.compareTo(slot.endTime) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'En ${slot.dayName}: la hora de inicio debe ser antes que la hora de fin.',
            ),
            backgroundColor: colors.error,
          ),
        );
        return;
      }
    }

    final success = await ref
        .read(onboardingWizardProvider.notifier)
        .saveAvailability(slots);

    if (success && mounted) {
      ref.read(onboardingWizardProvider.notifier).nextStep();
    }
  }
}
