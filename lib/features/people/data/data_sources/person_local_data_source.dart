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

  Future<void> savePerson(Person person) async {
    await _box.put(person.id, person.toJson());
  }
}
