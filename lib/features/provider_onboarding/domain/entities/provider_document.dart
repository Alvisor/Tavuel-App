class ProviderDocument {
  final String? id;
  final String type;
  final String url;
  final String status;
  final String? rejectionReason;

  const ProviderDocument({
    this.id,
    required this.type,
    required this.url,
    this.status = 'PENDING',
    this.rejectionReason,
  });
}
