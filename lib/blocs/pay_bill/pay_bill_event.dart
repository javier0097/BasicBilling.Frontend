import 'package:equatable/equatable.dart';

abstract class PayBillEvent extends Equatable {
  const PayBillEvent();

  @override
  List<Object> get props => [];
}

class PayBillSubmitted extends PayBillEvent {
  final int clientId;
  final String serviceType;
  final String period;

  const PayBillSubmitted({
    required this.clientId,
    required this.serviceType,
    required this.period,
  });

  @override
  List<Object> get props => [clientId, serviceType, period];
}
