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
  Future<List<Person>> getAllPersons() {
    return _dataSource.getAllPersons();
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

  @override
  Future<void> updatePerson(Person person) {
    return _dataSource.savePerson(person);
  }

  @override
  Future<void> deletePerson(String personId) async {
    final person = await _dataSource.getPersonById(personId);

    if (person == null || person.isMe) {
      return;
    }

    await _dataSource.savePerson(person.markedDeleted());
  }

  Future<void> replaceAll(List<Person> persons) {
    return _dataSource.replaceAll(persons);
  }
}
