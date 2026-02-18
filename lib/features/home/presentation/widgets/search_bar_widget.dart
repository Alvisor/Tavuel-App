import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SearchBarWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search,
                color: colors.textHint,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Que servicio necesitas?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textHint,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
