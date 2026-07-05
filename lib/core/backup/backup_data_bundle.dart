import '../../features/bills/domain/models/bill_type.dart';
import '../../features/bills/domain/models/monthly_bill.dart';
import '../../features/expenses/domain/models/expense.dart';
import '../../features/people/domain/models/person.dart';

class BackupDataBundle {
  const BackupDataBundle({
    required this.persons,
    required this.expenses,
    required this.billTypes,
    required this.monthlyBills,
  });

  final List<Person> persons;
  final List<Expense> expenses;
  final List<BillType> billTypes;
  final List<MonthlyBill> monthlyBills;
}
