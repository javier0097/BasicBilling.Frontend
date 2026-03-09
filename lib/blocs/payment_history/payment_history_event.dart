import 'package:equatable/equatable.dart';

abstract class PaymentHistoryEvent extends Equatable {
  const PaymentHistoryEvent();

  @override
  List<Object?> get props => [];
}

class PaymentHistoryRequested extends PaymentHistoryEvent {
  final int clientId;
  final String? oDataQuery;

  const PaymentHistoryRequested({required this.clientId, this.oDataQuery});

  @override
  List<Object?> get props => [clientId, oDataQuery];
}
