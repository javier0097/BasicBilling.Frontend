import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/payment_repository.dart';
import 'payment_history_event.dart';
import 'payment_history_state.dart';

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final PaymentRepository _paymentRepository;

  PaymentHistoryBloc({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(PaymentHistoryInitial()) {
    on<PaymentHistoryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PaymentHistoryRequested event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(PaymentHistoryLoading());
    try {
      final payments = await _paymentRepository.getPaymentHistory(
        event.clientId,
        oDataQuery: event.oDataQuery,
      );
      emit(PaymentHistoryLoaded(payments));
    } catch (e) {
      emit(PaymentHistoryFailure(e.toString()));
    }
  }
}
