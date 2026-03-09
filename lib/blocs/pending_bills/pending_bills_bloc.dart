import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bill_repository.dart';
import 'pending_bills_event.dart';
import 'pending_bills_state.dart';

class PendingBillsBloc extends Bloc<PendingBillsEvent, PendingBillsState> {
  final BillRepository _billRepository;

  PendingBillsBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(PendingBillsInitial()) {
    on<PendingBillsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PendingBillsRequested event,
    Emitter<PendingBillsState> emit,
  ) async {
    emit(PendingBillsLoading());
    try {
      final bills = await _billRepository.getPendingBills(
        event.clientId,
        oDataQuery: event.oDataQuery,
      );
      emit(PendingBillsLoaded(bills));
    } catch (e) {
      emit(PendingBillsFailure(e.toString()));
    }
  }
}
