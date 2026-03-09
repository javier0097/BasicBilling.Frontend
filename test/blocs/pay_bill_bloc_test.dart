import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:basic_billing_frontend/blocs/pay_bill/pay_bill_bloc.dart';
import 'package:basic_billing_frontend/blocs/pay_bill/pay_bill_event.dart';
import 'package:basic_billing_frontend/blocs/pay_bill/pay_bill_state.dart';
import 'package:basic_billing_frontend/models/payment.dart';
import 'package:basic_billing_frontend/repositories/payment_repository.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockPaymentRepository();
  });

  final testPayment = Payment(
    id: 1,
    billId: 1,
    amount: 50.0,
    paymentDate: '2026-03-08T10:00:00Z',
    serviceType: 'Water',
    period: '202603',
    status: 'Paid',
  );

  group('PayBillBloc', () {
    blocTest<PayBillBloc, PayBillState>(
      'emits [Loading, Success] when payment is processed',
      build: () {
        when(() => mockRepository.processPayment(
              clientId: any(named: 'clientId'),
              serviceType: any(named: 'serviceType'),
              period: any(named: 'period'),
            )).thenAnswer((_) async => testPayment);
        return PayBillBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PayBillSubmitted(
        clientId: 100,
        serviceType: 'Water',
        period: '202603',
      )),
      expect: () => [
        isA<PayBillLoading>(),
        isA<PayBillSuccess>(),
      ],
    );

    blocTest<PayBillBloc, PayBillState>(
      'emits [Loading, Failure] when payment fails',
      build: () {
        when(() => mockRepository.processPayment(
              clientId: any(named: 'clientId'),
              serviceType: any(named: 'serviceType'),
              period: any(named: 'period'),
            )).thenThrow(Exception('Bill already paid'));
        return PayBillBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PayBillSubmitted(
        clientId: 100,
        serviceType: 'Water',
        period: '202603',
      )),
      expect: () => [
        isA<PayBillLoading>(),
        isA<PayBillFailure>(),
      ],
    );

    test('initial state is PayBillInitial', () {
      final bloc = PayBillBloc(paymentRepository: mockRepository);
      expect(bloc.state, isA<PayBillInitial>());
    });
  });
}
