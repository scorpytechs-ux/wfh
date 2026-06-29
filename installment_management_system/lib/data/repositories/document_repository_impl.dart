import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/database_helper.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DatabaseHelper _databaseHelper;

  DocumentRepositoryImpl(this._databaseHelper);

  @override
  Future<void> insertDocument(Document document) async {
    final db = await _databaseHelper.database;
    await db.insert('documents', DocumentModel.fromEntity(document).toJson());
  }

  @override
  Future<void> deleteDocument(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Document>> getDocumentsByCustomerId(String customerId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'documents',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'uploadedAt DESC',
    );
    return maps.map((map) => DocumentModel.fromJson(map)).toList();
  }
}
