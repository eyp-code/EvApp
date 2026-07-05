import '../models/person.dart';

abstract class PersonRepository {
  Future<List<Person>> getPersons();

  Future<List<Person>> getAllPersons();

  Future<Person?> getMe();

  Future<void> addPerson(Person person);

  Future<void> updatePerson(Person person);

  Future<void> deletePerson(String personId);
}
