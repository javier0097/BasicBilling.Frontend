import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bill_repository.dart';
import 'create_bill_event.dart';
import 'create_bill_state.dart';

class CreateBillBloc extends Bloc<CreateBillEvent, CreateBillState> {
  final BillRepository _billRepository;

  CreateBillBloc({required BillRepository billRepository})
      : _billRepository = billRepository,
        super(CreateBillInitial()) {
    on<CreateBillSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateBillSubmitted event,
    Emitter<CreateBillState> emit,
  ) async {
    emit(CreateBillLoading());
    try {
      final bill = await _billRepository.createBill(
        clientId: event.clientId,
        serviceType: event.serviceType,
        period: event.period,
        amount: event.amount,
      );
      emit(CreateBillSuccess(bill));
    } catch (e) {
      emit(CreateBillFailure(e.toString()));
    }
  }
}
