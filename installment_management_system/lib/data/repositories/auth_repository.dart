import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<bool> isUsernameTaken(String username) async {
    final result = await _db.collection('users').where('username', isEqualTo: username).get();
    return result.docs.isNotEmpty;
  }

  Future<bool> isEmailTaken(String email) async {
    final result = await _db.collection('users').where('email', isEqualTo: email).get();
    return result.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
    String role = 'candidate',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    final userMap = {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'createdAt': now,
      'role': role,
      'isBlocked': 0,
      'earnings': 0.0,
      'dailyTarget': 0,
      'monthlyTarget': 0,
      'lastOtp': '',
    };

    try {
      await _db.collection('users').doc(id).set(userMap);
      return userMap;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final result = await _db.collection('users')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (result.docs.isNotEmpty) {
      final doc = result.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  // --- ADMIN FEATURES ---

  Future<List<Map<String, dynamic>>> getAllCandidates() async {
    final result = await _db.collection('users')
        .where('role', isEqualTo: 'candidate')
        .get();
    
    final docs = result.docs.map((doc) => doc.data()).toList();
    // Sort by createdAt in Dart to avoid needing a Firestore composite index
    docs.sort((a, b) {
      final aDate = a['createdAt'] as String? ?? '';
      final bDate = b['createdAt'] as String? ?? '';
      return bDate.compareTo(aDate); // descending
    });
    return docs;
  }

  Future<void> updateBlockStatus(String userId, bool isBlocked) async {
    await _db.collection('users').doc(userId).update({
      'isBlocked': isBlocked ? 1 : 0
    });
  }

  Future<void> updateEarnings(String userId, double earnings) async {
    await _db.collection('users').doc(userId).update({
      'earnings': earnings
    });
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Stream<Map<String, dynamic>?> getUserStream(String id) {
    return _db.collection('users').doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        return data;
      }
      return null;
    });
  }
}
