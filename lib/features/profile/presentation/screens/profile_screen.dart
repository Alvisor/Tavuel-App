import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/app_mode_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/become_provider_banner.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/verification_status_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Carga el perfil al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user ?? authState.user;
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navegar a configuracion
            },
          ),
        ],
      ),
      body: profileState.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? _buildErrorState(profileState.errorMessage, colors)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(profileProvider.notifier).loadProfile();
                  },
                  child: ListView(
                    children: [
                      // Header con avatar y nombre
                      ProfileHeader(user: user),

                      // Tarjeta de estado de verificacion (si aplica)
                      if (user.wantsToBeProvider &&
                          user.role != 'PROVIDER') ...[
                        VerificationStatusCard(
                          status: _getVerificationStatus(user),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Banner "Quieres ser proveedor?" (solo si es CLIENT y no ha aplicado)
                      if (user.role == 'CLIENT' &&
                          !user.wantsToBeProvider) ...[
                        BecomeProviderBanner(
                          onTap: () {
                            context.push('/provider-onboarding');
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Switch de modo (solo si es PROVIDER)
                      if (user.role == 'PROVIDER') ...[
                        _buildModeSwitchTile(user, profileState, colors),
                        const SizedBox(height: 8),
                      ],

                      // Seccion de menu
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'General',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textHint,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      ProfileMenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Editar Perfil',
                        subtitle: 'Nombre, teléfono, foto',
                        onTap: () {
                          context.push(AppRoutes.editProfile);
                        },
                      ),

                      ProfileMenuItem(
                        icon: Icons.history,
                        title: 'Historial de Servicios',
                        subtitle: 'Tus servicios pasados',
                        onTap: () {
                          // TODO: Navegar a historial de servicios
                        },
                      ),

                      // Apariencia / Tema
                      ProfileMenuItem(
                        icon: Icons.palette_outlined,
                        title: 'Apariencia',
                        subtitle: _getThemeLabel(),
                        onTap: () => _showThemePicker(context),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Soporte',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textHint,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Centro de Ayuda',
                        subtitle: 'Preguntas frecuentes y soporte',
                        onTap: () {
                          context.push(AppRoutes.helpCenter);
                        },
                      ),

                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terminos y Condiciones',
                        onTap: () {
                          context.push(AppRoutes.terms);
                        },
                      ),

                      ProfileMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Politica de Privacidad',
                        onTap: () {
                          context.push(AppRoutes.privacyPolicy);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Cerrar sesion
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Cerrar Sesion',
                        iconColor: colors.error,
                        textColor: colors.error,
                        showDivider: false,
                        trailing: const SizedBox.shrink(),
                        onTap: () => _showLogoutDialog(context),
                      ),

                      const SizedBox(height: 32),

                      // Version
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Tavuel v${AppConstants.appVersion}',
                              style: TextStyle(
                                color: colors.textHint,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Desarrollado por Z Solutions',
                              style: TextStyle(
                                color: colors.textHint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  String _getThemeLabel() {
    final mode = ref.watch(themeProvider);
    return mode.label;
  }

  void _showThemePicker(BuildContext context) {
    final colors = AppColors.of(context);
    final currentMode = ref.read(themeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                  'Apariencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final mode in ThemeMode.values)
                  ListTile(
                    leading: Icon(
                      mode.icon,
                      color: currentMode == mode
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                    title: Text(
                      mode.label,
                      style: TextStyle(
                        fontWeight: currentMode == mode
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentMode == mode
                            ? colors.primary
                            : colors.textPrimary,
                      ),
                    ),
                    trailing: currentMode == mode
                        ? Icon(Icons.check, color: colors.primary)
                        : null,
                    onTap: () {
                      ref
                          .read(themeProvider.notifier)
                          .setThemeMode(mode);
                      Navigator.pop(ctx);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSwitchTile(
      User user, ProfileState profileState, AppColorsExtension colors) {
    final isProvider = ref.watch(isProviderModeProvider);
    final appModeState = ref.watch(appModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: SwitchListTile(
        title: const Text(
          'Modo Proveedor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isProvider
              ? 'Estás recibiendo solicitudes de servicio'
              : 'Activa para recibir solicitudes',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        value: isProvider,
        activeColor: colors.secondary,
        onChanged: profileState.isLoading || appModeState.isSwitching
            ? null
            : (value) async {
                final success =
                    await ref.read(appModeProvider.notifier).toggleMode();
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Modo proveedor activado'
                          : 'Modo cliente activado'),
                      backgroundColor: colors.secondary,
                    ),
                  );
                } else {
                  final error = ref.read(appModeProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(error ?? 'No se pudo cambiar el modo'),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              },
        secondary: Icon(
          isProvider ? Icons.handyman : Icons.person,
          color: isProvider
              ? colors.secondary
              : colors.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage, AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'No se pudo cargar el perfil',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(profileProvider.notifier).loadProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getVerificationStatus(User user) {
    return user.verificationStatus ?? 'DOCUMENTS_SUBMITTED';
  }

  void _showLogoutDialog(BuildContext context) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesion'),
        content: const Text(
          'Estas seguro de que quieres cerrar sesion?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(profileProvider.notifier).logout();
            },
            child: Text(
              'Cerrar Sesion',
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
