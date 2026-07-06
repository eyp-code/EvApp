import 'dart:convert';

import 'package:ev_masraflari_app/app/app.dart';
import 'package:ev_masraflari_app/bootstrap.dart';
import 'package:ev_masraflari_app/core/backup/backup_data_bundle.dart';
import 'package:ev_masraflari_app/core/backup/backup_service.dart';
import 'package:ev_masraflari_app/features/bills/domain/models/bill_type.dart';
import 'package:ev_masraflari_app/features/bills/domain/models/monthly_bill.dart';
import 'package:ev_masraflari_app/features/bills/domain/repositories/bill_repository.dart';
import 'package:ev_masraflari_app/features/expenses/domain/models/expense.dart';
import 'package:ev_masraflari_app/features/expenses/domain/models/split_type.dart';
import 'package:ev_masraflari_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:ev_masraflari_app/features/people/domain/models/person.dart';
import 'package:ev_masraflari_app/features/people/domain/repositories/person_repository.dart';
import 'package:ev_masraflari_app/features/shopping/domain/models/shopping_item.dart';
import 'package:ev_masraflari_app/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:ev_masraflari_app/features/tasks/domain/models/task_item.dart';
import 'package:ev_masraflari_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EvApp opens and navigates between main sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Masraf'), findsOneWidget);
    expect(find.text('Masraflar'), findsNothing);

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    expect(find.text('Masraflar'), findsOneWidget);
  });

  testWidgets('Settings page adds a roommate', (WidgetTester tester) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Evdeki kişiler'), findsOneWidget);
    expect(find.text('Ben'), findsWidgets);

    await tester.tap(find.byTooltip('Ev arkadaşı ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ayşe');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Ayşe'), findsOneWidget);
    expect(find.text('Ev arkadaşı'), findsOneWidget);
  });

  testWidgets('Expenses page adds an only-me expense', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Başlık'), 'Market');
    await tester.enterText(find.widgetWithText(TextField, 'Tutar'), '1200');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsOneWidget);
    expect(find.text('1200.00 TL'), findsOneWidget);
    expect(find.text('Benim payım: 1200.00 TL'), findsOneWidget);
  });

  testWidgets('Expenses page validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Başlık gerekli'), findsOneWidget);
    expect(find.text('Geçerli bir tutar gir'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Expenses page adds an equal shared expense', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository.withRoommate(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Market');
    await tester.enterText(find.byType(TextFormField).at(2), '1200');
    await tester.tap(find.text('Ortak eşit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsOneWidget);
    expect(find.text('1200.00 TL'), findsOneWidget);
    expect(find.text('Benim payım: 600.00 TL'), findsOneWidget);
    expect(find.text('Ortak eşit bölündü'), findsOneWidget);
  });

  testWidgets('Expenses page deletes an expense', (WidgetTester tester) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Başlık'), 'Market');
    await tester.enterText(find.widgetWithText(TextField, 'Tutar'), '1200');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsNothing);
    expect(find.byTooltip('Masraf ekle'), findsWidgets);
  });

  testWidgets('Expenses page saves the selected expense date', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository();

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: expenseRepository,
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Baslik'), 'Market');
    await tester.enterText(find.widgetWithText(TextField, 'Tutar'), '1200');

    await tester.tap(find.text('Tarih'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, hasLength(1));
    expect(expenses.first.spentAt.day, 15);
  });

  testWidgets('Expenses page hides legacy bill-generated expense records', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository();
    await expenseRepository.addExpense(
      Expense.create(
        title: 'Elektrik',
        category: 'Fatura',
        totalAmount: 800,
        spentAt: DateTime.now(),
        paidByPersonId: 'me',
        splitType: SplitType.onlyMe,
        participantIds: ['me'],
      ),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: expenseRepository,
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsNothing);
  });

  testWidgets('Dashboard shows understandable expense summary', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository.withRoommate();
    final persons = await personRepository.getPersons();
    final me = persons.firstWhere((person) => person.isMe);
    final roommate = persons.firstWhere((person) => !person.isMe);
    final expenseRepository = _FakeExpenseRepository();

    await expenseRepository.addExpense(
      Expense.create(
        title: 'Market',
        category: 'Market',
        totalAmount: 1200,
        spentAt: DateTime.now(),
        paidByPersonId: roommate.id,
        splitType: SplitType.equal,
        participantIds: [me.id, roommate.id],
      ),
    );
    await expenseRepository.addExpense(
      Expense.create(
        title: 'Kahve',
        category: 'Kafe',
        totalAmount: 200,
        spentAt: DateTime.now(),
        paidByPersonId: me.id,
        splitType: SplitType.onlyMe,
        participantIds: [me.id],
      ),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bana yazilan toplam'), findsOneWidget);
    expect(find.text('Ortak masraflar'), findsOneWidget);
    expect(find.text('Benim ortak payim'), findsOneWidget);
    expect(find.text('Sadece benim masraflarim'), findsOneWidget);
    expect(find.text('Bu ay girilen toplam'), findsOneWidget);
    expect(find.text('800.00 TL'), findsOneWidget);
    expect(find.text('1200.00 TL'), findsOneWidget);
    expect(find.text('600.00 TL'), findsOneWidget);
    expect(find.text('200.00 TL'), findsOneWidget);
    expect(find.text('1400.00 TL'), findsOneWidget);
  });

  testWidgets('Dashboard shows archived month summary and opens detail page', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository.withRoommate();
    final persons = await personRepository.getPersons();
    final me = persons.firstWhere((person) => person.isMe);
    final roommate = persons.firstWhere((person) => !person.isMe);
    final expenseRepository = _FakeExpenseRepository();
    final billRepository = _FakeBillRepository();
    final previousMonthDate = DateTime.now().month == 1
        ? DateTime(DateTime.now().year - 1, 12, 10)
        : DateTime(DateTime.now().year, DateTime.now().month - 1, 10);

    await expenseRepository.addExpense(
      Expense.create(
        title: 'Gecen Ay Market',
        category: 'Market',
        totalAmount: 1000,
        spentAt: previousMonthDate,
        paidByPersonId: roommate.id,
        splitType: SplitType.equal,
        participantIds: [me.id, roommate.id],
      ),
    );
    await expenseRepository.addExpense(
      Expense.create(
        title: 'Gecen Ay Kahve',
        category: 'Kafe',
        totalAmount: 150,
        spentAt: previousMonthDate,
        paidByPersonId: me.id,
        splitType: SplitType.onlyMe,
        participantIds: [me.id],
      ),
    );
    await billRepository.addMonthlyBill(
      MonthlyBill.create(
        billTypeId: 'su',
        billTypeName: 'Su',
        year: previousMonthDate.year,
        month: previousMonthDate.month,
        amount: 400,
      ).markedPaid(),
    );
    await billRepository.addMonthlyBill(
      MonthlyBill.create(
        billTypeId: 'internet',
        billTypeName: 'Internet',
        year: previousMonthDate.year,
        month: previousMonthDate.month,
        amount: 300,
      ),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biten aylar'), findsOneWidget);
    expect(find.textContaining('Bana yazilan toplam: 650.00 TL'), findsOneWidget);
    expect(find.textContaining('1 odenen, 1 odenmeyen'), findsOneWidget);

    await tester.tap(find.textContaining('Bana yazilan toplam: 650.00 TL'));
    await tester.pumpAndSettle();

    expect(find.text('Odenen faturalar'), findsWidgets);
    expect(find.text('Odenmeyen faturalar'), findsOneWidget);
    expect(find.text('Masraflar ozeti'), findsOneWidget);
    expect(find.text('Gecen Ay Market'), findsOneWidget);
    expect(find.text('Gecen Ay Kahve'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
  });

  testWidgets('Dashboard bill counts ignore unpaid bills of deleted bill types', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();

    await billRepository.addBillType(BillType.create(name: 'Elektrik'));
    await billRepository.addBillType(BillType.create(name: 'Su'));

    final billTypes = await billRepository.getBillTypes();
    final elektrik = billTypes.firstWhere((billType) => billType.name == 'Elektrik');
    final su = billTypes.firstWhere((billType) => billType.name == 'Su');
    final now = DateTime.now();

    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
        billType: elektrik,
        year: now.year,
        month: now.month,
      ).withDetails(amount: 500),
    );
    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
        billType: su,
        year: now.year,
        month: now.month,
      ).withDetails(amount: 300).markedPaid(),
    );

    await billRepository.deleteBillType(elektrik.id);

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Odenen fatura sayisi'), findsOneWidget);
    expect(find.text('Odenmeyen fatura sayisi'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('500.00 TL'), findsNothing);
  });

  test('Equal split assigns half to me when only my profile exists', () {
    final me = Person.createMe(name: 'Ben');
    final expense = Expense.create(
      title: 'Elektrik',
      category: 'Fatura',
      totalAmount: 800,
      spentAt: DateTime(2026, 7),
      paidByPersonId: me.id,
      splitType: SplitType.equal,
      participantIds: [me.id],
    );

    expect(expense.shareFor(me.id), 400);
  });

  testWidgets('Bills page adds a bill type', (WidgetTester tester) async {
    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Fatura turu ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Su');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Fatura turleri'), findsOneWidget);
    expect(find.text('Su'), findsWidgets);
    expect(find.text('Tutar Bekleniyor'), findsOneWidget);
  });

  testWidgets('Bills page adds and marks a monthly bill paid', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository();
    final billRepository = _FakeBillRepository();
    final expenseRepository = _FakeExpenseRepository();
    await billRepository.addBillType(
      BillType.create(name: 'Su', isRecurringMonthly: false),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Aylik fatura ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '450');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Su'), findsWidgets);
    expect(find.text('450.00 TL'), findsOneWidget);
    expect(find.text('Odenmeye Hazir'), findsOneWidget);

    final paidButton = find.widgetWithText(TextButton, 'Odendi isaretle');
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    expect(find.text('Odendi'), findsOneWidget);
    expect(find.text('Odendi isaretle'), findsNothing);

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, isEmpty);
  });

  testWidgets('Bills page auto creates recurring bills waiting for amount', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    await billRepository.addBillType(BillType.create(name: 'Elektrik'));

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsWidgets);
    expect(find.text('Tutar Bekleniyor'), findsOneWidget);
    expect(find.text('Odendi isaretle'), findsNothing);
    expect(find.text('Tutar gir'), findsOneWidget);
  });

  testWidgets('Bills page enters amount before paying an auto bill', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    final expenseRepository = _FakeExpenseRepository();
    await billRepository.addBillType(BillType.create(name: 'Elektrik'));

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutar gir').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '785');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('785.00 TL'), findsOneWidget);
    expect(find.text('Odenmeye Hazir'), findsOneWidget);

    final autoPaidButton = find.ancestor(
      of: find.text('Odendi isaretle'),
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(autoPaidButton);
    await tester.tap(autoPaidButton);
    await tester.pumpAndSettle();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Bana yazilan toplam'), findsOneWidget);
    expect(find.text('392.50 TL'), findsWidgets);
    expect(find.text('785.00 TL'), findsWidgets);
  });

  testWidgets('Shared paid bill updates dashboard like a shared expense', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository.withRoommate();
    final billRepository = _FakeBillRepository();
    final expenseRepository = _FakeExpenseRepository();
    await billRepository.addBillType(BillType.create(name: 'Elektrik'));

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutar gir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '800');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final paidButton = find.ancestor(
      of: find.text('Odendi isaretle'),
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Bana yazilan toplam'), findsOneWidget);
    expect(find.text('400.00 TL'), findsWidgets);
    expect(find.text('800.00 TL'), findsWidgets);
  });

  testWidgets('Bills page deletes a bill type from the list', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    await billRepository.addBillType(
      BillType.create(name: 'Su', isRecurringMonthly: false),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('Su'), findsOneWidget);

    await tester.tap(find.byTooltip('Fatura turunu sil'));
    await tester.pumpAndSettle();

    expect(find.text('Su'), findsNothing);
  });

  testWidgets('Deleting a bill type keeps old paid monthly records visible', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    final expenseRepository = _FakeExpenseRepository();
    final billType = BillType.create(name: 'Elektrik');
    await billRepository.addBillType(billType);
    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
        billType: billType,
        year: DateTime.now().year,
        month: DateTime.now().month - 1,
      ).withDetails(amount: 600).markedPaid(),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Fatura turunu sil'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsOneWidget);
    expect(find.text('600.00 TL'), findsOneWidget);
    expect(find.text('Odendi'), findsOneWidget);
    expect(find.text('Tutar Bekleniyor'), findsNothing);
  });

  testWidgets('Bills page deletes a monthly bill record', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    final billType = BillType.create(name: 'Su', isRecurringMonthly: false);
    await billRepository.addBillType(billType);
    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
        billType: billType,
        year: DateTime.now().year,
        month: DateTime.now().month,
      ).withDetails(amount: 300),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('300.00 TL'), findsOneWidget);

    await tester.tap(find.byTooltip('Aylik faturayi sil'));
    await tester.pumpAndSettle();

    expect(find.text('300.00 TL'), findsNothing);
  });

  testWidgets('Skipping a recurring monthly bill hides it for the month and allows restore', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    await billRepository.addBillType(BillType.create(name: 'Elektrik'));

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsWidgets);

    await tester.tap(find.byTooltip('Bu ayi atla'));
    await tester.pumpAndSettle();

    expect(find.text('Bu ay atlandi'), findsOneWidget);
    expect(find.text('Geri getir'), findsOneWidget);

    await tester.tap(find.text('Geri getir'));
    await tester.pumpAndSettle();

    expect(find.text('Bu ay atlandi'), findsNothing);
    expect(find.text('Tutar Bekleniyor'), findsOneWidget);
  });

  testWidgets('Recurring monthly bill appears once for the same month', (
    WidgetTester tester,
  ) async {
    final billRepository = _FakeBillRepository();
    final now = DateTime.now();
    final billType = BillType.create(name: 'Elektrik');

    await billRepository.addBillType(billType);
    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
        billType: billType,
        year: now.year,
        month: now.month,
      ),
    );
    await billRepository.addMonthlyBill(
      MonthlyBill.create(
        billTypeId: billType.id,
        billTypeName: billType.name,
        year: now.year,
        month: now.month,
        amount: 650,
      ),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsOneWidget);
    expect(find.text('650.00 TL'), findsOneWidget);
  });

  testWidgets('Deleting a paid monthly bill removes its generated expense', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository();
    final me = await personRepository.getMe();
    final billRepository = _FakeBillRepository();
    final expenseRepository = _FakeExpenseRepository();
    final billType = BillType.create(name: 'Elektrik');
    final generatedExpense = Expense.create(
      title: 'Elektrik',
      category: 'Fatura',
      totalAmount: 800,
      spentAt: DateTime.now(),
      paidByPersonId: me!.id,
      splitType: SplitType.equal,
      participantIds: [me.id],
    );

    await billRepository.addBillType(billType);
    await expenseRepository.addExpense(generatedExpense);
    await billRepository.addMonthlyBill(
      MonthlyBill.fromBillType(
            billType: billType,
            year: DateTime.now().year,
            month: DateTime.now().month,
          )
          .withDetails(amount: 800)
          .markedPaid(generatedExpenseId: generatedExpense.id),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    expect(find.text('800.00 TL'), findsOneWidget);

    await tester.tap(find.byTooltip('Aylik faturayi sil'));
    await tester.pumpAndSettle();

    expect(await expenseRepository.getExpenses(), isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('400.00 TL'), findsNothing);
    expect(find.text('800.00 TL'), findsNothing);
    expect(find.text('0.00 TL'), findsWidgets);
  });

  testWidgets('Full expense and bill workflow keeps totals consistent', (
    WidgetTester tester,
  ) async {
    final personRepository = _FakePersonRepository.withRoommate();
    final persons = await personRepository.getPersons();
    final me = persons.firstWhere((person) => person.isMe);
    final expenseRepository = _FakeExpenseRepository();
    final billRepository = _FakeBillRepository();

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: personRepository,
          expenseRepository: expenseRepository,
          billRepository: billRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Market');
    await tester.enterText(find.byType(TextFormField).at(2), '1000');
    await tester.tap(find.text('Ortak eşit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Masraf ekle').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Kahve');
    await tester.enterText(find.byType(TextFormField).at(2), '200');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    var expenses = await expenseRepository.getExpenses();
    expect(expenses, hasLength(2));
    expect(
      expenses
          .firstWhere((expense) => expense.title == 'Market')
          .shareFor(me.id),
      500,
    );
    expect(
      expenses
          .firstWhere((expense) => expense.title == 'Kahve')
          .shareFor(me.id),
      200,
    );

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('700.00 TL'), findsOneWidget);
    expect(find.text('1200.00 TL'), findsOneWidget);

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Fatura turu ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fatura adi'),
      'Elektrik',
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutar gir').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '800');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final electricityPaidButton = find.ancestor(
      of: find.text('Odendi isaretle').first,
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(electricityPaidButton);
    await tester.tap(electricityPaidButton);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    expect(expenses.where((expense) => expense.title == 'Elektrik'), isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('1100.00 TL'), findsOneWidget);
    expect(find.text('2000.00 TL'), findsOneWidget);

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Fatura turu ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fatura adi'),
      'Netflix',
    );
    await tester.tap(find.text('Kisisel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sabit tutar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '150');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final netflixPaidButton = find.ancestor(
      of: find.text('Odendi isaretle').last,
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(netflixPaidButton);
    await tester.tap(netflixPaidButton);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    expect(expenses.where((expense) => expense.title == 'Netflix'), isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('1250.00 TL'), findsOneWidget);
    expect(find.text('2150.00 TL'), findsOneWidget);

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aylik faturayi sil').first);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    expect(expenses.where((expense) => expense.title == 'Elektrik'), isEmpty);
    expect(expenses.where((expense) => expense.title == 'Netflix'), isEmpty);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('850.00 TL'), findsOneWidget);
    expect(find.text('1350.00 TL'), findsOneWidget);
  });
  test('BackupService exports expected sections and restores records', () async {
    final store = _FakeBackupStore(
      persons: [Person.createMe(name: 'Ben'), Person.createRoommate(name: 'Ayse')],
      expenses: [
        Expense.create(
          title: 'Market',
          category: 'Market',
          totalAmount: 500,
          spentAt: DateTime(2026, 7, 1),
          paidByPersonId: 'p1',
          splitType: SplitType.onlyMe,
          participantIds: ['p1'],
        ),
      ],
      billTypes: [BillType.create(name: 'Su')],
      monthlyBills: [
        MonthlyBill.create(
          billTypeId: 'bill-1',
          billTypeName: 'Su',
          year: 2026,
          month: 7,
          amount: 250,
        ),
      ],
    );
    final service = BackupService(store);

    final exported = await service.exportBackupJson();
    final exportedMap = jsonDecode(exported) as Map<String, dynamic>;

    expect(exportedMap['appName'], 'EvApp');
    expect(exportedMap['backupVersion'], 1);
    expect(exportedMap['persons'], hasLength(2));
    expect(exportedMap['expenses'], hasLength(1));
    expect(exportedMap['billTypes'], hasLength(1));
    expect(exportedMap['monthlyBills'], hasLength(1));

    final emptyStore = _FakeBackupStore();
    await BackupService(emptyStore).importBackupJson(exported);

    expect(await emptyStore.getAllPersons(), hasLength(2));
    expect(await emptyStore.getAllExpenses(), hasLength(1));
    expect(await emptyStore.getAllBillTypes(), hasLength(1));
    expect(await emptyStore.getAllMonthlyBills(), hasLength(1));
  });

  test('BackupService rejects invalid backupVersion', () async {
    final service = BackupService(_FakeBackupStore());

    await expectLater(
      () => service.importBackupJson(
        jsonEncode({
          'appName': 'EvApp',
          'backupVersion': 999,
          'createdAt': DateTime.now().toIso8601String(),
          'persons': [],
          'expenses': [],
          'billTypes': [],
          'monthlyBills': [],
        }),
      ),
      throwsFormatException,
    );
  });

  test('BackupService import uses replace-all strategy', () async {
    final service = BackupService(_FakeBackupStore());
    final existingStore = _FakeBackupStore(
      persons: [Person.createMe(name: 'Eski Ben')],
      expenses: [
        Expense.create(
          title: 'Eski Masraf',
          category: 'Test',
          totalAmount: 999,
          spentAt: DateTime(2026, 1, 1),
          paidByPersonId: 'old-person',
          splitType: SplitType.onlyMe,
          participantIds: ['old-person'],
        ),
      ],
      billTypes: [BillType.create(name: 'Eski Fatura')],
      monthlyBills: [
        MonthlyBill.create(
          billTypeId: 'old-bill',
          billTypeName: 'Eski Fatura',
          year: 2026,
          month: 1,
          amount: 999,
        ),
      ],
    );

    final exported = await service.exportBackupJson();
    await BackupService(existingStore).importBackupJson(exported);

    expect(
      (await existingStore.getAllPersons()).map((person) => person.name),
      isNot(contains('Eski Ben')),
    );
    expect(
      (await existingStore.getAllExpenses()).map((expense) => expense.title),
      isEmpty,
    );
    expect(
      (await existingStore.getAllBillTypes()).map((billType) => billType.name),
      isEmpty,
    );
    expect(await existingStore.getAllMonthlyBills(), isEmpty);
  });

  test('BackupService preserves soft-deleted records in export/import', () async {
    final deletedPerson = Person.createRoommate(name: 'Silinen').markedDeleted();
    final deletedExpense = Expense.create(
      title: 'Silinen Masraf',
      category: 'Test',
      totalAmount: 100,
      spentAt: DateTime(2026, 7, 2),
      paidByPersonId: 'deleted-person',
      splitType: SplitType.onlyMe,
      participantIds: ['deleted-person'],
    ).markedDeleted();
    final deletedBillType = BillType.create(name: 'Silinen Fatura')
        .markedDeleted();
    final deletedMonthlyBill = MonthlyBill.create(
      billTypeId: deletedBillType.id,
      billTypeName: deletedBillType.name,
      year: 2026,
      month: 7,
      amount: 300,
    ).markedDeleted();

    final store = _FakeBackupStore(
      persons: [Person.createMe(name: 'Ben'), deletedPerson],
      expenses: [deletedExpense],
      billTypes: [deletedBillType],
      monthlyBills: [deletedMonthlyBill],
    );

    final exported = await BackupService(store).exportBackupJson();
    final importedStore = _FakeBackupStore();
    await BackupService(importedStore).importBackupJson(exported);

    expect(
      (await importedStore.getAllPersons()).where((person) => person.isDeleted),
      hasLength(1),
    );
    expect(
      (await importedStore.getAllExpenses())
          .where((expense) => expense.isDeleted),
      hasLength(1),
    );
    expect(
      (await importedStore.getAllBillTypes())
          .where((billType) => billType.isDeleted),
      hasLength(1),
    );
    expect(
      (await importedStore.getAllMonthlyBills())
          .where((monthlyBill) => monthlyBill.isDeleted),
      hasLength(1),
    );
  });

  test('BackupService rejects invalid appName', () async {
    final service = BackupService(_FakeBackupStore());

    await expectLater(
      () => service.importBackupJson(
        jsonEncode({
          'appName': 'WrongApp',
          'backupVersion': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'persons': [],
          'expenses': [],
          'billTypes': [],
          'monthlyBills': [],
        }),
      ),
      throwsFormatException,
    );
  });

  testWidgets('Shopping page adds an item', (WidgetTester tester) async {
    final shoppingRepository = _FakeShoppingRepository();

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          shoppingRepository: shoppingRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Urun ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Urun adi'), 'Sut');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Sut'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);
  });

  testWidgets('Shopping page toggles purchased state', (
    WidgetTester tester,
  ) async {
    final shoppingRepository = _FakeShoppingRepository();
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Deterjan', category: 'Temizlik'),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          shoppingRepository: shoppingRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect((await shoppingRepository.getShoppingItems()).single.isPurchased, isTrue);
  });

  testWidgets('Shopping page deletes an item', (WidgetTester tester) async {
    final shoppingRepository = _FakeShoppingRepository();
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Peçete', category: 'Market'),
    );

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          shoppingRepository: shoppingRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Urunu sil'));
    await tester.pumpAndSettle();

    expect(find.text('Peçete'), findsNothing);
  });

  testWidgets('Shopping page shows summary metrics', (
    WidgetTester tester,
  ) async {
    final shoppingRepository = _FakeShoppingRepository();
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Sut', category: 'Market'),
    );
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Deterjan', category: 'Temizlik'),
    );
    final secondItem = (await shoppingRepository.getShoppingItems()).last;
    await shoppingRepository.togglePurchased(secondItem.id);

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          shoppingRepository: shoppingRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    expect(find.text('Toplam urun'), findsOneWidget);
    expect(find.text('Alinacak'), findsWidgets);
    expect(find.text('Alindi'), findsWidgets);
    expect(find.text('Durum'), findsOneWidget);
    expect(find.text('Bekliyor'), findsOneWidget);
  });

  testWidgets('Shopping page filters purchased and pending items', (
    WidgetTester tester,
  ) async {
    final shoppingRepository = _FakeShoppingRepository();
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Sut', category: 'Market'),
    );
    await shoppingRepository.addShoppingItem(
      ShoppingItem.create(name: 'Cop Torbasi', category: 'Temizlik'),
    );
    final secondItem = (await shoppingRepository.getShoppingItems()).last;
    await shoppingRepository.togglePurchased(secondItem.id);

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          shoppingRepository: shoppingRepository,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alinacak').last);
    await tester.pumpAndSettle();

    expect(find.text('Sut'), findsOneWidget);
    expect(find.text('Cop Torbasi'), findsNothing);

    await tester.tap(find.text('Alindi').last);
    await tester.pumpAndSettle();

    expect(find.text('Sut'), findsNothing);
    expect(find.text('Cop Torbasi'), findsOneWidget);
  });

  testWidgets('Tasks page adds and completes a task', (
    WidgetTester tester,
  ) async {
    final taskRepository = _FakeTaskRepository();

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository.withRoommate(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          taskRepository: taskRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gorev'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Normal gorev ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Baslik'), 'Cop cikar');
    await tester.enterText(
      find.widgetWithText(TextField, 'Aciklama'),
      'Aksam 20:00 once',
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Cop cikar'), findsOneWidget);
    expect(find.text('Aksam 20:00 once'), findsOneWidget);
    expect(find.text('Bekliyor'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Tamamlandi'), findsOneWidget);
    final tasks = await taskRepository.getTasks();
    expect(tasks.single.isCompleted, isTrue);
  });

  testWidgets('Tasks page advances a recurring task instead of duplicating it', (
    WidgetTester tester,
  ) async {
    final taskRepository = _FakeTaskRepository();

    await tester.pumpWidget(
      EvApp(
        dependencies: AppDependencies(
          personRepository: _FakePersonRepository(),
          expenseRepository: _FakeExpenseRepository(),
          billRepository: _FakeBillRepository(),
          taskRepository: taskRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gorev'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rutin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rutin gorev ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Baslik'),
      'Nevresim degistir',
    );
    await tester.tap(find.text('Ilk bildirim gunu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Tekrar miktari'),
      '2',
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    final tasks = await taskRepository.getTasks();
    expect(tasks, hasLength(1));
    expect(tasks.single.isCompleted, isFalse);
    expect(tasks.single.lastCompletedAt, isNotNull);
    expect(tasks.single.dueDate, isNotNull);
    expect(find.textContaining('Tekrar: her 2 hafta'), findsWidgets);
    expect(find.textContaining('Son yapilma:'), findsOneWidget);
    expect(find.textContaining('Siradaki bildirim:'), findsOneWidget);
  });
}

class _FakePersonRepository implements PersonRepository {
  _FakePersonRepository() : _persons = [Person.createMe(name: 'Ben')];

  _FakePersonRepository.withRoommate()
    : _persons = [
        Person.createMe(name: 'Ben'),
        Person.createRoommate(name: 'Ayşe'),
      ];

  final List<Person> _persons;

  @override
  Future<void> addPerson(Person person) async {
    _persons.add(person);
  }

  @override
  Future<void> deletePerson(String personId) async {
    final index = _persons.indexWhere((person) => person.id == personId);

    if (index == -1 || _persons[index].isMe) {
      return;
    }

    _persons[index] = _persons[index].markedDeleted();
  }

  @override
  Future<Person?> getMe() async {
    return _persons.where((person) => person.isMe && !person.isDeleted).first;
  }

  @override
  Future<List<Person>> getAllPersons() async {
    return List<Person>.from(_persons);
  }

  @override
  Future<List<Person>> getPersons() async {
    return _persons.where((person) => !person.isDeleted).toList();
  }

  @override
  Future<void> updatePerson(Person person) async {
    final index = _persons.indexWhere((item) => item.id == person.id);

    if (index == -1) {
      return;
    }

    _persons[index] = person;
  }
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    final index = _expenses.indexWhere((expense) => expense.id == expenseId);

    if (index == -1) {
      return;
    }

    _expenses[index] = _expenses[index].markedDeleted();
  }

  @override
  Future<List<Expense>> getExpenses() async {
    return _expenses.where((expense) => !expense.isDeleted).toList();
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    return List<Expense>.from(_expenses);
  }
}

class _FakeBillRepository implements BillRepository {
  final List<BillType> _billTypes = [];
  final List<MonthlyBill> _monthlyBills = [];

  @override
  Future<void> addBillType(BillType billType) async {
    _billTypes.add(billType);
  }

  @override
  Future<void> deleteBillType(String billTypeId) async {
    final index = _billTypes.indexWhere(
      (billType) => billType.id == billTypeId,
    );

    if (index == -1) {
      return;
    }

    _billTypes[index] = _billTypes[index].markedDeleted();
  }

  @override
  Future<void> addMonthlyBill(MonthlyBill monthlyBill) async {
    final existingIndex = _monthlyBills.indexWhere(
      (existingMonthlyBill) =>
          !existingMonthlyBill.isDeleted &&
          existingMonthlyBill.id != monthlyBill.id &&
          existingMonthlyBill.billTypeId == monthlyBill.billTypeId &&
          existingMonthlyBill.year == monthlyBill.year &&
          existingMonthlyBill.month == monthlyBill.month,
    );

    if (existingIndex == -1) {
      _monthlyBills.add(monthlyBill);
      return;
    }

    final existingMonthlyBill = _monthlyBills[existingIndex];
    _monthlyBills[existingIndex] = existingMonthlyBill.copyWith(
      billTypeName: monthlyBill.billTypeName,
      amount: monthlyBill.amount ?? existingMonthlyBill.amount,
      dueDate: monthlyBill.dueDate ?? existingMonthlyBill.dueDate,
      note: monthlyBill.note ?? existingMonthlyBill.note,
      status: monthlyBill.status,
      paidAt: monthlyBill.paidAt ?? existingMonthlyBill.paidAt,
      generatedExpenseId:
          monthlyBill.generatedExpenseId ?? existingMonthlyBill.generatedExpenseId,
      updatedAt: monthlyBill.updatedAt,
      syncStatus: monthlyBill.syncStatus,
    );
  }

  @override
  Future<void> deleteMonthlyBill(String monthlyBillId) async {
    final index = _monthlyBills.indexWhere(
      (monthlyBill) => monthlyBill.id == monthlyBillId,
    );

    if (index == -1) {
      return;
    }

    _monthlyBills[index] = _monthlyBills[index].markedDeleted();
  }

  @override
  Future<void> skipMonthlyBill(String monthlyBillId) async {
    final index = _monthlyBills.indexWhere(
      (monthlyBill) => monthlyBill.id == monthlyBillId,
    );

    if (index == -1) {
      return;
    }

    _monthlyBills[index] = _monthlyBills[index].markedSkipped();
  }

  @override
  Future<void> restoreMonthlyBill(String monthlyBillId) async {
    final index = _monthlyBills.indexWhere(
      (monthlyBill) => monthlyBill.id == monthlyBillId,
    );

    if (index == -1) {
      return;
    }

    _monthlyBills[index] = _monthlyBills[index].restoredFromSkip();
  }

  @override
  Future<List<BillType>> getBillTypes() async {
    return _billTypes.where((billType) => !billType.isDeleted).toList();
  }

  @override
  Future<List<BillType>> getAllBillTypes() async {
    return List<BillType>.from(_billTypes);
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBills() async {
    return _dedupeMonthlyBills(
      _monthlyBills.where((monthlyBill) => !monthlyBill.isDeleted).toList(),
    );
  }

  @override
  Future<List<MonthlyBill>> getAllMonthlyBills() async {
    return _dedupeMonthlyBills(List<MonthlyBill>.from(_monthlyBills));
  }

  @override
  Future<void> ensureMonthlyBillsForMonth({
    required int year,
    required int month,
  }) async {
    for (final billType in _billTypes.where(
      (item) => item.isRecurringMonthly,
    )) {
      final alreadyExists = _monthlyBills.any(
        (monthlyBill) =>
            !monthlyBill.isDeleted &&
            monthlyBill.billTypeId == billType.id &&
            monthlyBill.year == year &&
            monthlyBill.month == month,
      );

      if (alreadyExists) {
        continue;
      }

      _monthlyBills.add(
        MonthlyBill.fromBillType(billType: billType, year: year, month: month),
      );
    }
  }

  @override
  Future<void> markMonthlyBillPaid({
    required String monthlyBillId,
    String? generatedExpenseId,
  }) async {
    final index = _monthlyBills.indexWhere(
      (monthlyBill) => monthlyBill.id == monthlyBillId,
    );

    if (index == -1) {
      return;
    }

    _monthlyBills[index] = _monthlyBills[index].markedPaid(
      generatedExpenseId: generatedExpenseId,
    );
  }

  List<MonthlyBill> _dedupeMonthlyBills(List<MonthlyBill> monthlyBills) {
    final byKey = <String, MonthlyBill>{};

    for (final monthlyBill in monthlyBills) {
      final key =
          '${monthlyBill.billTypeId}-${monthlyBill.year}-${monthlyBill.month}';
      final existingMonthlyBill = byKey[key];

      if (existingMonthlyBill == null ||
          monthlyBill.updatedAt.isAfter(existingMonthlyBill.updatedAt)) {
        byKey[key] = monthlyBill;
      }
    }

    return byKey.values.toList();
  }
}

class _FakeBackupStore implements BackupStore {
  _FakeBackupStore({
    List<Person>? persons,
    List<Expense>? expenses,
    List<BillType>? billTypes,
    List<MonthlyBill>? monthlyBills,
  }) : _persons = persons ?? [],
       _expenses = expenses ?? [],
       _billTypes = billTypes ?? [],
       _monthlyBills = monthlyBills ?? [];

  List<Person> _persons;
  List<Expense> _expenses;
  List<BillType> _billTypes;
  List<MonthlyBill> _monthlyBills;

  @override
  Future<List<BillType>> getAllBillTypes() async => List<BillType>.from(_billTypes);

  @override
  Future<List<Expense>> getAllExpenses() async => List<Expense>.from(_expenses);

  @override
  Future<List<MonthlyBill>> getAllMonthlyBills() async =>
      List<MonthlyBill>.from(_monthlyBills);

  @override
  Future<List<Person>> getAllPersons() async => List<Person>.from(_persons);

  @override
  Future<void> replaceAll(BackupDataBundle bundle) async {
    _persons = List<Person>.from(bundle.persons);
    _expenses = List<Expense>.from(bundle.expenses);
    _billTypes = List<BillType>.from(bundle.billTypes);
    _monthlyBills = List<MonthlyBill>.from(bundle.monthlyBills);
  }
}

class _FakeShoppingRepository implements ShoppingRepository {
  final List<ShoppingItem> _items = [];

  @override
  Future<void> addShoppingItem(ShoppingItem item) async {
    _items.add(item);
  }

  @override
  Future<void> deleteShoppingItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);

    if (index == -1) {
      return;
    }

    _items[index] = _items[index].markedDeleted();
  }

  @override
  Future<List<ShoppingItem>> getShoppingItems() async {
    return _items.where((item) => !item.isDeleted).toList();
  }

  @override
  Future<void> togglePurchased(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);

    if (index == -1) {
      return;
    }

    _items[index] = _items[index].toggledPurchased();
  }
}

class _FakeTaskRepository implements TaskRepository {
  final List<TaskItem> _tasks = [];

  @override
  Future<void> addTask(TaskItem task) async {
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].markedDeleted();
  }

  @override
  Future<List<TaskItem>> getTasks() async {
    return _tasks.where((task) => !task.isDeleted).toList();
  }

  @override
  Future<void> toggleCompleted(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].toggledCompleted();
  }

  @override
  Future<void> updateTask(TaskItem task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      return;
    }

    _tasks[index] = task;
  }
}
