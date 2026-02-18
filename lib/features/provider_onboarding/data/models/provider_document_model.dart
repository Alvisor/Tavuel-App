import '../../domain/entities/provider_document.dart';

class ProviderDocumentModel extends ProviderDocument {
  const ProviderDocumentModel({
    super.id,
    required super.type,
    required super.url,
    super.status,
    super.rejectionReason,
  });

  factory ProviderDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProviderDocumentModel(
      id: json['id'] as String?,
      type: json['type'] as String,
      url: json['url'] as String,
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}
