import 'package:equatable/equatable.dart';
import '../../models/payment.dart';

abstract class PaymentHistoryState extends Equatable {
  const PaymentHistoryState();

  @override
  List<Object?> get props => [];
}

class PaymentHistoryInitial extends PaymentHistoryState {}

class PaymentHistoryLoading extends PaymentHistoryState {}

class PaymentHistoryLoaded extends PaymentHistoryState {
  final List<Payment> payments;

  const PaymentHistoryLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentHistoryFailure extends PaymentHistoryState {
  final String message;

  const PaymentHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
