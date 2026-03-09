class ApiConstants {
  static const String baseUrl = 'http://localhost:5101/api';
  static const String authToken = '$baseUrl/auth/token';
  static const String bills = '$baseUrl/bills';
  static const String payments = '$baseUrl/payments';

  static String pendingBills(int clientId) =>
      '$baseUrl/clients/$clientId/pending-bills';

  static String paymentHistory(int clientId) =>
      '$baseUrl/clients/$clientId/payment-history';
}
