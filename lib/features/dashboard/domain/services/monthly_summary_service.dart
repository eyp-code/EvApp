import '../../../bills/domain/models/bill_share_type.dart';
import '../../../bills/domain/models/bill_type.dart';
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
    required List<BillType> billTypes,
    required List<Expense> expenses,
    required List<MonthlyBill> monthlyBills,
  }) {
    final monthExpenses = expenses
        .where(
          (expense) =>
              expense.category != 'Fatura' &&
              expense.spentAt.year == year &&
              expense.spentAt.month == month,
        )
        .toList()
      ..sort((a, b) => b.spentAt.compareTo(a.spentAt));
    final monthBills = monthlyBills
        .where((bill) => bill.year == year && bill.month == month)
        .toList()
      ..sort((a, b) => a.billTypeName.compareTo(b.billTypeName));
    final billTypesById = {
      for (final billType in billTypes) billType.id: billType,
    };

    final sharedExpensesTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.totalAmount);
    final mySharedShareTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final onlyMeExpensesTotal = monthExpenses
        .where((expense) => expense.splitType == SplitType.onlyMe)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final paidBills = monthBills.where((bill) => bill.isPaid).toList();
    final unpaidBills = monthBills
        .where((bill) => !bill.isPaid && !bill.isSkipped)
        .toList();
    final paidSharedBillsTotal = paidBills.fold<double>(
      0,
      (total, bill) => total + _sharedBillAmount(bill, billTypesById),
    );
    final myPaidSharedBillsTotal = paidBills.fold<double>(
      0,
      (total, bill) => total + _mySharedBillAmount(bill, billTypesById),
    );
    final paidOnlyMeBillsTotal = paidBills.fold<double>(
      0,
      (total, bill) => total + _onlyMeBillAmount(bill, billTypesById),
    );
    final enteredExpensesTotal =
        monthExpenses.fold<double>(0, (total, expense) => total + expense.totalAmount) +
        paidBills.fold<double>(
          0,
          (total, bill) => total + (bill.amount ?? 0),
        );

    return MonthlySummary(
      year: year,
      month: month,
      assignedToMeTotal:
          mySharedShareTotal + myPaidSharedBillsTotal + onlyMeExpensesTotal + paidOnlyMeBillsTotal,
      sharedExpensesTotal: sharedExpensesTotal + paidSharedBillsTotal,
      mySharedShareTotal: mySharedShareTotal + myPaidSharedBillsTotal,
      onlyMeExpensesTotal: onlyMeExpensesTotal + paidOnlyMeBillsTotal,
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
      if (expense.category == 'Fatura') {
        continue;
      }

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

  double _sharedBillAmount(
    MonthlyBill bill,
    Map<String, BillType> billTypesById,
  ) {
    final billType = billTypesById[bill.billTypeId];
    final amount = bill.amount ?? 0;

    if (billType == null || billType.shareType == BillShareType.equal) {
      return amount;
    }

    return 0;
  }

  double _mySharedBillAmount(
    MonthlyBill bill,
    Map<String, BillType> billTypesById,
  ) {
    final billType = billTypesById[bill.billTypeId];
    final amount = bill.amount ?? 0;

    if (billType == null) {
      return amount / 2;
    }

    if (billType.shareType != BillShareType.equal) {
      return 0;
    }

    return amount * (billType.mySharePercentage / 100);
  }

  double _onlyMeBillAmount(
    MonthlyBill bill,
    Map<String, BillType> billTypesById,
  ) {
    final billType = billTypesById[bill.billTypeId];
    final amount = bill.amount ?? 0;

    if (billType == null) {
      return 0;
    }

    if (billType.shareType != BillShareType.onlyMe) {
      return 0;
    }

    return amount * (billType.mySharePercentage / 100);
  }
}
