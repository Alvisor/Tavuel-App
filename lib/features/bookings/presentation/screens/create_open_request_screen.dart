import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../provider_search/domain/entities/service_category.dart';
import '../../../provider_search/presentation/providers/provider_search_provider.dart';
import '../providers/bookings_provider.dart';

/// Pantalla para crear una solicitud abierta (sin proveedor).
class CreateOpenRequestScreen extends ConsumerStatefulWidget {
  const CreateOpenRequestScreen({super.key});

  @override
  ConsumerState<CreateOpenRequestScreen> createState() =>
      _CreateOpenRequestScreenState();
}

class _CreateOpenRequestScreenState
    extends ConsumerState<CreateOpenRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategoryId;

  double _latitude = AppConstants.bogotaLatitude;
  double _longitude = AppConstants.bogotaLongitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(createOpenRequestProvider);
    final catState = ref.watch(categoriesProvider);

    ref.listen<CreateBookingState>(createOpenRequestProvider, (_, next) {
      if (next.isSuccess && next.createdBooking != null) {
        context.go('/booking-detail/${next.createdBooking!.id}');
        ref.read(createOpenRequestProvider.notifier).reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud publicada exitosamente'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Solicitud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: colors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los proveedores de la categoria seleccionada veran tu solicitud y podran aceptarla.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Categoria
              Text('Categoria', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildCategoryPicker(catState, colors, theme),

              const SizedBox(height: 20),

              // Descripcion
              Text('Que necesitas?', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe el servicio que necesitas...',
                ),
                maxLines: 4,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'La descripcion debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Fecha
              Text('Fecha', style: theme.textTheme.titleMedium),
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

              // Hora
              Text('Hora', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Selecciona una hora',
                    suffixIcon: Icon(
                      Icons.access_time,
                      color: colors.textSecondary,
                    ),
                  ),
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Selecciona una hora',
                    style: _selectedTime != null
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: colors.textHint,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Direccion
              Text(
                'Direccion del servicio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Calle, numero, barrio, ciudad',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'La direccion debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Presupuesto (opcional)
              Text(
                'Presupuesto estimado (opcional)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  hintText: 'Ej: 150000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
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

              // Boton enviar
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
                      : const Text('Publicar Solicitud'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker(
    CategoriesState catState,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    if (catState.isLoading) {
      return const LinearProgressIndicator();
    }

    if (catState.categories.isEmpty) {
      return Text(
        'No hay categorias disponibles',
        style: TextStyle(color: colors.textHint),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        hintText: 'Selecciona una categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: catState.categories.map((c) {
        return DropdownMenuItem(
          value: c.id,
          child: Text(c.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona una categoria';
        }
        return null;
      },
    );
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
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
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

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

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

    final budgetText = _budgetController.text.trim();
    final budget = budgetText.isNotEmpty
        ? double.tryParse(budgetText)
        : null;

    await ref.read(createOpenRequestProvider.notifier).createOpenRequest(
          categoryId: _selectedCategoryId!,
          scheduledAt: scheduledAt,
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          budget: budget,
        );
  }
}
