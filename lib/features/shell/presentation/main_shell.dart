import 'package:flutter/material.dart';

import '../../../../bootstrap.dart';
import '../../../../core/backup/backup_data_bundle.dart';
import '../../../../core/backup/backup_service.dart';
import '../../../../core/backup/file_backup_gateway.dart';
import '../../bills/domain/models/bill_type.dart';
import '../../bills/domain/models/monthly_bill.dart';
import '../../bills/presentation/pages/bills_page.dart';
import '../../dashboard/presentation/pages/dashboard_home_page.dart';
import '../../expenses/domain/models/expense.dart';
import '../../expenses/presentation/pages/expenses_page.dart';
import '../../people/domain/models/person.dart';
import '../../settings/presentation/pages/settings_page.dart';
import '../../shopping/domain/models/shopping_item.dart';
import '../../shopping/domain/repositories/shopping_repository.dart';
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
  int _dataRevision = 0;

  void _handleDataImported() {
    setState(() {
      _dataRevision++;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardHomePage(
        key: ValueKey('dashboard-$_dataRevision'),
        personRepository: widget.dependencies.personRepository,
        expenseRepository: widget.dependencies.expenseRepository,
        billRepository: widget.dependencies.billRepository,
      ),
      ExpensesPage(
        key: ValueKey('expenses-$_dataRevision'),
        personRepository: widget.dependencies.personRepository,
        expenseRepository: widget.dependencies.expenseRepository,
      ),
      BillsPage(
        key: ValueKey('bills-$_dataRevision'),
        billRepository: widget.dependencies.billRepository,
        expenseRepository: widget.dependencies.expenseRepository,
        personRepository: widget.dependencies.personRepository,
      ),
      ShoppingPage(
        key: ValueKey('shopping-$_dataRevision'),
        shoppingRepository:
            widget.dependencies.shoppingRepository ??
            _EmptyShoppingRepository(),
      ),
      const TasksPage(key: ValueKey('tasks')),
      SettingsPage(
        key: ValueKey('settings-$_dataRevision'),
        personRepository: widget.dependencies.personRepository,
        backupService:
            widget.dependencies.backupService ??
            BackupService(_EmptyBackupStore()),
        fileBackupGateway:
            widget.dependencies.fileBackupGateway ?? FileBackupGateway(),
        onDataImported: _handleDataImported,
      ),
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
            label: 'Ozet',
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
            label: 'Gorev',
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

class _EmptyBackupStore implements BackupStore {
  @override
  Future<List<BillType>> getAllBillTypes() async => const [];

  @override
  Future<List<Expense>> getAllExpenses() async => const [];

  @override
  Future<List<MonthlyBill>> getAllMonthlyBills() async => const [];

  @override
  Future<List<Person>> getAllPersons() async => const [];

  @override
  Future<void> replaceAll(BackupDataBundle bundle) async {}
}

class _EmptyShoppingRepository implements ShoppingRepository {
  @override
  Future<void> addShoppingItem(ShoppingItem item) async {}

  @override
  Future<void> deleteShoppingItem(String itemId) async {}

  @override
  Future<List<ShoppingItem>> getShoppingItems() async => const [];

  @override
  Future<void> togglePurchased(String itemId) async {}
}
