import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/pay_bill/pay_bill_bloc.dart';
import '../blocs/pay_bill/pay_bill_event.dart';
import '../blocs/pay_bill/pay_bill_state.dart';
import '../repositories/payment_repository.dart';

class PayBillScreen extends StatelessWidget {
  const PayBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayBillBloc(
        paymentRepository: context.read<PaymentRepository>(),
      ),
      child: const _PayBillView(),
    );
  }
}

class _PayBillView extends StatefulWidget {
  const _PayBillView();

  @override
  State<_PayBillView> createState() => _PayBillViewState();
}

class _PayBillViewState extends State<_PayBillView> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _periodController = TextEditingController();
  String _serviceType = 'Water';

  static const _serviceTypes = ['Water', 'Electricity', 'Sewer'];

  @override
  void dispose() {
    _clientIdController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<PayBillBloc>().add(PayBillSubmitted(
          clientId: int.parse(_clientIdController.text.trim()),
          serviceType: _serviceType,
          period: _periodController.text.trim(),
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
        title: const Text('Pay Bill'),
      ),
      body: BlocConsumer<PayBillBloc, PayBillState>(
        listener: (context, state) {
          if (state is PayBillSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Payment processed - \$${state.payment.amount.toStringAsFixed(2)}'),
                backgroundColor: Colors.green,
              ),
            );
            _formKey.currentState!.reset();
            _clientIdController.clear();
            _periodController.clear();
            setState(() => _serviceType = 'Water');
          } else if (state is PayBillFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _clientIdController,
                        decoration:
                            const InputDecoration(labelText: 'Client ID'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) {
                            return 'Must be a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _serviceType,
                        decoration:
                            const InputDecoration(labelText: 'Service Type'),
                        items: _serviceTypes
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _serviceType = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _periodController,
                        decoration: const InputDecoration(
                          labelText: 'Period',
                          hintText: 'YYYYMM (e.g. 202603)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final trimmed = v.trim();
                          if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
                            return 'Format: YYYYMM';
                          }
                          final month = int.parse(trimmed.substring(4));
                          if (month < 1 || month > 12) {
                            return 'Invalid month';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state is PayBillLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: state is PayBillLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Process Payment',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
