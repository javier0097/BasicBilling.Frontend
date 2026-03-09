import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/pay_bill/pay_bill_bloc.dart';
import '../blocs/pay_bill/pay_bill_event.dart';
import '../blocs/pay_bill/pay_bill_state.dart';
import '../blocs/pending_bills/pending_bills_bloc.dart';
import '../blocs/pending_bills/pending_bills_event.dart';
import '../blocs/pending_bills/pending_bills_state.dart';
import '../models/bill.dart';
import '../repositories/bill_repository.dart';
import '../repositories/payment_repository.dart';

class PendingBillsScreen extends StatelessWidget {
  const PendingBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PendingBillsBloc(
            billRepository: context.read<BillRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => PayBillBloc(
            paymentRepository: context.read<PaymentRepository>(),
          ),
        ),
      ],
      child: const _PendingBillsView(),
    );
  }
}

class _PendingBillsView extends StatefulWidget {
  const _PendingBillsView();

  @override
  State<_PendingBillsView> createState() => _PendingBillsViewState();
}

class _PendingBillsViewState extends State<_PendingBillsView> {
  final _clientIdController = TextEditingController();
  String _orderBy = '';

  static const _orderOptions = {
    '': 'Default',
    '\$orderby=period asc': 'Period (oldest first)',
    '\$orderby=period desc': 'Period (newest first)',
    '\$orderby=amount asc': 'Amount (low to high)',
    '\$orderby=amount desc': 'Amount (high to low)',
  };

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  void _search() {
    final text = _clientIdController.text.trim();
    if (text.isEmpty || int.tryParse(text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid Client ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<PendingBillsBloc>().add(PendingBillsRequested(
          clientId: int.parse(text),
          oDataQuery: _orderBy.isNotEmpty ? _orderBy : null,
        ));
  }

  void _payBill(Bill bill) {
    context.read<PayBillBloc>().add(PayBillSubmitted(
          clientId: bill.clientId,
          serviceType: bill.serviceType,
          period: bill.period,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Pending Bills'),
      ),
      body: BlocListener<PayBillBloc, PayBillState>(
        listener: (context, state) {
          if (state is PayBillSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Payment processed - \$${state.payment.amount.toStringAsFixed(2)}'),
                backgroundColor: Colors.green,
              ),
            );
            _search();
          } else if (state is PayBillFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _clientIdController,
                          decoration: const InputDecoration(
                            labelText: 'Client ID',
                            hintText: 'Enter client ID',
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _orderBy,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: _orderOptions.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _orderBy = v ?? '');
                      if (_clientIdController.text.trim().isNotEmpty) {
                        _search();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<PendingBillsBloc, PendingBillsState>(
                      builder: (context, state) {
                        if (state is PendingBillsInitial) {
                          return const Center(
                            child: Text('Enter a Client ID to search'),
                          );
                        }
                        if (state is PendingBillsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is PendingBillsFailure) {
                          return Center(
                            child: Text(state.message,
                                style: const TextStyle(color: Colors.red)),
                          );
                        }
                        if (state is PendingBillsLoaded) {
                          if (state.bills.isEmpty) {
                            return const Center(
                                child: Text('No pending bills found'));
                          }
                          return BlocBuilder<PayBillBloc, PayBillState>(
                            builder: (context, payState) {
                              return ListView.builder(
                                itemCount: state.bills.length,
                                itemBuilder: (context, index) {
                                  final bill = state.bills[index];
                                  return Card(
                                    child: ListTile(
                                      leading: Icon(
                                          _serviceIcon(bill.serviceType)),
                                      title: Text(
                                          '${bill.serviceType} - ${bill.period}'),
                                      subtitle: Text(
                                          'Bill #${bill.id} - \$${bill.amount.toStringAsFixed(2)}'),
                                      trailing: FilledButton.tonal(
                                        onPressed: payState is PayBillLoading
                                            ? null
                                            : () => _payBill(bill),
                                        child: payState is PayBillLoading
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : const Text('Pay'),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _serviceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'electricity':
        return Icons.bolt;
      case 'sewer':
        return Icons.plumbing;
      default:
        return Icons.receipt;
    }
  }
}
