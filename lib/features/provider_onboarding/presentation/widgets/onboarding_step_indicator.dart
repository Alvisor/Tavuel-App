import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_onboarding_provider.dart';

/// Indicador de pasos horizontal para el wizard de onboarding.
///
/// Muestra 6 circulos numerados con lineas conectoras, resaltando
/// el paso actual y marcando como completados los anteriores.
class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = OnboardingWizardState.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Circulos con lineas conectoras
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              // Indices pares = circulos, impares = lineas
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                return _buildStepCircle(stepIndex, colors);
              } else {
                final beforeStep = index ~/ 2;
                return _buildConnectorLine(beforeStep, colors);
              }
            }),
          ),
          const SizedBox(height: 8),
          // Labels debajo de cada circulo
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: Text(
                  OnboardingWizardState.stepLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: index == currentStep
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: index <= currentStep
                        ? colors.primary
                        : colors.textHint,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepIndex, AppColorsExtension colors) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;

    Color backgroundColor;
    Color textColor;
    Widget child;

    if (isCompleted) {
      backgroundColor = colors.primary;
      textColor = colors.textOnPrimary;
      child = Icon(Icons.check, size: 14, color: colors.textOnPrimary);
    } else if (isActive) {
      backgroundColor = colors.primary;
      textColor = colors.textOnPrimary;
      child = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      );
    } else {
      backgroundColor = colors.surfaceVariant;
      textColor = colors.textHint;
      child = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: colors.primaryLight, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildConnectorLine(int beforeStep, AppColorsExtension colors) {
    final isCompleted = beforeStep < currentStep;

    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? colors.primary : colors.surfaceVariant,
      ),
    );
  }
}
