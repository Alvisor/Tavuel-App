import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/onboarding_step_indicator.dart';
import 'step_availability_screen.dart';
import 'step_bank_account_screen.dart';
import 'step_bio_address_screen.dart';
import 'step_categories_screen.dart';
import 'step_documents_screen.dart';
import 'step_review_submit_screen.dart';

/// Pantalla principal del wizard de onboarding para proveedores.
///
/// Contiene un [PageView] con 6 pasos, un indicador de progreso superior
/// y manejo de navegacion hacia atras.
class ProviderOnboardingScreen extends ConsumerStatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  ConsumerState<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState
    extends ConsumerState<ProviderOnboardingScreen> {
  late final PageController _pageController;

  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Inicializar el wizard despues del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingWizardProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingWizardProvider);
    final colors = AppColors.of(context);

    // Escuchar cambios de paso para animar el PageView
    ref.listen<OnboardingWizardState>(onboardingWizardProvider,
        (previous, next) {
      if (previous?.currentStep != next.currentStep &&
          _pageController.hasClients) {
        if (_isInitialLoad) {
          // Primera carga: saltar directo sin animacion
          _isInitialLoad = false;
          _pageController.jumpToPage(next.currentStep);
        } else {
          _pageController.animateToPage(
            next.currentStep,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    // Mostrar errores como SnackBar
    ref.listen<OnboardingWizardState>(onboardingWizardProvider,
        (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colors.error,
            action: SnackBarAction(
              label: 'OK',
              textColor: colors.textOnPrimary,
              onPressed: () {
                ref.read(onboardingWizardProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return PopScope(
      canPop: state.currentStep == 0,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) {
          ref.read(onboardingWizardProvider.notifier).previousStep();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Registro de proveedor'),
          leading: state.currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref
                        .read(onboardingWizardProvider.notifier)
                        .previousStep();
                  },
                )
              : null,
          actions: [
            // Indicador de paso actual
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${state.currentStep + 1}/${OnboardingWizardState.totalSteps}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: state.isLoading && state.categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando datos...',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Step indicator
                  OnboardingStepIndicator(
                    currentStep: state.currentStep,
                  ),
                  const Divider(height: 1),

                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        StepBioAddressScreen(),
                        StepCategoriesScreen(),
                        StepDocumentsScreen(),
                        StepBankAccountScreen(),
                        StepAvailabilityScreen(),
                        StepReviewSubmitScreen(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
