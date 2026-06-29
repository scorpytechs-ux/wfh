import '../entities/document.dart';

abstract class DocumentRepository {
  Future<void> insertDocument(Document document);
  Future<void> deleteDocument(String id);
  Future<List<Document>> getDocumentsByCustomerId(String customerId);
}
