import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:basic_billing_frontend/blocs/pending_bills/pending_bills_bloc.dart';
import 'package:basic_billing_frontend/blocs/pending_bills/pending_bills_event.dart';
import 'package:basic_billing_frontend/blocs/pending_bills/pending_bills_state.dart';
import 'package:basic_billing_frontend/models/bill.dart';
import 'package:basic_billing_frontend/repositories/bill_repository.dart';

class MockBillRepository extends Mock implements BillRepository {}

void main() {
  late MockBillRepository mockRepository;

  setUp(() {
    mockRepository = MockBillRepository();
  });

  final testBills = [
    Bill(id: 1, clientId: 100, serviceType: 'Water', period: '202602', amount: 50.0, status: 'Pending'),
    Bill(id: 2, clientId: 100, serviceType: 'Electricity', period: '202602', amount: 75.0, status: 'Pending'),
  ];

  group('PendingBillsBloc', () {
    blocTest<PendingBillsBloc, PendingBillsState>(
      'emits [Loading, Loaded] when bills are fetched',
      build: () {
        when(() => mockRepository.getPendingBills(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => testBills);
        return PendingBillsBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PendingBillsRequested(clientId: 100)),
      expect: () => [
        isA<PendingBillsLoading>(),
        isA<PendingBillsLoaded>(),
      ],
    );

    blocTest<PendingBillsBloc, PendingBillsState>(
      'emits [Loading, Loaded] with empty list when no bills found',
      build: () {
        when(() => mockRepository.getPendingBills(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => []);
        return PendingBillsBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PendingBillsRequested(clientId: 999)),
      expect: () => [
        isA<PendingBillsLoading>(),
        isA<PendingBillsLoaded>(),
      ],
    );

    blocTest<PendingBillsBloc, PendingBillsState>(
      'emits [Loading, Failure] when fetch fails',
      build: () {
        when(() => mockRepository.getPendingBills(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenThrow(Exception('Client not found'));
        return PendingBillsBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PendingBillsRequested(clientId: 999)),
      expect: () => [
        isA<PendingBillsLoading>(),
        isA<PendingBillsFailure>(),
      ],
    );

    blocTest<PendingBillsBloc, PendingBillsState>(
      'passes OData query to repository',
      build: () {
        when(() => mockRepository.getPendingBills(
              any(),
              oDataQuery: any(named: 'oDataQuery'),
            )).thenAnswer((_) async => testBills);
        return PendingBillsBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const PendingBillsRequested(
        clientId: 100,
        oDataQuery: '\$orderby=amount desc',
      )),
      expect: () => [
        isA<PendingBillsLoading>(),
        isA<PendingBillsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.getPendingBills(
              100,
              oDataQuery: '\$orderby=amount desc',
            )).called(1);
      },
    );

    test('initial state is PendingBillsInitial', () {
      final bloc = PendingBillsBloc(billRepository: mockRepository);
      expect(bloc.state, isA<PendingBillsInitial>());
    });
  });
}
