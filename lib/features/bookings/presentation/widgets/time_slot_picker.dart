import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/time_slot.dart';

/// Grid de chips para seleccionar una hora en intervalos de 30 minutos.
///
/// - Disponible: color primary, tappable
/// - Ocupado: gris, deshabilitado
/// - Seleccionado: color secondary con borde
class TimeSlotPicker extends StatelessWidget {
  final List<TimeSlot> slots;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool isLoading;

  const TimeSlotPicker({
    super.key,
    required this.slots,
    this.selectedTime,
    required this.onTimeSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Selecciona una fecha para ver horarios disponibles',
          style: TextStyle(color: colors.textHint, fontSize: 14),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = selectedTime != null &&
            selectedTime!.hour == slot.time.hour &&
            selectedTime!.minute == slot.time.minute;

        return _SlotChip(
          slot: slot,
          isSelected: isSelected,
          onTap: slot.isAvailable
              ? () => onTimeSelected(slot.time)
              : null,
        );
      }).toList(),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      bgColor = colors.secondary;
      textColor = colors.textOnPrimary;
      borderColor = colors.secondary;
    } else if (slot.isAvailable) {
      bgColor = colors.primary.withOpacity(0.08);
      textColor = colors.primary;
      borderColor = colors.primary.withOpacity(0.3);
    } else {
      bgColor = colors.surfaceVariant.withOpacity(0.5);
      textColor = colors.textHint;
      borderColor = colors.surfaceVariant;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          slot.label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
