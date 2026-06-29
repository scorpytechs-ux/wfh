import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../../../domain/entities/document.dart';
import '../../../domain/repositories/document_repository.dart';
import '../../../core/providers/repository_providers.dart';

class DocumentState {
  final bool isLoading;
  final String? error;
  final List<Document> documents;

  DocumentState({this.isLoading = false, this.error, this.documents = const []});

  DocumentState copyWith({bool? isLoading, String? error, List<Document>? documents}) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      documents: documents ?? this.documents,
    );
  }
}

final documentViewModelProvider = NotifierProvider<DocumentViewModel, DocumentState>(DocumentViewModel.new);

class DocumentViewModel extends Notifier<DocumentState> {
  late final DocumentRepository _repository;
  final _uuid = const Uuid();

  @override
  DocumentState build() {
    _repository = ref.watch(documentRepositoryProvider);
    return DocumentState();
  }

  Future<void> loadDocuments(String customerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents = await _repository.getDocumentsByCustomerId(customerId);
      state = state.copyWith(isLoading: false, documents: documents);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadDocument({
    required String customerId,
    required String filePath,
    required String documentType,
    required String description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doc = Document(
        id: _uuid.v4(),
        customerId: customerId,
        fileName: filePath.split(Platform.pathSeparator).last,
        filePath: filePath,
        uploadedAt: DateTime.now(),
      );
      await _repository.insertDocument(doc);
      await loadDocuments(customerId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteDocument(String id, String customerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteDocument(id);
      await loadDocuments(customerId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
