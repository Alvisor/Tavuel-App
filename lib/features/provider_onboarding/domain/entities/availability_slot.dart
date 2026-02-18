class AvailabilitySlot {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const AvailabilitySlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

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
}
