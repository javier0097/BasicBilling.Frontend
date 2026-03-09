import 'package:equatable/equatable.dart';
import '../../models/bill.dart';

abstract class PendingBillsState extends Equatable {
  const PendingBillsState();

  @override
  List<Object?> get props => [];
}

class PendingBillsInitial extends PendingBillsState {}

class PendingBillsLoading extends PendingBillsState {}

class PendingBillsLoaded extends PendingBillsState {
  final List<Bill> bills;

  const PendingBillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class PendingBillsFailure extends PendingBillsState {
  final String message;

  const PendingBillsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
