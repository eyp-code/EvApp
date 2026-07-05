import 'package:hive/hive.dart';

import '../../domain/models/person.dart';

class PersonLocalDataSource {
  const PersonLocalDataSource(this._box);

  final Box<Map> _box;

  Future<List<Person>> getPersons() async {
    return _box.values
        .map((value) => Person.fromJson(Map<String, dynamic>.from(value)))
        .where((person) => !person.isDeleted)
        .toList();
  }

  Future<List<Person>> getAllPersons() async {
    return _box.values
        .map((value) => Person.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<Person?> getPersonById(String id) async {
    final value = _box.get(id);

    if (value == null) {
      return null;
    }

    return Person.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> savePerson(Person person) async {
    await _box.put(person.id, person.toJson());
  }

  Future<void> replaceAll(List<Person> persons) async {
    await _box.clear();

    for (final person in persons) {
      await _box.put(person.id, person.toJson());
    }
  }
}
