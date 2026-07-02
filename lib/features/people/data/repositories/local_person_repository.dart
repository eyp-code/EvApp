import '../../domain/models/person.dart';
import '../../domain/repositories/person_repository.dart';
import '../data_sources/person_local_data_source.dart';

class LocalPersonRepository implements PersonRepository {
  const LocalPersonRepository(this._dataSource);

  final PersonLocalDataSource _dataSource;

  @override
  Future<List<Person>> getPersons() {
    return _dataSource.getPersons();
  }

  @override
  Future<Person?> getMe() async {
    final persons = await getPersons();

    for (final person in persons) {
      if (person.isMe) {
        return person;
      }
    }

    return null;
  }

  @override
  Future<void> addPerson(Person person) {
    return _dataSource.savePerson(person);
  }
}
