import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/availability_slot.dart';

/// Representa un dia con sus franjas horarias editables.
class DayAvailabilityData {
  final int dayOfWeek;
  final bool isActive;
  final List<TimeSlotData> timeSlots;

  const DayAvailabilityData({
    required this.dayOfWeek,
    this.isActive = false,
    this.timeSlots = const [],
  });

  DayAvailabilityData copyWith({
    bool? isActive,
    List<TimeSlotData>? timeSlots,
  }) {
    return DayAvailabilityData(
      dayOfWeek: dayOfWeek,
      isActive: isActive ?? this.isActive,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }

  String get dayName {
    const days = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Domingo',
    ];
    return days[dayOfWeek];
  }

  String get dayAbbrev {
    const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return days[dayOfWeek];
  }

  /// Convierte los time slots a AvailabilitySlot entities.
  List<AvailabilitySlot> toSlots() {
    if (!isActive) return [];
    return timeSlots
        .map((ts) => AvailabilitySlot(
              dayOfWeek: dayOfWeek,
              startTime: ts.startTime,
              endTime: ts.endTime,
            ))
        .toList();
  }
}

/// Representa una franja horaria individual con hora de inicio y fin.
class TimeSlotData {
  final String startTime;
  final String endTime;

  const TimeSlotData({
    this.startTime = '08:00',
    this.endTime = '17:00',
  });

  TimeSlotData copyWith({String? startTime, String? endTime}) {
    return TimeSlotData(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Card de un dia de la semana para configurar disponibilidad.
///
/// Incluye toggle switch, nombre del dia, y pickers de horario
/// cuando el dia esta activo. Permite agregar y eliminar franjas horarias.
class AvailabilityDayPicker extends StatelessWidget {
  final DayAvailabilityData dayData;
  final ValueChanged<DayAvailabilityData> onChanged;

  const AvailabilityDayPicker({
    super.key,
    required this.dayData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: dayData.isActive
              ? Border.all(color: colors.primary.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          children: [
            // Header con toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Dia de la semana
                  Expanded(
                    child: Text(
                      dayData.dayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: dayData.isActive
                            ? colors.textPrimary
                            : colors.textHint,
                      ),
                    ),
                  ),
                  // Toggle
                  Switch(
                    value: dayData.isActive,
                    onChanged: (value) {
                      if (value && dayData.timeSlots.isEmpty) {
                        // Agregar slot por defecto al activar
                        onChanged(dayData.copyWith(
                          isActive: true,
                          timeSlots: const [TimeSlotData()],
                        ));
                      } else {
                        onChanged(dayData.copyWith(isActive: value));
                      }
                    },
                    activeColor: colors.primary,
                  ),
                ],
              ),
            ),

            // Time slots (solo si activo)
            if (dayData.isActive) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    ...dayData.timeSlots.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slot = entry.value;
                      return _TimeSlotRow(
                        slot: slot,
                        canRemove: dayData.timeSlots.length > 1,
                        onStartChanged: (time) {
                          final updated =
                              List<TimeSlotData>.from(dayData.timeSlots);
                          updated[index] = slot.copyWith(startTime: time);
                          onChanged(dayData.copyWith(timeSlots: updated));
                        },
                        onEndChanged: (time) {
                          final updated =
                              List<TimeSlotData>.from(dayData.timeSlots);
                          updated[index] = slot.copyWith(endTime: time);
                          onChanged(dayData.copyWith(timeSlots: updated));
                        },
                        onRemove: () {
                          final updated =
                              List<TimeSlotData>.from(dayData.timeSlots);
                          updated.removeAt(index);
                          onChanged(dayData.copyWith(timeSlots: updated));
                        },
                      );
                    }),
                    // Boton agregar franja
                    TextButton.icon(
                      onPressed: () {
                        final updated =
                            List<TimeSlotData>.from(dayData.timeSlots);
                        updated.add(const TimeSlotData());
                        onChanged(dayData.copyWith(timeSlots: updated));
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar franja'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primary,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila individual de time slot con pickers de inicio y fin.
class _TimeSlotRow extends StatelessWidget {
  final TimeSlotData slot;
  final bool canRemove;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;
  final VoidCallback onRemove;

  const _TimeSlotRow({
    required this.slot,
    required this.canRemove,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Start time
          Expanded(
            child: _TimePicker(
              label: 'Desde',
              time: slot.startTime,
              onChanged: onStartChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 16, color: colors.textHint),
          ),
          // End time
          Expanded(
            child: _TimePicker(
              label: 'Hasta',
              time: slot.endTime,
              onChanged: onEndChanged,
            ),
          ),
          // Remove button
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              color: colors.error,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }
}

/// Picker de hora individual que muestra un TimePickerDialog.
class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final ValueChanged<String> onChanged;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: () async {
        final parts = time.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          helpText: label,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final formatted =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(formatted);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
