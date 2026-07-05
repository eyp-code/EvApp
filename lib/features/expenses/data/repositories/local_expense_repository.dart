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
  Future<List<Expense>> getAllExpenses() {
    return _dataSource.getAllExpenses();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    final expense = await _dataSource.getExpenseById(expenseId);

    if (expense == null) {
      return;
    }

    await _dataSource.saveExpense(expense.markedDeleted());
  }

  @override
  Future<List<Expense>> getExpenses() {
    return _dataSource.getExpenses();
  }

  Future<void> replaceAll(List<Expense> expenses) {
    return _dataSource.replaceAll(expenses);
  }
}
