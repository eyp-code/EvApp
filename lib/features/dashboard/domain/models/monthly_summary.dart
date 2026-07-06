import '../../../bills/domain/models/monthly_bill.dart';
import '../../../expenses/domain/models/expense.dart';

class MonthlySummary {
  const MonthlySummary({
    required this.year,
    required this.month,
    required this.assignedToMeTotal,
    required this.sharedExpensesTotal,
    required this.mySharedShareTotal,
    required this.onlyMeExpensesTotal,
    required this.enteredExpensesTotal,
    required this.paidBillsCount,
    required this.unpaidBillsCount,
    required this.expenses,
    required this.paidBills,
    required this.unpaidBills,
  });

  final int year;
  final int month;
  final double assignedToMeTotal;
  final double sharedExpensesTotal;
  final double mySharedShareTotal;
  final double onlyMeExpensesTotal;
  final double enteredExpensesTotal;
  final int paidBillsCount;
  final int unpaidBillsCount;
  final List<Expense> expenses;
  final List<MonthlyBill> paidBills;
  final List<MonthlyBill> unpaidBills;
}
