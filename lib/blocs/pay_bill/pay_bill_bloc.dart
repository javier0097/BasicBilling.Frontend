import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/payment_repository.dart';
import 'pay_bill_event.dart';
import 'pay_bill_state.dart';

class PayBillBloc extends Bloc<PayBillEvent, PayBillState> {
  final PaymentRepository _paymentRepository;

  PayBillBloc({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(PayBillInitial()) {
    on<PayBillSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    PayBillSubmitted event,
    Emitter<PayBillState> emit,
  ) async {
    emit(PayBillLoading());
    try {
      final payment = await _paymentRepository.processPayment(
        clientId: event.clientId,
        serviceType: event.serviceType,
        period: event.period,
      );
      emit(PayBillSuccess(payment));
    } catch (e) {
      emit(PayBillFailure(e.toString()));
    }
  }
}
