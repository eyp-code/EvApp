import 'package:ev_masraflari_app/app/app.dart';
import 'package:ev_masraflari_app/bootstrap.dart';
import 'package:ev_masraflari_app/features/expenses/domain/models/expense.dart';
import 'package:ev_masraflari_app/features/expenses/domain/models/split_type.dart';
import 'package:ev_masraflari_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:ev_masraflari_app/features/people/domain/models/person.dart';
import 'package:ev_masraflari_app/features/people/domain/repositories/person_repository.dart';
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
}
