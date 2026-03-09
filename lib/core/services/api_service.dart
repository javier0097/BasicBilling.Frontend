import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/bill.dart';
import '../../models/payment.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;

  ApiService({required AuthService authService})
      : _authService = authService;

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return _authService.authHeaders(token);
  }

  Future<Bill> createBill({
    required int clientId,
    required String serviceType,
    required String period,
    required double amount,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(ApiConstants.bills),
      headers: headers,
      body: jsonEncode({
        'clientId': clientId,
        'serviceType': serviceType,
        'period': period,
        'amount': amount,
      }),
    );

    if (response.statusCode == 201) {
      return Bill.fromJson(jsonDecode(response.body));
    }

    throw _handleError(response);
  }

  Future<Payment> processPayment({
    required int clientId,
    required String serviceType,
    required String period,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(ApiConstants.payments),
      headers: headers,
      body: jsonEncode({
        'clientId': clientId,
        'serviceType': serviceType,
        'period': period,
      }),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }

    throw _handleError(response);
  }

  Future<List<Bill>> getPendingBills(int clientId, {String? oDataQuery}) async {
    final headers = await _headers();
    var url = ApiConstants.pendingBills(clientId);
    if (oDataQuery != null && oDataQuery.isNotEmpty) {
      url += '?$oDataQuery';
    }

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Bill.fromJson(json)).toList();
    }

    throw _handleError(response);
  }

  Future<List<Payment>> getPaymentHistory(int clientId,
      {String? oDataQuery}) async {
    final headers = await _headers();
    var url = ApiConstants.paymentHistory(clientId);
    if (oDataQuery != null && oDataQuery.isNotEmpty) {
      url += '?$oDataQuery';
    }

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    }

    throw _handleError(response);
  }

  Exception _handleError(http.Response response) {
    final body = response.body;
    String message;

    try {
      final data = jsonDecode(body);
      message = data['message'] ?? data['title'] ?? body;
    } catch (_) {
      message = body;
    }

    return Exception(message);
  }
}
