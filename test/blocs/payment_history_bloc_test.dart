import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:basic_billing_frontend/blocs/payment_history/payment_history_bloc.dart';
import 'package:basic_billing_frontend/blocs/payment_history/payment_history_event.dart';
import 'package:basic_billing_frontend/blocs/payment_history/payment_history_state.dart';
import 'package:basic_billing_frontend/models/payment.dart';
import 'package:basic_billing_frontend/repositories/payment_repository.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockPaymentRepository();
  });

  final testPayments = [
    Payment(id: 1, billId: 1, amount: 50.0, paymentDate: '2026-03-08T10:00:00Z', serviceType: 'Water', period: '202602'),
    Payment(id: 2, billId: 7, amount: 75.0, paymentDate: '2026-03-07T09:00:00Z', serviceType: 'Electricity', period: '202602'),
  ];

  group('PaymentHistoryBloc', () {
    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'emits [Loading, Loaded] when history is fetched',
      build: () {
        when(() => mockRepository.getPaymentHistory(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => testPayments);
        return PaymentHistoryBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PaymentHistoryRequested(clientId: 100)),
      expect: () => [
        isA<PaymentHistoryLoading>(),
        isA<PaymentHistoryLoaded>(),
      ],
    );

    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'emits [Loading, Loaded] with empty list when no history',
      build: () {
        when(() => mockRepository.getPaymentHistory(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => []);
        return PaymentHistoryBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PaymentHistoryRequested(clientId: 999)),
      expect: () => [
        isA<PaymentHistoryLoading>(),
        isA<PaymentHistoryLoaded>(),
      ],
    );

    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'emits [Loading, Failure] when fetch fails',
      build: () {
        when(() => mockRepository.getPaymentHistory(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenThrow(Exception('Client not found'));
        return PaymentHistoryBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PaymentHistoryRequested(clientId: 999)),
      expect: () => [
        isA<PaymentHistoryLoading>(),
        isA<PaymentHistoryFailure>(),
      ],
    );

    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'passes OData query to repository',
      build: () {
        when(() => mockRepository.getPaymentHistory(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => testPayments);
        return PaymentHistoryBloc(paymentRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PaymentHistoryRequested(
        clientId: 100,
        oDataQuery: '\$orderby=paymentDate desc',
      )),
      expect: () => [
        isA<PaymentHistoryLoading>(),
        isA<PaymentHistoryLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.getPaymentHistory(
              100,
              oDataQuery: '\$orderby=paymentDate desc',
            )).called(1);
      },
    );

    test('initial state is PaymentHistoryInitial', () {
      final bloc = PaymentHistoryBloc(paymentRepository: mockRepository);
      expect(bloc.state, isA<PaymentHistoryInitial>());
    });
  });
}
