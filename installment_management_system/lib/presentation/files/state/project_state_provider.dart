import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_data_model.dart';
import '../../../data/repositories/form_repository.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'package:uuid/uuid.dart';

final projectStateProvider = NotifierProvider<ProjectStateNotifier, List<FormDataModel>>(() {
  return ProjectStateNotifier();
});

// Provides the target number of forms expected for the current project
final targetFormCountProvider = NotifierProvider<TargetFormCountNotifier, int>(() {
  return TargetFormCountNotifier();
});

class TargetFormCountNotifier extends Notifier<int> {
  @override
  int build() => 18;

  void setCount(int count) {
    state = count;
  }
}

class ProjectStateNotifier extends Notifier<List<FormDataModel>> {
  final FormRepository _repository = FormRepository();
  final _uuid = const Uuid();
  String? _lastLoadedUserId;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  List<FormDataModel> build() {
    // Listen to auth state changes — reload forms whenever the logged-in user changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final userId = ((next.currentUser?['id'] ?? next.currentUser?['username']) as String?) ?? '';
      if (userId.isNotEmpty && userId != _lastLoadedUserId) {
        _lastLoadedUserId = userId;
        _listenToForms(userId);
      } else if (userId.isEmpty) {
        // User logged out — clear state
        _lastLoadedUserId = null;
        _subscription?.cancel();
        _allForms = [];
        state = [];
      }
    });

    // Also attempt an immediate load in case the user is already logged in
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isNotEmpty) {
        _lastLoadedUserId = userId;
        _listenToForms(userId);
      }
    }

    // Return empty initially, stream will populate it
    return [];
  }

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  List<FormDataModel> _allForms = [];

  void _listenToForms(String userId) {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('forms')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      List<FormDataModel> parsedForms = [];
      for (var doc in snapshot.docs) {
        final docData = doc.data();
        final status = docData['status'] as String? ?? 'pending';
        if (status == 'archived') continue;

        List<dynamic> parsedMistakes = [];
        if (docData['mistakes'] is String) {
          try { parsedMistakes = jsonDecode(docData['mistakes']); } catch (_) {}
        } else if (docData['mistakes'] is List) {
          parsedMistakes = docData['mistakes'];
        }

        parsedForms.add(FormDataModel(
          id: docData['id'] as String? ?? '',
          serialNo: docData['serialNo']?.toString() ?? '',
          title: docData['title'] as String? ?? '',
          firstName: docData['firstName'] as String? ?? '',
          lastName: docData['lastName'] as String? ?? '',
          initial: docData['initial'] as String? ?? '',
          email: docData['email'] as String? ?? '',
          fatherName: docData['fatherName'] as String? ?? '',
          dob: docData['dob'] as String? ?? '',
          gender: docData['gender'] as String? ?? '',
          profession: docData['profession'] as String? ?? '',
          mailingStreet: docData['mailingStreet'] as String? ?? '',
          mailingCity: docData['mailingCity'] as String? ?? '',
          mailingPostal: docData['mailingPostal']?.toString() ?? '',
          mailingCountry: docData['mailingCountry'] as String? ?? '',
          serviceProvider: docData['serviceProvider'] as String? ?? '',
          fileNo: docData['fileNo'] as String? ?? '',
          referenceNo: docData['referenceNo'] as String? ?? '',
          simNo: docData['simNo'] as String? ?? '',
          typeOfNetwork: docData['typeOfNetwork'] as String? ?? '',
          cellModelNo: docData['cellModelNo'] as String? ?? '',
          imsi1: docData['imsi1'] as String? ?? '',
          imsi2: docData['imsi2'] as String? ?? '',
          typeOfPlan: docData['typeOfPlan'] as String? ?? '',
          creditCardType: docData['creditCardType'] as String? ?? '',
          contractValue: docData['contractValue']?.toString() ?? '',
          dateOfIssue: docData['dateOfIssue'] as String? ?? '',
          dateOfRenewal: docData['dateOfRenewal'] as String? ?? '',
          installment: docData['installment']?.toString() ?? '',
          amountInWords: docData['amountInWords'] as String? ?? '',
          remarks: docData['remarks'] as String? ?? '',
          score: (docData['score'] as num?)?.toDouble() ?? 0.0,
          mistakes: parsedMistakes.map((e) => e.toString()).toList(),
          status: status,
          submittedDate: docData['submittedDate'] as String?,
        ));
      }
      
      _allForms = parsedForms;
      _updatePaginatedState();
    });
  }

  void _updatePaginatedState() {
    final limit = 50;
    final endIndex = _currentPage * limit;
    if (endIndex >= _allForms.length) {
      _hasMore = false;
      state = List.from(_allForms);
    } else {
      _hasMore = true;
      state = _allForms.sublist(0, endIndex);
    }
  }

  Future<void> loadMoreForms() async {
    if (!_hasMore) return;
    _currentPage++;
    _updatePaginatedState();
  }

  /// Public method to manually reload forms from Firestore
  Future<void> reloadForms() async {
    // With stream, reload can just be ignored or we can reset pagination
    _currentPage = 1;
    _updatePaginatedState();
  }

  Future<void> addForm(FormDataModel data) async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isEmpty) return;
      // Ensure the form has a unique ID
      final formData = data.id.isEmpty ? data.copyWith(id: _uuid.v4()) : data;
      await _repository.saveForm(formData, userId);
      // We don't need to manually update state, the stream will catch it
    }
  }

  Future<void> updateForm(FormDataModel updatedData) async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isEmpty) return;
      await _repository.saveForm(updatedData, userId);
      // Stream catches it
    }
  }

  Future<void> deleteForm(String id) async {
    await _repository.deleteForm(id);
    // Stream catches it
  }

  void clearForms() {
    _lastLoadedUserId = null;
    _subscription?.cancel();
    _allForms = [];
    state = [];
  }
}
