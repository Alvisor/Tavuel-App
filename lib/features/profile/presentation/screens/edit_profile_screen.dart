import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Pantalla de edición de perfil del usuario.
///
/// Permite cambiar nombre, apellido, teléfono y foto de perfil.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _newAvatarUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profileState = ref.read(profileProvider);
    final authState = ref.read(authProvider);
    final user = profileState.user ?? authState.user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final user = profileState.user ?? authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar con botón de cambiar
                    _buildAvatarSection(user, colors),
                    const SizedBox(height: 32),

                    // Nombre
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Nombre',
                      icon: Icons.person_outline,
                      colors: colors,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.trim().length > 50) {
                          return 'Máximo 50 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apellido
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Apellido',
                      icon: Icons.person_outline,
                      colors: colors,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El apellido es obligatorio';
                        }
                        if (value.trim().length > 50) {
                          return 'Máximo 50 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      colors: colors,
                      keyboardType: TextInputType.phone,
                      hint: '+573001234567',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es obligatorio';
                        }
                        final phoneRegex = RegExp(r'^\+57[0-9]{10}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Formato: +57 seguido de 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (solo lectura)
                    _buildTextField(
                      controller: TextEditingController(text: user.email),
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      colors: colors,
                      enabled: false,
                    ),

                    const SizedBox(height: 32),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection(User user, AppColorsExtension colors) {
    final avatarUrl = _newAvatarUrl ?? user.avatarUrl;
    final hasAvatar =
        avatarUrl != null && avatarUrl.isNotEmpty && _selectedImage == null;
    final hasLocalImage = _selectedImage != null;

    return Column(
      children: [
        Stack(
          children: [
            // Avatar
            CircleAvatar(
              radius: 56,
              backgroundColor: colors.primary.withOpacity(0.1),
              backgroundImage: hasLocalImage
                  ? FileImage(_selectedImage!) as ImageProvider
                  : hasAvatar
                      ? CachedNetworkImageProvider(avatarUrl!)
                      : null,
              child: !hasAvatar && !hasLocalImage
                  ? Text(
                      _getInitials(user),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    )
                  : null,
            ),

            // Botón de cámara
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 3),
                  ),
                  child: _isUploadingPhoto
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para cambiar la foto',
          style: TextStyle(
            fontSize: 13,
            color: colors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColorsExtension colors,
    String? hint,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colors.textHint),
        filled: true,
        fillColor: enabled
            ? colors.surface
            : colors.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.surfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.surfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.surfaceVariant.withOpacity(0.5)),
        ),
      ),
    );
  }

  String _getInitials(User user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  Future<void> _pickImage() async {
    final colors = AppColors.of(context);

    // Mostrar opciones: cámara o galería
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primary),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.primary),
                title: const Text('Elegir de galería'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isUploadingPhoto = true;
    });

    try {
      // Subir al servidor
      final apiClient = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await apiClient.uploadFile(
        '/media/upload?folder=avatars',
        formData: formData,
      );

      final data = response.data as Map<String, dynamic>;
      final url = data['url'] as String;

      setState(() {
        _newAvatarUrl = url;
        _isUploadingPhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedImage = null;
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la foto: ${e.toString()}'),
          backgroundColor: AppColors.of(context).error,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    // Si se subió una nueva foto, incluir la URL
    if (_newAvatarUrl != null) {
      data['avatarUrl'] = _newAvatarUrl;
    }

    final success =
        await ref.read(profileProvider.notifier).updateProfile(data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    final colors = AppColors.of(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: colors.success,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al actualizar el perfil'),
          backgroundColor: colors.error,
        ),
      );
    }
  }
}
