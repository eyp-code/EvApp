import '../models/person.dart';

abstract class PersonRepository {
  Future<List<Person>> getPersons();

  Future<Person?> getMe();

  Future<void> addPerson(Person person);
}
