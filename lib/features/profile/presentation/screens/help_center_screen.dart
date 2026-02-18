import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/providers/app_mode_provider.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final isProvider = ref.watch(isProviderModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Client FAQs section
          _buildSectionHeader(
            context,
            icon: Icons.person_outline,
            title: 'Preguntas Frecuentes - Clientes',
            colors: colors,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFaqTile(
                  context,
                  question: '¿Cómo solicito un servicio?',
                  answer:
                      'Busca el servicio que necesitas y selecciona un proveedor verificado, o publica una solicitud abierta sin elegir proveedor para que los expertos te contacten. Una vez conectado, pueden acordar el precio y los detalles del servicio. Elige la fecha y hora, y confirma tu solicitud.',
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildFaqTile(
                  context,
                  question: '¿Cómo se verifican los proveedores?',
                  answer:
                      'Todos los proveedores pasan por un proceso de verificación que incluye validación de identidad (cédula), antecedentes, RUT y certificación bancaria. Solo los proveedores aprobados pueden ofrecer servicios.',
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildFaqTile(
                  context,
                  question: '¿Qué hago si tengo un problema con un servicio?',
                  answer:
                      'Puedes crear una PQR (Petición, Queja o Reclamo) desde el detalle de tu reserva. Nuestro equipo de soporte revisará tu caso y te contactará en un plazo máximo de 15 días hábiles, según la regulación colombiana.',
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildFaqTile(
                  context,
                  question: '¿Cómo funcionan los pagos?',
                  answer:
                      'Los pagos se procesan de forma segura a través de la plataforma. El monto se retiene hasta que el servicio se complete satisfactoriamente.',
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildFaqTile(
                  context,
                  question: '¿Puedo cancelar una reserva?',
                  answer:
                      'Sí, puedes cancelar una reserva antes de que el proveedor la acepte sin ningún cargo. Una vez aceptada, consulta nuestra política de cancelación.',
                  colors: colors,
                  isLast: true,
                ),
              ],
            ),
          ),

          // Provider FAQs section (only shown in provider mode)
          if (isProvider) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              context,
              icon: Icons.handyman_outlined,
              title: 'Preguntas Frecuentes - Proveedores',
              colors: colors,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildFaqTile(
                    context,
                    question: '¿Cómo recibo solicitudes de servicio?',
                    answer:
                        'Las solicitudes te llegan directamente cuando un cliente te selecciona, o puedes revisar el tablón de solicitudes abiertas donde los clientes publican lo que necesitan.',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildFaqTile(
                    context,
                    question: '¿Cómo configuro mis servicios y precios?',
                    answer:
                        'Ve a \'Mis Servicios\' en el menú inferior y agrega las categorías de servicios que ofreces. Podrás establecer precios personalizados para cada servicio.',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildFaqTile(
                    context,
                    question: '¿Cuándo recibo mis pagos?',
                    answer:
                        'Los pagos se procesan a tu cuenta bancaria registrada una vez que el cliente confirma la finalización del servicio. El tiempo de transferencia depende de tu banco.',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildFaqTile(
                    context,
                    question: '¿Qué pasa si un cliente no está satisfecho?',
                    answer:
                        'Si un cliente abre una PQR, nuestro equipo de soporte evaluará el caso revisando las evidencias (fotos antes/después). Siempre recomendamos documentar tu trabajo con fotografías.',
                    colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildFaqTile(
                    context,
                    question: '¿Cómo mejoro mi visibilidad?',
                    answer:
                        'Mantener un perfil completo, responder rápido a las solicitudes, y obtener buenas reseñas te ayudará a aparecer más arriba en las búsquedas.',
                    colors: colors,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],

          // Contact section
          const SizedBox(height: 24),
          _buildSectionHeader(
            context,
            icon: Icons.contact_support_outlined,
            title: 'Contacto',
            colors: colors,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'soporte@tavuel.com',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Horario de atención: Lunes a Viernes, 8:00 AM - 6:00 PM',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required AppColorsExtension colors,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(
    BuildContext context, {
    required String question,
    required String answer,
    required AppColorsExtension colors,
    bool isLast = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: isLast
            ? const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              )
            : null,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        iconColor: colors.primary,
        collapsedIconColor: colors.textHint,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColorsExtension colors) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: colors.surfaceVariant,
    );
  }
}
