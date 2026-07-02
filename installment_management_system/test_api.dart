import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/candidates/d7e68625-5c4b-4260-bc22-c71df3d5a09f/forms?limit=10&status=active'));
    print("Body: ${response.body}");
  } catch (e) {
    print('Error: $e');
  }
}
