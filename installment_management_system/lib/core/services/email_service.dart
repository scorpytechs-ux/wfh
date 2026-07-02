import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  // Simulates sending an OTP to the user's email
  Future<String> sendOtpEmail(String email) async {
    // Generate a 6-digit random OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/auth/otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      
      if (response.statusCode == 200) {
        print('📧 EMAIL SERVICE: OTP for login has been successfully sent to $email');
      } else {
        print('⚠️ EMAIL SERVICE: Backend failed to send email. Falling back to local logging.');
        print('🔑 YOUR OTP IS: $otp');
      }
    } catch (e) {
      print('⚠️ EMAIL SERVICE: Could not connect to backend to send email. Falling back to local logging.');
      print('🔑 YOUR OTP IS: $otp');
    }

    return otp;
  }
}
