import 'package:equatable/equatable.dart';

abstract class PendingBillsEvent extends Equatable {
  const PendingBillsEvent();

  @override
  List<Object?> get props => [];
}

class PendingBillsRequested extends PendingBillsEvent {
  final int clientId;
  final String? oDataQuery;

  const PendingBillsRequested({required this.clientId, this.oDataQuery});

  @override
  List<Object?> get props => [clientId, oDataQuery];
}
