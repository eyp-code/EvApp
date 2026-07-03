import 'package:hive_flutter/hive_flutter.dart';

import 'core/storage/hive_box_names.dart';
import 'features/expenses/data/data_sources/expense_local_data_source.dart';
import 'features/expenses/data/repositories/local_expense_repository.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/people/data/data_sources/person_local_data_source.dart';
import 'features/people/data/repositories/local_person_repository.dart';
import 'features/people/domain/models/person.dart';
import 'features/people/domain/repositories/person_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.personRepository,
    required this.expenseRepository,
  });

  final PersonRepository personRepository;
  final ExpenseRepository expenseRepository;
}

Future<AppDependencies> bootstrapApp() async {
  await Hive.initFlutter();

  final personsBox = await Hive.openBox<Map>(HiveBoxNames.persons);
  final expensesBox = await Hive.openBox<Map>(HiveBoxNames.expenses);

  final personDataSource = PersonLocalDataSource(personsBox);
  final personRepository = LocalPersonRepository(personDataSource);
  final expenseDataSource = ExpenseLocalDataSource(expensesBox);
  final expenseRepository = LocalExpenseRepository(expenseDataSource);

  await _seedMePerson(personRepository);

  return AppDependencies(
    personRepository: personRepository,
    expenseRepository: expenseRepository,
  );
}

Future<void> _seedMePerson(PersonRepository personRepository) async {
  final existingMe = await personRepository.getMe();

  if (existingMe != null) {
    return;
  }

  await personRepository.addPerson(Person.createMe(name: 'Ben'));
}
