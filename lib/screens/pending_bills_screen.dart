import 'package:flutter/material.dart';

class PendingBillsScreen extends StatelessWidget {
  const PendingBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Bills')),
      body: const Center(child: Text('Pending Bills - Coming soon')),
    );
  }
}
