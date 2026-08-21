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

  Future<Map<String, dynamic>?> loginUser(String identifier, String password) async {
    try {
      // 1. Try matching by username first
      var result = await _db.collection('users')
          .where('username', isEqualTo: identifier)
          .where('password', isEqualTo: password)
          .get();

      // 2. If not found, try matching by email
      if (result.docs.isEmpty) {
        result = await _db.collection('users')
            .where('email', isEqualTo: identifier)
            .where('password', isEqualTo: password)
            .get();
      }

      if (result.docs.isNotEmpty) {
        final doc = result.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print("Error in loginUser repository: $e");
      return null;
    }
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

  // --- DEVICE MANAGEMENT ---

  Future<void> registerDeviceSession({
    required String userId,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final docRef = _db.collection('users').doc(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final data = doc.data()!;
      List<dynamic> activeDevices = (data['activeDevices'] as List<dynamic>?) != null
          ? List.from(data['activeDevices'])
          : [];

      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      const maxInactivityMinutes = 30;

      // Filter out stale sessions and server-generated OTP dummy IDs (e.g. dev_1787328049502_nomw6)
      final dummyPattern = RegExp(r'^dev_\d{10,}');

      final concurrentOtherDevices = activeDevices.where((d) {
        if (d is! Map || d['deviceId'] == null || d['deviceId'] == deviceId) {
          return false;
        }
        final otherDeviceId = d['deviceId'].toString();
        if (dummyPattern.hasMatch(otherDeviceId)) {
          return false; // Ignore server dummy OTP artifact
        }
        final lastActiveStr = d['lastActive'] as String?;
        if (lastActiveStr == null || lastActiveStr.isEmpty) return false;
        try {
          final lastActiveTime = DateTime.parse(lastActiveStr);
          final diff = now.difference(lastActiveTime).inMinutes.abs();
          return diff < maxInactivityMinutes;
        } catch (_) {
          return false;
        }
      }).toList();

      if (concurrentOtherDevices.isNotEmpty) {
        // Genuine multi-device simultaneous login detected!
        final blockReason = 'Auto-blocked: Simultaneous login detected on 2 or more devices.';
        activeDevices.add({
          'deviceId': deviceId,
          'deviceName': 'Secondary Device ($deviceName)',
          'lastActive': nowIso,
        });
        await docRef.update({
          'isBlocked': 1,
          'blockReason': blockReason,
          'activeDevices': activeDevices,
          'lastLoginAt': nowIso,
        });
      } else {
        // Single device login -> cleanly keep only this active device session
        await docRef.update({
          'activeDevices': [
            {
              'deviceId': deviceId,
              'deviceName': deviceName,
              'lastActive': nowIso,
            }
          ],
          'lastLoginAt': nowIso,
        });
      }
    } catch (e) {
      print('Error in registerDeviceSession: $e');
    }
  }

  Future<void> removeDeviceSession({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final docRef = _db.collection('users').doc(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final data = doc.data()!;
      List<dynamic> activeDevices = (data['activeDevices'] as List<dynamic>?) != null
          ? List.from(data['activeDevices'])
          : [];

      activeDevices.removeWhere((d) => d is Map && d['deviceId'] == deviceId);

      await docRef.update({
        'activeDevices': activeDevices,
      });
    } catch (e) {
      print('Error in removeDeviceSession: $e');
    }
  }
}

