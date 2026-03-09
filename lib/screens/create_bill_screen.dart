import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/create_bill/create_bill_bloc.dart';
import '../blocs/create_bill/create_bill_event.dart';
import '../blocs/create_bill/create_bill_state.dart';
import '../repositories/bill_repository.dart';

class CreateBillScreen extends StatelessWidget {
  const CreateBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateBillBloc(
        billRepository: context.read<BillRepository>(),
      ),
      child: const _CreateBillView(),
    );
  }
}

class _CreateBillView extends StatefulWidget {
  const _CreateBillView();

  @override
  State<_CreateBillView> createState() => _CreateBillViewState();
}

class _CreateBillViewState extends State<_CreateBillView> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _periodController = TextEditingController();
  final _amountController = TextEditingController();
  String _serviceType = 'Water';

  static const _serviceTypes = ['Water', 'Electricity', 'Sewer'];

  @override
  void dispose() {
    _clientIdController.dispose();
    _periodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CreateBillBloc>().add(CreateBillSubmitted(
          clientId: int.parse(_clientIdController.text.trim()),
          serviceType: _serviceType,
          period: _periodController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
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
        title: const Text('Create Bill'),
      ),
      body: BlocConsumer<CreateBillBloc, CreateBillState>(
        listener: (context, state) {
          if (state is CreateBillSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bill #${state.bill.id} created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _formKey.currentState!.reset();
            _clientIdController.clear();
            _periodController.clear();
            _amountController.clear();
            setState(() => _serviceType = 'Water');
          } else if (state is CreateBillFailure) {
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
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration:
                            const InputDecoration(labelText: 'Amount (\$)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final amount = double.tryParse(v.trim());
                          if (amount == null) return 'Must be a number';
                          if (amount <= 0) return 'Must be greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              state is CreateBillLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: state is CreateBillLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Create Bill',
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
