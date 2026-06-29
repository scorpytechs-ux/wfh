import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/document_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CustomerRepositoryImpl(dbHelper);
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DocumentRepositoryImpl(dbHelper);
});
