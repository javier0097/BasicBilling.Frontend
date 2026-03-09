import 'package:equatable/equatable.dart';

abstract class CreateBillEvent extends Equatable {
  const CreateBillEvent();

  @override
  List<Object> get props => [];
}

class CreateBillSubmitted extends CreateBillEvent {
  final int clientId;
  final String serviceType;
  final String period;
  final double amount;

  const CreateBillSubmitted({
    required this.clientId,
    required this.serviceType,
    required this.period,
    required this.amount,
  });

  @override
  List<Object> get props => [clientId, serviceType, period, amount];
}
