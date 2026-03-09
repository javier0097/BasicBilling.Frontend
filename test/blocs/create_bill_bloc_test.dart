import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:basic_billing_frontend/blocs/create_bill/create_bill_bloc.dart';
import 'package:basic_billing_frontend/blocs/create_bill/create_bill_event.dart';
import 'package:basic_billing_frontend/blocs/create_bill/create_bill_state.dart';
import 'package:basic_billing_frontend/models/bill.dart';
import 'package:basic_billing_frontend/repositories/bill_repository.dart';

class MockBillRepository extends Mock implements BillRepository {}

void main() {
  late MockBillRepository mockRepository;

  setUp(() {
    mockRepository = MockBillRepository();
  });

  final testBill = Bill(
    id: 1,
    clientId: 100,
    serviceType: 'Water',
    period: '202603',
    amount: 50.0,
    status: 'Pending',
  );

  group('CreateBillBloc', () {
    blocTest<CreateBillBloc, CreateBillState>(
      'emits [Loading, Success] when bill is created successfully',
      build: () {
        when(() => mockRepository.createBill(
              clientId: any(named: 'clientId'),
              serviceType: any(named: 'serviceType'),
              period: any(named: 'period'),
              amount: any(named: 'amount'),
            )).thenAnswer((_) async => testBill);
        return CreateBillBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const CreateBillSubmitted(
        clientId: 100,
        serviceType: 'Water',
        period: '202603',
        amount: 50.0,
      )),
      expect: () => [
        isA<CreateBillLoading>(),
        isA<CreateBillSuccess>(),
      ],
    );

    blocTest<CreateBillBloc, CreateBillState>(
      'emits [Loading, Failure] when repository throws',
      build: () {
        when(() => mockRepository.createBill(
              clientId: any(named: 'clientId'),
              serviceType: any(named: 'serviceType'),
              period: any(named: 'period'),
              amount: any(named: 'amount'),
            )).thenThrow(Exception('Client not found'));
        return CreateBillBloc(billRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const CreateBillSubmitted(
        clientId: 999,
        serviceType: 'Water',
        period: '202603',
        amount: 50.0,
      )),
      expect: () => [
        isA<CreateBillLoading>(),
        isA<CreateBillFailure>(),
      ],
    );

    test('initial state is CreateBillInitial', () {
      final bloc = CreateBillBloc(billRepository: mockRepository);
      expect(bloc.state, isA<CreateBillInitial>());
    });
  });
}
