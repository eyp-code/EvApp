import 'package:hive_flutter/hive_flutter.dart';

import 'core/storage/hive_box_names.dart';
import 'features/people/data/data_sources/person_local_data_source.dart';
import 'features/people/data/repositories/local_person_repository.dart';
import 'features/people/domain/models/person.dart';
import 'features/people/domain/repositories/person_repository.dart';

class AppDependencies {
  const AppDependencies({required this.personRepository});

  final PersonRepository personRepository;
}

Future<AppDependencies> bootstrapApp() async {
  await Hive.initFlutter();

  final personsBox = await Hive.openBox<Map>(HiveBoxNames.persons);
  final personDataSource = PersonLocalDataSource(personsBox);
  final personRepository = LocalPersonRepository(personDataSource);

  await _seedMePerson(personRepository);

  return AppDependencies(personRepository: personRepository);
}

Future<void> _seedMePerson(PersonRepository personRepository) async {
  final existingMe = await personRepository.getMe();

  if (existingMe != null) {
    return;
  }

  await personRepository.addPerson(Person.createMe(name: 'Ben'));
}
