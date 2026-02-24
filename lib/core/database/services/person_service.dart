import 'package:isar/isar.dart';
import '../models/auxiliary_models.dart';
import '../repositories/finance_repositories.dart';

class PersonService {
  final Isar isar;
  final PersonRepository personRepository;
  
  PersonService({required this.isar, required this.personRepository});

  Future<void> addPerson({
    required String name,
    required String color,
    String? contact,
    String? avatar,
  }) async {
    final person = Person()
      ..name = name
      ..color = color
      ..contact = contact
      ..avatar = avatar
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
      
    await personRepository.save(person);
  }

  Future<void> updatePerson(Person person, Person updatedPerson) async {
    updatedPerson.id = person.id;
    updatedPerson.updatedAt = DateTime.now();
    await personRepository.save(updatedPerson);
  }

  Future<void> deletePerson(Id id) async {
    await personRepository.delete(id);
  }
}
