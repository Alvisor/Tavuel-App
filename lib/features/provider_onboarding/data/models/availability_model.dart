import '../../domain/entities/availability_slot.dart';

class AvailabilitySlotModel extends AvailabilitySlot {
  const AvailabilitySlotModel({
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
