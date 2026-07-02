import 'package:flutter/material.dart';

import '../../../../bootstrap.dart';
import '../../bills/presentation/pages/bills_page.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../expenses/presentation/pages/expenses_page.dart';
import '../../settings/presentation/pages/settings_page.dart';
import '../../shopping/presentation/pages/shopping_page.dart';
import '../../tasks/presentation/pages/tasks_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(personRepository: widget.dependencies.personRepository),
      const ExpensesPage(),
      const BillsPage(),
      const ShoppingPage(),
      const TasksPage(),
      SettingsPage(personRepository: widget.dependencies.personRepository),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Özet',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Masraf',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Fatura',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Liste',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Görev',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayar',
          ),
        ],
      ),
    );
  }
}
