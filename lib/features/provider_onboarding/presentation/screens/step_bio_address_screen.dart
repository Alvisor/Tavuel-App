import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_onboarding_provider.dart';

/// Paso 1: Informacion del perfil - bio y direccion.
///
/// Formulario con campos para descripcion personal (bio), direccion
/// de servicio y coordenadas (latitud/longitud) opcionales.
class StepBioAddressScreen extends ConsumerStatefulWidget {
  const StepBioAddressScreen({super.key});

  @override
  ConsumerState<StepBioAddressScreen> createState() =>
      _StepBioAddressScreenState();
}

class _StepBioAddressScreenState extends ConsumerState<StepBioAddressScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingWizardProvider);
    _bioController = TextEditingController(text: state.bio);
    _addressController = TextEditingController(text: state.address);
    _latController = TextEditingController(
      text: state.lat?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: state.lng?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingWizardProvider);
    final colors = AppColors.of(context);

    // Actualizar controllers cuando init() carga datos pre-existentes
    ref.listen<OnboardingWizardState>(onboardingWizardProvider,
        (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.bio.isNotEmpty && _bioController.text.isEmpty) {
          _bioController.text = next.bio;
        }
        if (next.address.isNotEmpty && _addressController.text.isEmpty) {
          _addressController.text = next.address;
        }
        if (next.lat != null && _latController.text.isEmpty) {
          _latController.text = next.lat.toString();
        }
        if (next.lng != null && _lngController.text.isEmpty) {
          _lngController.text = next.lng.toString();
        }
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titulo
            Text(
              'Cuentanos sobre ti',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta informacion sera visible para los clientes que busquen tus servicios.',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            Text(
              'Descripcion profesional',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLength: 500,
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText:
                    'Ej: Soy electricista certificado con 10 anos de experiencia en instalaciones residenciales y comerciales...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripcion es obligatoria.';
                }
                if (value.trim().length < 20) {
                  return 'La descripcion debe tener al menos 20 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Direccion
            Text(
              'Direccion de servicio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Ej: Calle 123 #45-67, Barrio, Ciudad',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La direccion es obligatoria.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Coordenadas
            Text(
              'Ubicacion (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Puedes agregar coordenadas para una ubicacion mas precisa.',
              style: TextStyle(
                fontSize: 12,
                color: colors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Latitud',
                      prefixIcon: Icon(Icons.gps_fixed, size: 20),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Latitud invalida.';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Longitud',
                      prefixIcon: Icon(Icons.gps_fixed, size: 20),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Longitud invalida.';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Boton siguiente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _onSave,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final bio = _bioController.text.trim();
    final address = _addressController.text.trim();
    final lat = double.tryParse(_latController.text.trim()) ?? 4.6097;
    final lng = double.tryParse(_lngController.text.trim()) ?? -74.0817;

    // Paso 1 guarda con categorias vacias - se eligen en paso 2
    final selectedCategories =
        ref.read(onboardingWizardProvider).selectedCategoryIds;

    final success = await ref
        .read(onboardingWizardProvider.notifier)
        .saveProfileStep(
          bio: bio,
          address: address,
          lat: lat,
          lng: lng,
          categoryIds: selectedCategories,
        );

    if (success && mounted) {
      ref.read(onboardingWizardProvider.notifier).nextStep();
    }
  }
}
