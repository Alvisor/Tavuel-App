import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/provider_document.dart';

/// Tipos de documentos requeridos para el onboarding.
class DocumentTypeConfig {
  final String type;
  final String label;
  final IconData icon;

  const DocumentTypeConfig({
    required this.type,
    required this.label,
    required this.icon,
  });

  /// Todos los documentos requeridos para completar el onboarding.
  static const List<DocumentTypeConfig> requiredDocuments = [
    DocumentTypeConfig(
      type: 'CEDULA_FRONT',
      label: 'Cedula frente',
      icon: Icons.credit_card,
    ),
    DocumentTypeConfig(
      type: 'CEDULA_BACK',
      label: 'Cedula reverso',
      icon: Icons.credit_card_outlined,
    ),
    DocumentTypeConfig(
      type: 'SELFIE_WITH_CEDULA',
      label: 'Selfie con cedula',
      icon: Icons.face,
    ),
    DocumentTypeConfig(
      type: 'RUT',
      label: 'RUT',
      icon: Icons.description,
    ),
    DocumentTypeConfig(
      type: 'ANTECEDENTES',
      label: 'Antecedentes',
      icon: Icons.verified_user,
    ),
    DocumentTypeConfig(
      type: 'BANK_CERTIFICATE',
      label: 'Certificado bancario',
      icon: Icons.account_balance,
    ),
  ];
}

/// Card individual para subir un documento.
///
/// Muestra el tipo de documento, su estado actual (pendiente, subido,
/// aprobado, rechazado), y permite seleccionar imagen desde camara o galeria.
class DocumentUploadCard extends StatelessWidget {
  final DocumentTypeConfig config;
  final ProviderDocument? document;
  final double? uploadProgress;
  final void Function(String filePath, String documentType) onUpload;

  const DocumentUploadCard({
    super.key,
    required this.config,
    this.document,
    this.uploadProgress,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = document != null;
    final status = isUploaded ? (document!.status ?? 'PENDING') : 'NOT_UPLOADED';
    final isUploading = uploadProgress != null;
    final colors = AppColors.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isUploading ? null : () => _showSourcePicker(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail o icono
              _buildThumbnail(status, colors),
              const SizedBox(width: 16),

              // Info del documento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusWidget(status, isUploading, colors),
                    if (document?.rejectionReason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        document!.rejectionReason!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Accion
              if (isUploading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  _getActionIcon(status),
                  color: _getStatusColor(status, colors),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String status, AppColorsExtension colors) {
    if (document != null && document!.url.isNotEmpty && status != 'REJECTED') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: colors.surfaceVariant,
          child: document!.url.startsWith('http')
              ? Image.network(
                  document!.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildIconPlaceholder(colors),
                )
              : Image.file(
                  File(document!.url),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildIconPlaceholder(colors),
                ),
        ),
      );
    }

    return _buildIconPlaceholder(colors);
  }

  Widget _buildIconPlaceholder(AppColorsExtension colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        config.icon,
        color: colors.textHint,
        size: 24,
      ),
    );
  }

  Widget _buildStatusWidget(
      String status, bool isUploading, AppColorsExtension colors) {
    if (isUploading) {
      return Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: colors.surfaceVariant,
              valueColor:
                  AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Subiendo...',
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(status, colors),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusLabel(status),
          style: TextStyle(
            fontSize: 12,
            color: _getStatusColor(status, colors),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En revisión';
      case 'UPLOADED':
        return 'Subido';
      case 'APPROVED':
        return 'Aprobado';
      case 'REJECTED':
        return 'Rechazado';
      case 'NOT_UPLOADED':
        return 'Sin subir';
      default:
        return 'Sin subir';
    }
  }

  Color _getStatusColor(String status, AppColorsExtension colors) {
    switch (status) {
      case 'PENDING':
        return colors.info;
      case 'UPLOADED':
        return colors.info;
      case 'APPROVED':
        return colors.success;
      case 'REJECTED':
        return colors.error;
      case 'NOT_UPLOADED':
        return colors.textHint;
      default:
        return colors.textHint;
    }
  }

  IconData _getActionIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.refresh;
      case 'PENDING':
      case 'UPLOADED':
        return Icons.check_circle_outline;
      case 'NOT_UPLOADED':
        return Icons.add_photo_alternate_outlined;
      default:
        return Icons.add_photo_alternate_outlined;
    }
  }

  Future<void> _showSourcePicker(BuildContext context) async {
    final colors = AppColors.of(context);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccionar ${config.label}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primary),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: colors.primary),
                title: const Text('Elegir de galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      onUpload(pickedFile.path, config.type);
    }
  }
}
