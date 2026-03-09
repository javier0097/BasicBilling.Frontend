import '../core/services/api_service.dart';
import '../models/bill.dart';

class BillRepository {
  final ApiService _apiService;

  BillRepository({required ApiService apiService}) : _apiService = apiService;

  Future<Bill> createBill({
    required int clientId,
    required String serviceType,
    required String period,
    required double amount,
  }) =>
      _apiService.createBill(
        clientId: clientId,
        serviceType: serviceType,
        period: period,
        amount: amount,
      );

  Future<List<Bill>> getPendingBills(int clientId, {String? oDataQuery}) =>
      _apiService.getPendingBills(clientId, oDataQuery: oDataQuery);
}
