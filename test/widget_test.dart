import 'package:ev_masraflari_app/app/app.dart';
import 'package:ev_masraflari_app/bootstrap.dart';
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
}

class _FakePersonRepository implements PersonRepository {
  final List<Person> _persons = [Person.createMe(name: 'Ben')];

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
