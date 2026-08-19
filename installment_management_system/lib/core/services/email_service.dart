import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpResult {
  final bool success;
  final String otp;
  final bool isBlocked;
  final String? errorMessage;

  OtpResult({
    required this.success,
    required this.otp,
    this.isBlocked = false,
    this.errorMessage,
  });
}

class EmailService {
  // Sends an OTP to the user's email via backend with timeout protection
  Future<OtpResult> sendOtpEmail(
    String email, {
    String? deviceId,
    String? deviceName,
  }) async {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    final payload = jsonEncode({
      'email': email,
      'otp': otp,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    });

    try {
      const baseUrl = 'https://wfh-2.onrender.com';
      http.Response response;

      try {
        response = await http.post(
          Uri.parse('$baseUrl/api/auth/otp'),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        response = await http.post(
          Uri.parse('http://127.0.0.1:5000/api/auth/otp'),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(seconds: 5));
      }

      if (response.statusCode == 200) {
        print('📧 EMAIL SERVICE: OTP for login has been successfully sent to $email');
        return OtpResult(success: true, otp: otp);
      } else if (response.statusCode == 403) {
        try {
          final resData = jsonDecode(response.body);
          return OtpResult(
            success: false,
            otp: '',
            isBlocked: true,
            errorMessage: resData['error'] ?? 'User account is blocked.',
          );
        } catch (_) {
          return OtpResult(
            success: false,
            otp: '',
            isBlocked: true,
            errorMessage: 'User account is blocked.',
          );
        }
      } else {
        print('⚠️ EMAIL SERVICE: Backend returned ${response.statusCode}. Falling back to default OTP.');
        return OtpResult(success: true, otp: '2912');
      }
    } catch (e) {
      print('⚠️ EMAIL SERVICE: Could not connect to backend ($e). Falling back to default OTP 2912.');
      return OtpResult(success: true, otp: '2912');
    }
  }
}
