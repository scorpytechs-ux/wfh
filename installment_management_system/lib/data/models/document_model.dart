import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  DocumentModel({
    required super.id,
    required super.customerId,
    required super.fileName,
    required super.filePath,
    required super.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      customerId: json['customerId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'fileName': fileName,
      'filePath': filePath,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
  
  factory DocumentModel.fromEntity(Document doc) {
    return DocumentModel(
      id: doc.id,
      customerId: doc.customerId,
      fileName: doc.fileName,
      filePath: doc.filePath,
      uploadedAt: doc.uploadedAt,
    );
  }
}
