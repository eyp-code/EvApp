import '../models/bill_type.dart';
import '../models/monthly_bill.dart';

abstract class BillRepository {
  Future<List<BillType>> getBillTypes();

  Future<void> addBillType(BillType billType);

  Future<void> deleteBillType(String billTypeId);

  Future<List<MonthlyBill>> getMonthlyBills();

  Future<void> addMonthlyBill(MonthlyBill monthlyBill);

  Future<void> deleteMonthlyBill(String monthlyBillId);

  Future<void> ensureMonthlyBillsForMonth({
    required int year,
    required int month,
  });

  Future<void> markMonthlyBillPaid({
    required String monthlyBillId,
    String? generatedExpenseId,
  });
}
