import 'package:hive/hive.dart';

import '../../domain/models/expense.dart';

class ExpenseLocalDataSource {
  const ExpenseLocalDataSource(this._box);

  final Box<Map> _box;

  Future<List<Expense>> getExpenses() async {
    final expenses = _box.values
        .map((value) => Expense.fromJson(Map<String, dynamic>.from(value)))
        .where((expense) => !expense.isDeleted)
        .toList();

    expenses.sort((first, second) => second.spentAt.compareTo(first.spentAt));

    return expenses;
  }

  Future<Expense?> getExpenseById(String id) async {
    final value = _box.get(id);

    if (value == null) {
      return null;
    }

    return Expense.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> saveExpense(Expense expense) async {
    await _box.put(expense.id, expense.toJson());
  }
}
