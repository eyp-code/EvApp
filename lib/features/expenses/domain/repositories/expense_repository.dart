import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<List<Expense>> getAllExpenses();

  Future<void> addExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);
}
