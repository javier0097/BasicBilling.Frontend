import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'repositories/bill_repository.dart';
import 'repositories/payment_repository.dart';
import 'screens/home_screen.dart';
import 'screens/create_bill_screen.dart';
import 'screens/pay_bill_screen.dart';
import 'screens/pending_bills_screen.dart';
import 'screens/payment_history_screen.dart';

void main() {
  final authService = AuthService();
  final apiService = ApiService(authService: authService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => BillRepository(apiService: apiService)),
        RepositoryProvider(create: (_) => PaymentRepository(apiService: apiService)),
      ],
      child: const BasicBillingApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/create-bill', builder: (context, state) => const CreateBillScreen()),
    GoRoute(path: '/pay-bill', builder: (context, state) => const PayBillScreen()),
    GoRoute(path: '/pending-bills', builder: (context, state) => const PendingBillsScreen()),
    GoRoute(path: '/payment-history', builder: (context, state) => const PaymentHistoryScreen()),
  ],
);

class BasicBillingApp extends StatelessWidget {
  const BasicBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Basic Billing',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
