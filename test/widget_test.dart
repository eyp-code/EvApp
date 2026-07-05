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

    expect(find.text('Bana yazılan toplam'), findsOneWidget);
    expect(find.text('Ortak masraflar'), findsOneWidget);
    expect(find.text('Benim ortak payım'), findsOneWidget);
    expect(find.text('Sadece benim masraflarım'), findsOneWidget);
    expect(find.text('Bu ay girilen toplam'), findsOneWidget);
    expect(find.text('800.00 TL'), findsOneWidget);
    expect(find.text('1200.00 TL'), findsOneWidget);
    expect(find.text('600.00 TL'), findsOneWidget);
    expect(find.text('200.00 TL'), findsOneWidget);
    expect(find.text('1400.00 TL'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Fatura türü ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Su');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Fatura türleri'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Aylık fatura ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '450');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Su'), findsWidgets);
    expect(find.text('450.00 TL'), findsOneWidget);
    expect(find.text('Ödenmeye Hazır'), findsOneWidget);

    final paidButton = find.widgetWithText(TextButton, 'Ödendi işaretle');
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    expect(find.text('Ödendi'), findsOneWidget);
    expect(find.text('Ödendi işaretle'), findsNothing);

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, hasLength(1));
    expect(expenses.single.title, 'Su');
    expect(expenses.single.totalAmount, 450);
    final me = await personRepository.getMe();
    expect(expenses.single.shareFor(me!.id), 225);
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
    expect(find.text('Ödendi işaretle'), findsNothing);
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
    expect(find.text('Ödenmeye Hazır'), findsOneWidget);

    final autoPaidButton = find.ancestor(
      of: find.text('Ödendi işaretle'),
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(autoPaidButton);
    await tester.tap(autoPaidButton);
    await tester.pumpAndSettle();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, hasLength(1));
    expect(expenses.single.title, 'Elektrik');
    expect(expenses.single.totalAmount, 785);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Bana yazılan toplam'), findsOneWidget);
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
      of: find.text('Ödendi işaretle'),
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses, hasLength(1));
    expect(expenses.single.totalAmount, 800);
    expect(expenses.single.shares, hasLength(2));

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Bana yazılan toplam'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Fatura türünü sil'));
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

    await tester.tap(find.byTooltip('Fatura türünü sil'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsOneWidget);
    expect(find.text('600.00 TL'), findsOneWidget);
    expect(find.text('Ödendi'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Aylık faturayı sil'));
    await tester.pumpAndSettle();

    expect(find.text('300.00 TL'), findsNothing);
  });

  testWidgets('Deleting a recurring monthly bill does not recreate it', (
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

    await tester.tap(find.byTooltip('Aylık faturayı sil'));
    await tester.pumpAndSettle();

    expect(find.text('Elektrik'), findsOneWidget);
    expect(find.text('Tutar Bekleniyor'), findsNothing);
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

    await tester.tap(find.byTooltip('Aylık faturayı sil'));
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

    await tester.tap(find.byTooltip('Fatura türü ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fatura adı'),
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
      of: find.text('Ödendi işaretle').first,
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(electricityPaidButton);
    await tester.tap(electricityPaidButton);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    final electricityExpense = expenses.firstWhere(
      (expense) => expense.title == 'Elektrik',
    );
    expect(electricityExpense.totalAmount, 800);
    expect(electricityExpense.shareFor(me.id), 400);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('1100.00 TL'), findsOneWidget);
    expect(find.text('2000.00 TL'), findsOneWidget);

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Fatura türü ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fatura adı'),
      'Netflix',
    );
    await tester.tap(find.text('Kişisel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sabit tutar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '150');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final netflixPaidButton = find.ancestor(
      of: find.text('Ödendi işaretle').last,
      matching: find.byType(TextButton),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(netflixPaidButton);
    await tester.tap(netflixPaidButton);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    final netflixExpense = expenses.firstWhere(
      (expense) => expense.title == 'Netflix',
    );
    expect(netflixExpense.totalAmount, 150);
    expect(netflixExpense.shareFor(me.id), 150);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('1250.00 TL'), findsOneWidget);
    expect(find.text('2150.00 TL'), findsOneWidget);

    await tester.tap(find.text('Fatura'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aylık faturayı sil').first);
    await tester.pumpAndSettle();

    expenses = await expenseRepository.getExpenses();
    expect(expenses.where((expense) => expense.title == 'Elektrik'), isEmpty);
    expect(
      expenses
          .firstWhere((expense) => expense.title == 'Netflix')
          .shareFor(me.id),
      150,
    );

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

    await tester.tap(find.byTooltip('Ürün ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ürün adı'), 'Süt');
    await tester.enterText(
      find.widgetWithText(TextField, 'Tahmini fiyat'),
      '85',
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Süt'), findsOneWidget);
    expect(find.text('Market • 85.00 TL'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Ürünü sil'));
    await tester.pumpAndSettle();

    expect(find.text('Peçete'), findsNothing);
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
    _monthlyBills.add(monthlyBill);
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
  Future<List<BillType>> getBillTypes() async {
    return _billTypes.where((billType) => !billType.isDeleted).toList();
  }

  @override
  Future<List<BillType>> getAllBillTypes() async {
    return List<BillType>.from(_billTypes);
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBills() async {
    return _monthlyBills
        .where((monthlyBill) => !monthlyBill.isDeleted)
        .toList();
  }

  @override
  Future<List<MonthlyBill>> getAllMonthlyBills() async {
    return List<MonthlyBill>.from(_monthlyBills);
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
