import '../core/services/api_service.dart';
import '../models/payment.dart';

class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<Payment> processPayment({
    required int clientId,
    required String serviceType,
    required String period,
  }) =>
      _apiService.processPayment(
        clientId: clientId,
        serviceType: serviceType,
        period: period,
      );

  Future<List<Payment>> getPaymentHistory(int clientId,
          {String? oDataQuery}) =>
      _apiService.getPaymentHistory(clientId, oDataQuery: oDataQuery);
}
