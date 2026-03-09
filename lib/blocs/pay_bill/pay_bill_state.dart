import 'package:equatable/equatable.dart';
import '../../models/payment.dart';

abstract class PayBillState extends Equatable {
  const PayBillState();

  @override
  List<Object?> get props => [];
}

class PayBillInitial extends PayBillState {}

class PayBillLoading extends PayBillState {}

class PayBillSuccess extends PayBillState {
  final Payment payment;

  const PayBillSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PayBillFailure extends PayBillState {
  final String message;

  const PayBillFailure(this.message);

  @override
  List<Object?> get props => [message];
}
