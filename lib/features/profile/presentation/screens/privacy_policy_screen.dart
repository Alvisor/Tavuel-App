import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              colors: colors,
              title: 'Información que Recopilamos',
              body:
                  'Recopilamos los siguientes tipos de información: datos personales (nombre, correo electrónico, número de teléfono), ubicación para conectarte con proveedores cercanos, información de pago para procesar transacciones, documentos de verificación para proveedores (cédula, antecedentes, RUT, certificación bancaria), y fotografías de evidencia de los servicios realizados.',
            ),
            _buildSection(
              colors: colors,
              title: 'Uso de la Información',
              body:
                  'Utilizamos tu información para: facilitar la conexión entre clientes y proveedores de servicios para el hogar, procesar pagos de forma segura, verificar la identidad de los proveedores, mejorar nuestros servicios y la experiencia de usuario, enviar notificaciones relevantes sobre tus reservas, y cumplir con los requisitos legales colombianos aplicables.',
            ),
            _buildSection(
              colors: colors,
              title: 'Protección de Datos',
              body:
                  'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal. Los datos de pago se procesan de forma cifrada mediante protocolos seguros. Cumplimos con la Ley 1581 de 2012 de Protección de Datos Personales de Colombia y su decreto reglamentario 1377 de 2013.',
            ),
            _buildSection(
              colors: colors,
              title: 'Compartir Información',
              body:
                  'Solo compartimos tu información con: el proveedor o cliente con quien realizas una transacción (datos de contacto necesarios para la prestación del servicio), procesadores de pago autorizados para completar las transacciones, y autoridades competentes cuando sea requerido por ley o por orden judicial.',
            ),
            _buildSection(
              colors: colors,
              title: 'Tus Derechos',
              body:
                  'De acuerdo con la ley colombiana (Ley 1581 de 2012), tienes derecho a: conocer, actualizar y rectificar tus datos personales, solicitar la eliminación de tus datos cuando no exista obligación legal de conservarlos, revocar la autorización de tratamiento de datos, presentar quejas ante la Superintendencia de Industria y Comercio (SIC) por infracciones a la ley de protección de datos, y acceder de forma gratuita a tus datos personales.',
            ),
            _buildSection(
              colors: colors,
              title: 'Cookies y Tecnologías',
              body:
                  'Utilizamos tecnologías de seguimiento para mejorar la experiencia de usuario y analizar el uso de la plataforma. Estas tecnologías nos permiten recordar tus preferencias, analizar patrones de uso, y optimizar el rendimiento de la aplicación.',
            ),
            _buildSection(
              colors: colors,
              title: 'Contacto',
              body:
                  'Para ejercer tus derechos de habeas data o realizar consultas sobre privacidad, puedes escribirnos a: privacidad@tavuel.com. Atenderemos tu solicitud en los plazos establecidos por la ley colombiana.',
            ),

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
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
