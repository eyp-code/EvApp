import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<void> addExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);
}
