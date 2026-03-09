import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Billing'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Service Payment System',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _MenuButton(
                  icon: Icons.add_circle_outline,
                  label: 'Create New Bill',
                  onTap: () => context.go('/create-bill'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.payment,
                  label: 'Pay a Bill',
                  onTap: () => context.go('/pay-bill'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.pending_actions,
                  label: 'View Pending Bills',
                  onTap: () => context.go('/pending-bills'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.history,
                  label: 'Payment History',
                  onTap: () => context.go('/payment-history'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
