import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../blocs/payment_history/payment_history_bloc.dart';
import '../blocs/payment_history/payment_history_event.dart';
import '../blocs/payment_history/payment_history_state.dart';
import '../repositories/payment_repository.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentHistoryBloc(
        paymentRepository: context.read<PaymentRepository>(),
      ),
      child: const _PaymentHistoryView(),
    );
  }
}

class _PaymentHistoryView extends StatefulWidget {
  const _PaymentHistoryView();

  @override
  State<_PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<_PaymentHistoryView> {
  final _clientIdController = TextEditingController();
  String _orderBy = '\$orderby=paymentDate desc';
  String _filterService = '';

  static const _orderOptions = {
    '\$orderby=paymentDate desc': 'Date (newest first)',
    '\$orderby=paymentDate asc': 'Date (oldest first)',
    '\$orderby=amount asc': 'Amount (low to high)',
    '\$orderby=amount desc': 'Amount (high to low)',
  };

  static const _serviceFilterOptions = {
    '': 'All services',
    'Water': 'Water',
    'Electricity': 'Electricity',
    'Sewer': 'Sewer',
  };

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  String _buildODataQuery() {
    final parts = <String>[];

    if (_filterService.isNotEmpty) {
      parts.add("\$filter=serviceType eq '$_filterService'");
    }

    parts.add(_orderBy);

    return parts.join('&');
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

    context.read<PaymentHistoryBloc>().add(PaymentHistoryRequested(
          clientId: int.parse(text),
          oDataQuery: _buildODataQuery(),
        ));
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy - HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Payment History'),
      ),
      body: Padding(
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterService,
                        decoration:
                            const InputDecoration(labelText: 'Filter by service'),
                        items: _serviceFilterOptions.entries
                            .map((e) => DropdownMenuItem(
                                value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _filterService = v ?? '');
                          if (_clientIdController.text.trim().isNotEmpty) {
                            _search();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _orderBy,
                        decoration:
                            const InputDecoration(labelText: 'Sort by'),
                        items: _orderOptions.entries
                            .map((e) => DropdownMenuItem(
                                value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) {
                          setState(() =>
                              _orderBy = v ?? '\$orderby=paymentDate desc');
                          if (_clientIdController.text.trim().isNotEmpty) {
                            _search();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
                    builder: (context, state) {
                      if (state is PaymentHistoryInitial) {
                        return const Center(
                          child: Text('Enter a Client ID to search'),
                        );
                      }
                      if (state is PaymentHistoryLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (state is PaymentHistoryFailure) {
                        return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                        );
                      }
                      if (state is PaymentHistoryLoaded) {
                        if (state.payments.isEmpty) {
                          return const Center(
                              child: Text('No payment history found'));
                        }
                        return ListView.builder(
                          itemCount: state.payments.length,
                          itemBuilder: (context, index) {
                            final payment = state.payments[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                title: Text(
                                  '${payment.serviceType ?? 'N/A'} - ${payment.period ?? 'N/A'}',
                                ),
                                subtitle:
                                    Text(_formatDate(payment.paymentDate)),
                                trailing: Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.green,
                                      ),
                                ),
                              ),
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
    );
  }
}
