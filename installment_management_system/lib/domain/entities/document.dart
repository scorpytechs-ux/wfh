class Document {
  final String id;
  final String customerId;
  final String fileName;
  final String filePath;
  final DateTime uploadedAt;

  Document({
    required this.id,
    required this.customerId,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
  });
}
