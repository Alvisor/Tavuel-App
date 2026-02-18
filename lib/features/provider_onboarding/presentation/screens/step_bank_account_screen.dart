import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/bank_account.dart';
import '../providers/provider_onboarding_provider.dart';
import '../widgets/bank_type_selector.dart';

/// Paso 4: Configuracion de cuenta bancaria.
///
/// Permite al usuario seleccionar entre Nequi, Daviplata o banco
/// tradicional, y completar los campos correspondientes a cada opcion.
class StepBankAccountScreen extends ConsumerStatefulWidget {
  const StepBankAccountScreen({super.key});

  @override
  ConsumerState<StepBankAccountScreen> createState() =>
      _StepBankAccountScreenState();
}

class _StepBankAccountScreenState extends ConsumerState<StepBankAccountScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  BankType? _selectedBankType;
  String? _selectedBank;
  String? _selectedAccountType;
  String? _selectedDocType;

  late final TextEditingController _phoneController;
  late final TextEditingController _holderController;
  late final TextEditingController _cedulaController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _docNumberController;

  /// Bancos colombianos disponibles.
  static const List<String> _banks = [
    'Bancolombia',
    'Davivienda',
    'Banco de Bogota',
    'BBVA',
    'Banco Popular',
    'Scotiabank',
    'Banco de Occidente',
  ];

  static const List<String> _accountTypes = ['Ahorros', 'Corriente'];

  static const List<String> _docTypes = [
    'CC',
    'CE',
    'NIT',
    'Pasaporte',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final existingBank = ref.read(onboardingWizardProvider).bankAccount;

    _phoneController = TextEditingController();
    _holderController = TextEditingController();
    _cedulaController = TextEditingController();
    _accountNumberController = TextEditingController();
    _docNumberController = TextEditingController();

    // Pre-llenar si ya existe una cuenta bancaria
    if (existingBank != null) {
      _holderController.text = existingBank.accountHolder;
      _docNumberController.text = existingBank.documentNumber;
      _selectedDocType = existingBank.documentType;

      if (existingBank.bankName == 'Nequi') {
        _selectedBankType = BankType.nequi;
        _phoneController.text = existingBank.accountNumber;
      } else if (existingBank.bankName == 'Daviplata') {
        _selectedBankType = BankType.daviplata;
        _cedulaController.text = existingBank.accountNumber;
      } else {
        _selectedBankType = BankType.banco;
        _selectedBank = existingBank.bankName;
        _selectedAccountType = existingBank.accountType;
        _accountNumberController.text = existingBank.accountNumber;
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _holderController.dispose();
    _cedulaController.dispose();
    _accountNumberController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingWizardProvider);
    final colors = AppColors.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titulo
                  Text(
                    'Datos bancarios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura tu cuenta para recibir pagos. Esta informacion se mantiene segura y encriptada.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector de tipo
                  BankTypeSelector(
                    selectedType: _selectedBankType,
                    onSelected: (type) {
                      setState(() {
                        _selectedBankType = type;
                        // Limpiar formulario al cambiar tipo
                        _formKey.currentState?.reset();
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Campos condicionales
                  if (_selectedBankType != null) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildFieldsForType(_selectedBankType!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Boton inferior
        if (_selectedBankType != null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: colors.onBackground.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
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
            ),
          ),
      ],
    );
  }

  Widget _buildFieldsForType(BankType type) {
    switch (type) {
      case BankType.nequi:
        return _buildNequiFields();
      case BankType.daviplata:
        return _buildDaviplataFields();
      case BankType.banco:
        return _buildTraditionalBankFields();
    }
  }

  Widget _buildNequiFields() {
    return Column(
      key: const ValueKey('nequi'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Numero de celular Nequi'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            hintText: '3001234567',
            prefixIcon: Icon(Icons.phone_android),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El numero es obligatorio.';
            }
            if (value.length != 10) {
              return 'El numero debe tener 10 digitos.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildHolderField(),
      ],
    );
  }

  Widget _buildDaviplataFields() {
    return Column(
      key: const ValueKey('daviplata'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Numero de cedula Daviplata'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cedulaController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            hintText: '1234567890',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La cedula es obligatoria.';
            }
            if (value.length < 6) {
              return 'La cedula debe tener al menos 6 digitos.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildHolderField(),
      ],
    );
  }

  Widget _buildTraditionalBankFields() {
    return Column(
      key: const ValueKey('banco'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banco
        _buildSectionLabel('Banco'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBank,
          decoration: const InputDecoration(
            hintText: 'Selecciona tu banco',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: _banks.map((bank) {
            return DropdownMenuItem(value: bank, child: Text(bank));
          }).toList(),
          onChanged: (value) => setState(() => _selectedBank = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona un banco.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Tipo de cuenta
        _buildSectionLabel('Tipo de cuenta'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAccountType,
          decoration: const InputDecoration(
            hintText: 'Selecciona tipo de cuenta',
          ),
          items: _accountTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedAccountType = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona un tipo de cuenta.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Numero de cuenta
        _buildSectionLabel('Numero de cuenta'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(20),
          ],
          decoration: const InputDecoration(
            hintText: 'Numero de cuenta',
            prefixIcon: Icon(Icons.numbers),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El numero de cuenta es obligatorio.';
            }
            if (value.length < 8) {
              return 'El numero de cuenta debe tener al menos 8 digitos.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Titular
        _buildHolderField(),
        const SizedBox(height: 16),

        // Tipo de documento
        _buildSectionLabel('Tipo de documento'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDocType,
          decoration: const InputDecoration(
            hintText: 'Tipo de documento',
            prefixIcon: Icon(Icons.article_outlined),
          ),
          items: _docTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _selectedDocType = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona tipo de documento.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Numero de documento
        _buildSectionLabel('Numero de documento'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _docNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            hintText: 'Numero de documento',
            prefixIcon: Icon(Icons.badge),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El numero de documento es obligatorio.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    final colors = AppColors.of(context);
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildHolderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Nombre del titular'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _holderController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Nombre completo del titular',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre del titular es obligatorio.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankType == null) return;

    late final BankAccount bankAccount;

    switch (_selectedBankType!) {
      case BankType.nequi:
        bankAccount = BankAccount(
          accountType: 'NEQUI',
          bankName: 'Nequi',
          accountNumber: _phoneController.text.trim(),
          accountHolder: _holderController.text.trim(),
          documentType: 'CC',
          documentNumber: _phoneController.text.trim(),
        );
        break;
      case BankType.daviplata:
        bankAccount = BankAccount(
          accountType: 'DAVIPLATA',
          bankName: 'Daviplata',
          accountNumber: _cedulaController.text.trim(),
          accountHolder: _holderController.text.trim(),
          documentType: 'CC',
          documentNumber: _cedulaController.text.trim(),
        );
        break;
      case BankType.banco:
        bankAccount = BankAccount(
          accountType: _selectedAccountType!,
          bankName: _selectedBank!,
          accountNumber: _accountNumberController.text.trim(),
          accountHolder: _holderController.text.trim(),
          documentType: _selectedDocType!,
          documentNumber: _docNumberController.text.trim(),
        );
        break;
    }

    final success = await ref
        .read(onboardingWizardProvider.notifier)
        .saveBankAccount(bankAccount);

    if (success && mounted) {
      ref.read(onboardingWizardProvider.notifier).nextStep();
    }
  }
}
