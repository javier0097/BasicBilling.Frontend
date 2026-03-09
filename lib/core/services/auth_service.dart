import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AuthService {
  String? _token;

  Future<String> getToken() async {
    if (_token != null) return _token!;

    final response = await http.post(Uri.parse(ApiConstants.authToken));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'] as String;
      return _token!;
    }

    throw Exception('Failed to obtain token');
  }

  Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
