import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../data_sources/expense_local_data_source.dart';

class LocalExpenseRepository implements ExpenseRepository {
  const LocalExpenseRepository(this._dataSource);

  final ExpenseLocalDataSource _dataSource;

  @override
  Future<void> addExpense(Expense expense) {
    return _dataSource.saveExpense(expense);
  }

  @override
  Future<List<Expense>> getExpenses() {
    return _dataSource.getExpenses();
  }
}
