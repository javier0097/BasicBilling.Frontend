import 'package:equatable/equatable.dart';
import '../../models/bill.dart';

abstract class CreateBillState extends Equatable {
  const CreateBillState();

  @override
  List<Object?> get props => [];
}

class CreateBillInitial extends CreateBillState {}

class CreateBillLoading extends CreateBillState {}

class CreateBillSuccess extends CreateBillState {
  final Bill bill;

  const CreateBillSuccess(this.bill);

  @override
  List<Object?> get props => [bill];
}

class CreateBillFailure extends CreateBillState {
  final String message;

  const CreateBillFailure(this.message);

  @override
  List<Object?> get props => [message];
}
