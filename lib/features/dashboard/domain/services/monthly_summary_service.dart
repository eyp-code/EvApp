import '../../../bills/domain/models/monthly_bill.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../../expenses/domain/models/split_type.dart';
import '../../../people/domain/models/person.dart';
import '../models/monthly_summary.dart';

class MonthlySummaryService {
  const MonthlySummaryService();

  MonthlySummary build({
    required Person me,
    required int year,
    required int month,
    required List<Expense> expenses,
    required List<MonthlyBill> monthlyBills,
  }) {
    final monthExpenses = expenses
        .where((expense) => expense.spentAt.year == year && expense.spentAt.month == month)
        .toList()
      ..sort((a, b) => b.spentAt.compareTo(a.spentAt));
    final monthBills = monthlyBills
        .where((bill) => bill.year == year && bill.month == month)
        .toList()
      ..sort((a, b) => a.billTypeName.compareTo(b.billTypeName));

    final sharedExpensesTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.totalAmount);
    final mySharedShareTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final onlyMeExpensesTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.onlyMe)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final enteredExpensesTotal = monthExpenses.fold<double>(
      0,
      (total, expense) => total + expense.totalAmount,
    );
    final paidBills = monthBills.where((bill) => bill.isPaid).toList();
    final unpaidBills = monthBills
        .where((bill) => !bill.isPaid && !bill.isSkipped)
        .toList();

    return MonthlySummary(
      year: year,
      month: month,
      assignedToMeTotal: mySharedShareTotal + onlyMeExpensesTotal,
      sharedExpensesTotal: sharedExpensesTotal,
      mySharedShareTotal: mySharedShareTotal,
      onlyMeExpensesTotal: onlyMeExpensesTotal,
      enteredExpensesTotal: enteredExpensesTotal,
      paidBillsCount: paidBills.length,
      unpaidBillsCount: unpaidBills.length,
      expenses: monthExpenses,
      paidBills: paidBills,
      unpaidBills: unpaidBills,
    );
  }

  List<DateTime> archivedMonths({
    required DateTime currentMonth,
    required List<Expense> expenses,
    required List<MonthlyBill> monthlyBills,
  }) {
    final months = <DateTime>{};

    for (final expense in expenses) {
      final month = DateTime(expense.spentAt.year, expense.spentAt.month);
      if (month.isBefore(currentMonth)) {
        months.add(month);
      }
    }

    for (final bill in monthlyBills) {
      final month = DateTime(bill.year, bill.month);
      if (month.isBefore(currentMonth)) {
        months.add(month);
      }
    }

    final result = months.toList()..sort((a, b) => b.compareTo(a));
    return result;
  }
}
