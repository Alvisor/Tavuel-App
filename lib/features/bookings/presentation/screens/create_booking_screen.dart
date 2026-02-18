import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/time_slot.dart';
import '../providers/bookings_provider.dart';
import '../widgets/time_slot_picker.dart';

/// Pantalla de formulario para crear una nueva reserva de servicio.
class CreateBookingScreen extends ConsumerStatefulWidget {
  final String providerId;
  final String? serviceId;

  const CreateBookingScreen({
    super.key,
    required this.providerId,
    this.serviceId,
  });

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedServiceId;

  // TODO: Integrar con seleccion de mapa o geolocator
  double _latitude = AppConstants.bogotaLatitude;
  double _longitude = AppConstants.bogotaLongitude;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.serviceId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(createBookingProvider);

    // Escuchar cambios de estado para navegar al exito
    ref.listen<CreateBookingState>(createBookingProvider, (_, next) {
      if (next.isSuccess && next.createdBooking != null) {
        // Navegar al detalle de la reserva creada
        context.go('/booking-detail/${next.createdBooking!.id}');
        ref.read(createBookingProvider.notifier).reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reserva creada exitosamente!'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de servicio (si no viene preseleccionado)
              if (widget.serviceId == null) ...[
                Text(
                  'Servicio',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildServicePicker(colors, theme),
                const SizedBox(height: 20),
              ],

              // Descripcion del servicio
              Text(
                '¿Qué necesitas?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText:
                      'Describe el servicio que necesitas...',
                ),
                maxLines: 4,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Fecha
              Text(
                'Fecha',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Selecciona una fecha',
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: colors.textSecondary,
                    ),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('EEEE dd MMMM yyyy', 'es_CO')
                            .format(_selectedDate!)
                        : 'Selecciona una fecha',
                    style: _selectedDate != null
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: colors.textHint,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Hora - Time Slot Picker
              Text(
                'Hora',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildTimeSlotSection(colors, theme),

              const SizedBox(height: 20),

              // Direccion
              Text(
                'Dirección del servicio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Calle, número, barrio, ciudad',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'La dirección debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Notas adicionales
              Text(
                'Notas adicionales (opcional)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText:
                      'Instrucciones para el proveedor...',
                ),
                maxLines: 3,
                maxLength: 500,
              ),

              // Error message
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: colors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Boton de enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : _onSubmit,
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Solicitar Servicio'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicePicker(
      AppColorsExtension colors, ThemeData theme) {
    final servicesAsync =
        ref.watch(providerServicesProvider(widget.providerId));

    return servicesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Error cargando servicios',
        style: TextStyle(color: colors.error),
      ),
      data: (services) {
        if (services.isEmpty) {
          return Text(
            'Este proveedor no tiene servicios disponibles',
            style: TextStyle(color: colors.textHint),
          );
        }
        return DropdownButtonFormField<String>(
          value: _selectedServiceId,
          decoration: const InputDecoration(
            hintText: 'Selecciona un servicio',
            prefixIcon: Icon(Icons.handyman_outlined),
          ),
          items: services.map((s) {
            final priceLabel = s.price > 0
                ? ' - \$${s.price.toStringAsFixed(0)}'
                : '';
            return DropdownMenuItem(
              value: s.serviceId,
              child: Text(
                '${s.name}$priceLabel',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedServiceId = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona un servicio';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildTimeSlotSection(
      AppColorsExtension colors, ThemeData theme) {
    if (_selectedDate == null) {
      return TimeSlotPicker(
        slots: const [],
        onTimeSelected: (_) {},
      );
    }

    // Generar key para el provider
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final busyKey = '${widget.providerId}|$dateStr';
    final busySlotsAsync = ref.watch(busySlotsProvider(busyKey));

    return busySlotsAsync.when(
      loading: () => TimeSlotPicker(
        slots: const [],
        onTimeSelected: (_) {},
        isLoading: true,
      ),
      error: (e, _) => Text(
        'Error cargando horarios',
        style: TextStyle(color: colors.error),
      ),
      data: (busySlots) {
        final slots = _generateTimeSlots(busySlots);
        return TimeSlotPicker(
          slots: slots,
          selectedTime: _selectedTime,
          onTimeSelected: (time) {
            setState(() => _selectedTime = time);
          },
        );
      },
    );
  }

  /// Genera slots de 30 min entre 6:00 y 21:00, marcando como
  /// no disponibles los que se solapan con busy slots.
  List<TimeSlot> _generateTimeSlots(List<BusySlot> busySlots) {
    final slots = <TimeSlot>[];
    final now = DateTime.now();
    final isToday = _selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    for (int hour = 6; hour <= 20; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = TimeOfDay(hour: hour, minute: minute);

        // Si es hoy, ocultar slots pasados + 1h de margen
        if (isToday) {
          final slotDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          if (slotDateTime.isBefore(
              now.add(const Duration(hours: 1)))) {
            continue;
          }
        }

        // Verificar si el slot se solapa con algun busy slot
        final slotStart = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          hour,
          minute,
        );
        final slotEnd = slotStart.add(const Duration(minutes: 30));

        bool isBusy = false;
        for (final busy in busySlots) {
          if (slotStart.isBefore(busy.end) &&
              slotEnd.isAfter(busy.start)) {
            isBusy = true;
            break;
          }
        }

        slots.add(TimeSlot(time: time, isAvailable: !isBusy));
      }
    }

    return slots;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(
        const Duration(days: AppConstants.maxFutureBookingDays),
      ),
      locale: const Locale('es', 'CO'),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null; // Reset time al cambiar fecha
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha para el servicio'),
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una hora para el servicio'),
        ),
      );
      return;
    }

    // Combinar fecha y hora
    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Validar que sea al menos 1 hora en el futuro
    final minTime = DateTime.now().add(
      const Duration(minutes: AppConstants.minBookingLeadTimeMinutes),
    );
    if (scheduledAt.isBefore(minTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora debe ser al menos 1 hora en el futuro',
          ),
        ),
      );
      return;
    }

    final serviceId = _selectedServiceId ?? widget.serviceId ?? '';
    if (serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un servicio'),
        ),
      );
      return;
    }

    await ref.read(createBookingProvider.notifier).createBooking(
          providerId: widget.providerId,
          serviceId: serviceId,
          scheduledAt: scheduledAt,
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
  }
}
