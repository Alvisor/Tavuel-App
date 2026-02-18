import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Column(
      children: [
        const SizedBox(height: 24),
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: colors.primary.withOpacity(0.1),
          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(
                  _getInitials(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),

        // Nombre completo
        Text(
          user.fullName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Badge de rol
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _getRoleBadgeColor(colors).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getRoleBadgeColor(colors).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(),
                size: 16,
                color: _getRoleBadgeColor(colors),
              ),
              const SizedBox(width: 6),
              Text(
                _getRoleLabel(),
                style: TextStyle(
                  color: _getRoleBadgeColor(colors),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Email
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getInitials() {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  Color _getRoleBadgeColor(AppColorsExtension colors) {
    switch (user.role) {
      case 'PROVIDER':
        return colors.secondary;
      case 'ADMIN':
        return colors.error;
      default:
        return colors.primary;
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case 'PROVIDER':
        return Icons.handyman;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getRoleLabel() {
    switch (user.role) {
      case 'PROVIDER':
        return user.isProviderMode ? 'Modo Proveedor' : 'Modo Cliente';
      case 'ADMIN':
        return 'Administrador';
      default:
        return 'Cliente';
    }
  }
}
