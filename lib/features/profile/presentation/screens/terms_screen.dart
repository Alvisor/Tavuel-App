import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/providers/app_mode_provider.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final isProvider = ref.watch(isProviderModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General terms (always shown)
            _buildSection(
              colors: colors,
              number: '1',
              title: 'Aceptación de los Términos',
              body:
                  'Al registrarte y usar Tavuel, aceptas estos términos y condiciones en su totalidad. Si no estás de acuerdo con alguno de estos términos, te pedimos que no utilices la plataforma. El uso continuado de Tavuel constituye la aceptación de cualquier modificación futura a estos términos.',
            ),
            _buildSection(
              colors: colors,
              number: '2',
              title: 'Uso de la Plataforma',
              body:
                  'Tavuel es una plataforma que conecta clientes con proveedores de servicios para el hogar, incluyendo plomería, electricidad, limpieza, cerrajería, pintura y más. Tavuel actúa como intermediario tecnológico y no es responsable directo de la ejecución de los servicios.',
            ),
            _buildSection(
              colors: colors,
              number: '3',
              title: 'Registro y Cuenta',
              body:
                  'Debes proporcionar información verídica y mantener tus datos actualizados. Eres responsable de la seguridad de tu cuenta y de todas las actividades que se realicen bajo tu usuario. No está permitido compartir tu cuenta con terceros.',
            ),
            _buildSection(
              colors: colors,
              number: '4',
              title: 'Pagos y Comisiones',
              body:
                  'Los pagos se procesan a través de la plataforma. Tavuel cobra una comisión por cada transacción completada. Los precios de los servicios son establecidos por los proveedores y deben incluir todos los costos asociados al servicio.',
            ),
            _buildSection(
              colors: colors,
              number: '5',
              title: 'Cancelaciones',
              body:
                  'Las cancelaciones están sujetas a nuestra política. Cancelaciones reiteradas pueden resultar en restricciones de la cuenta. Las cancelaciones realizadas antes de la aceptación del proveedor no generan cargos adicionales.',
            ),
            _buildSection(
              colors: colors,
              number: '6',
              title: 'PQRs',
              body:
                  'De acuerdo con la normativa colombiana, tienes derecho a presentar Peticiones, Quejas y Reclamos (PQR). Nos comprometemos a responder en un plazo máximo de 15 días hábiles conforme a la Ley 1480 de 2011 (Estatuto del Consumidor).',
            ),
            _buildSection(
              colors: colors,
              number: '7',
              title: 'Propiedad Intelectual',
              body:
                  'Tavuel y su contenido, incluyendo la marca, logotipos, diseño y código fuente, son propiedad de Z Solutions. No está permitida la reproducción, distribución o modificación sin autorización previa y por escrito.',
            ),

            // Provider-specific terms
            if (isProvider) ...[
              const SizedBox(height: 8),
              Divider(color: colors.surfaceVariant, thickness: 2),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      size: 20,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Términos para Proveedores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSection(
                colors: colors,
                number: '8',
                title: 'Obligaciones del Proveedor',
                body:
                    'Como proveedor, te comprometes a: prestar servicios de calidad, cumplir con los horarios acordados, mantener tus documentos vigentes, documentar el trabajo con evidencias fotográficas (antes y después), y tratar a los clientes con respeto y profesionalismo.',
              ),
              _buildSection(
                colors: colors,
                number: '9',
                title: 'Verificación y Documentos',
                body:
                    'Para operar como proveedor debes completar el proceso de verificación que incluye cédula de ciudadanía, antecedentes judiciales, RUT y certificación bancaria. Tavuel se reserva el derecho de suspender cuentas con documentos vencidos o información fraudulenta.',
              ),
              _buildSection(
                colors: colors,
                number: '10',
                title: 'Pagos a Proveedores',
                body:
                    'Los pagos se realizan a la cuenta bancaria registrada. La comisión de la plataforma se descuenta automáticamente de cada transacción. El proveedor es responsable de sus obligaciones tributarias y de seguridad social.',
              ),
            ],

            // Footer
            const SizedBox(height: 24),
            Divider(color: colors.surfaceVariant),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Última actualización: Febrero 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Z Solutions - Todos los derechos reservados',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required AppColorsExtension colors,
    required String number,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
