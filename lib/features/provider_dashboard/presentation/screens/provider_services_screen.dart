import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';

class ProviderServicesScreen extends ConsumerWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios y Precios'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a agregar servicio
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colors.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.handyman_outlined,
                  size: 52,
                  color: colors.textHint,
                ),
              ),
              const SizedBox(height: 24),

              // Titulo
              Text(
                'Sin servicios configurados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Descripcion
              Text(
                'Agrega los servicios que ofreces con sus precios para que los clientes puedan encontrarte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Boton de agregar
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navegar a agregar servicio
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Servicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.textOnSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
