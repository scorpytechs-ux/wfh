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

  @override
  List<FormDataModel> build() {
    // Listen to auth state changes — reload forms whenever the logged-in user changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final userId = ((next.currentUser?['id'] ?? next.currentUser?['username']) as String?) ?? '';
      if (userId.isNotEmpty && userId != _lastLoadedUserId) {
        _lastLoadedUserId = userId;
        _loadForms(userId);
      } else if (userId.isEmpty) {
        // User logged out — clear state
        _lastLoadedUserId = null;
        state = [];
      }
    });

    // Also attempt an immediate load in case the user is already logged in
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isNotEmpty) {
        _lastLoadedUserId = userId;
        _loadForms(userId);
      }
    }

    return [];
  }

  Future<void> _loadForms(String userId) async {
    try {
      final forms = await _repository.getFormsForUser(userId);
      state = forms;
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Public method to manually reload forms from Firestore
  Future<void> reloadForms() async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isNotEmpty) await _loadForms(userId);
    }
  }

  Future<void> addForm(FormDataModel data) async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isEmpty) return;
      // Ensure the form has a unique ID
      final formData = data.id.isEmpty ? data.copyWith(id: _uuid.v4()) : data;
      await _repository.saveForm(formData, userId);
      state = [...state, formData];
    }
  }

  Future<void> updateForm(FormDataModel updatedData) async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final userId = (user['id'] ?? user['username'] ?? '') as String;
      if (userId.isEmpty) return;
      await _repository.saveForm(updatedData, userId);
      state = [
        for (final form in state)
          if (form.id == updatedData.id) updatedData else form
      ];
    }
  }

  Future<void> deleteForm(String id) async {
    await _repository.deleteForm(id);
    state = state.where((form) => form.id != id).toList();
  }

  void clearForms() {
    // We only clear memory state here (e.g. on logout)
    _lastLoadedUserId = null;
    state = [];
  }
}
