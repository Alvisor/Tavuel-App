import 'package:flutter/material.dart';

/// Representa un slot de tiempo con su disponibilidad.
class TimeSlot {
  final TimeOfDay time;
  final bool isAvailable;

  const TimeSlot({
    required this.time,
    required this.isAvailable,
  });

  String get label {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
