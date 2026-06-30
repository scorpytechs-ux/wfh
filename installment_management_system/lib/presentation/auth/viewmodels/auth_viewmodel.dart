import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/email_service.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool rememberMe;
  final bool isBlocked;
  final String? error;
  final Map<String, dynamic>? currentUser;
  final String? pendingOtp;
  final String? pendingEmail;

  AuthState({
    this.isAuthenticated = false, 
    this.isLoading = false, 
    this.rememberMe = false,
    this.isBlocked = false,
    this.error,
    this.currentUser,
    this.pendingOtp,
    this.pendingEmail,
  });

  AuthState copyWith({
    bool? isAuthenticated, 
    bool? isLoading, 
    bool? rememberMe, 
    bool? isBlocked,
    String? error,
    Map<String, dynamic>? currentUser,
    String? pendingOtp,
    String? pendingEmail,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      isBlocked: isBlocked ?? this.isBlocked,
      error: clearError ? null : (error ?? this.error),
      currentUser: currentUser ?? this.currentUser,
      pendingOtp: pendingOtp ?? this.pendingOtp,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  final AuthRepository _repository = AuthRepository();
  final EmailService _emailService = EmailService();
  StreamSubscription<Map<String, dynamic>?>? _userSubscription;

  void _listenToUserChanges(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _repository.getUserStream(userId).listen((user) {
      if (user != null) {
        if (user['isBlocked'] == 1) {
          state = state.copyWith(isBlocked: true, currentUser: user);
        } else {
          state = state.copyWith(currentUser: user, isBlocked: false);
        }
      }
    });
  }

  @override
  AuthState build() {
    _loadRememberMe();
    ref.onDispose(() {
      _userSubscription?.cancel();
    });
    return AuthState();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('remembered_username');
    final password = prefs.getString('remembered_password');
    if (username != null && password != null) {
      // Auto-login if remembered
      final user = await _repository.loginUser(username, password);
      if (user != null) {
        if (user['isBlocked'] == 1) {
          state = state.copyWith(isBlocked: true, currentUser: user);
          return;
        }
        state = state.copyWith(
          isAuthenticated: true, 
          rememberMe: true, 
          currentUser: user
        );
        _listenToUserChanges(user['id']);
      }
    }
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (await _repository.isUsernameTaken(username)) {
      state = state.copyWith(isLoading: false, error: 'Username is already taken');
      return false;
    }
    if (await _repository.isEmailTaken(email)) {
      state = state.copyWith(isLoading: false, error: 'Email is already registered');
      return false;
    }

    final user = await _repository.registerUser(
      name: name,
      email: email,
      username: username,
      password: password,
    );

    if (user != null) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Registration failed');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, isBlocked: false);

    final user = await _repository.loginUser(username, password);

    if (user != null) {
      if (user['isBlocked'] == 1) {
        state = state.copyWith(
          isLoading: false,
          isBlocked: true,
          currentUser: user,
        );
        return false; // Return false so OTP screen isn't shown
      }

      // Success. Generate OTP.
      final email = user['email'] as String;
      final otp = await _emailService.sendOtpEmail(email);

      // Save credentials if remember me
      if (state.rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_username', username);
        await prefs.setString('remembered_password', password);
      }

      state = state.copyWith(
        isLoading: false, 
        currentUser: user,
        pendingOtp: otp,
        pendingEmail: email,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Invalid username or password');
      return false;
    }
  }

  bool verifyOtp(String enteredOtp) {
    if (enteredOtp == state.pendingOtp) {
      state = state.copyWith(
        isAuthenticated: true, 
        pendingOtp: null, 
        pendingEmail: null,
      );
      if (state.currentUser != null) {
        _listenToUserChanges(state.currentUser!['id']);
      }
      return true;
    } else {
      state = state.copyWith(error: 'Invalid OTP');
      return false;
    }
  }

  Future<void> resendOtp() async {
    final email = state.pendingEmail;
    if (email != null) {
      final otp = await _emailService.sendOtpEmail(email);
      state = state.copyWith(pendingOtp: otp);
    }
  }

  Future<void> logout() async {
    _userSubscription?.cancel();
    _userSubscription = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_username');
    await prefs.remove('remembered_password');
    state = AuthState();
  }

  Future<void> blockCurrentUser() async {
    final user = state.currentUser;
    if (user != null) {
      await _repository.updateBlockStatus(user['id'], true);
      state = state.copyWith(isBlocked: true);
    }
  }
}
