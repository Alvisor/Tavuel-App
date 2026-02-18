import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Tipos de cuenta bancaria soportados.
enum BankType {
  nequi,
  daviplata,
  banco,
}

/// Extension para obtener propiedades del tipo de banco.
extension BankTypeExtension on BankType {
  String get label {
    switch (this) {
      case BankType.nequi:
        return 'Nequi';
      case BankType.daviplata:
        return 'Daviplata';
      case BankType.banco:
        return 'Banco tradicional';
    }
  }

  String get bankName {
    switch (this) {
      case BankType.nequi:
        return 'Nequi';
      case BankType.daviplata:
        return 'Daviplata';
      case BankType.banco:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case BankType.nequi:
        return Icons.phone_android;
      case BankType.daviplata:
        return Icons.smartphone;
      case BankType.banco:
        return Icons.account_balance;
    }
  }

  Color accentColorFor(BuildContext context) {
    final colors = AppColors.of(context);
    switch (this) {
      case BankType.nequi:
        return const Color(0xFF320046);
      case BankType.daviplata:
        return const Color(0xFFED1C24);
      case BankType.banco:
        return colors.primary;
    }
  }
}

/// Selector de tipo de cuenta bancaria con 3 opciones estilo radio cards.
///
/// Muestra Nequi, Daviplata y Banco tradicional como tarjetas seleccionables
/// con icono, nombre y borde resaltado cuando esta seleccionado.
class BankTypeSelector extends StatelessWidget {
  final BankType? selectedType;
  final ValueChanged<BankType> onSelected;

  const BankTypeSelector({
    super.key,
    this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de cuenta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: BankType.values.map((type) {
            final isSelected = selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != BankType.banco ? 8 : 0,
                ),
                child: _BankTypeCard(
                  type: type,
                  isSelected: isSelected,
                  onTap: () => onSelected(type),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BankTypeCard extends StatelessWidget {
  final BankType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accentColor = type.accentColorFor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(0.08)
                : colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 28,
                color: isSelected ? accentColor : colors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                type.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? accentColor : colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Radio indicator
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? accentColor : colors.textHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
