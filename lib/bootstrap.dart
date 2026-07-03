import 'package:hive_flutter/hive_flutter.dart';

import 'core/storage/hive_box_names.dart';
import 'features/bills/data/data_sources/bill_local_data_source.dart';
import 'features/bills/data/repositories/local_bill_repository.dart';
import 'features/bills/domain/models/bill_category.dart';
import 'features/bills/domain/models/bill_share_type.dart';
import 'features/bills/domain/models/bill_type.dart';
import 'features/bills/domain/repositories/bill_repository.dart';
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
    required this.billRepository,
  });

  final PersonRepository personRepository;
  final ExpenseRepository expenseRepository;
  final BillRepository billRepository;
}

Future<AppDependencies> bootstrapApp() async {
  await Hive.initFlutter();

  final personsBox = await Hive.openBox<Map>(HiveBoxNames.persons);
  final expensesBox = await Hive.openBox<Map>(HiveBoxNames.expenses);
  final billTypesBox = await Hive.openBox<Map>(HiveBoxNames.billTypes);
  final monthlyBillsBox = await Hive.openBox<Map>(HiveBoxNames.monthlyBills);

  final personDataSource = PersonLocalDataSource(personsBox);
  final personRepository = LocalPersonRepository(personDataSource);
  final expenseDataSource = ExpenseLocalDataSource(expensesBox);
  final expenseRepository = LocalExpenseRepository(expenseDataSource);
  final billDataSource = BillLocalDataSource(
    billTypesBox: billTypesBox,
    monthlyBillsBox: monthlyBillsBox,
  );
  final billRepository = LocalBillRepository(billDataSource);

  await _seedMePerson(personRepository);
  await _seedDefaultBillTypes(billRepository);

  return AppDependencies(
    personRepository: personRepository,
    expenseRepository: expenseRepository,
    billRepository: billRepository,
  );
}

Future<void> _seedDefaultBillTypes(BillRepository billRepository) async {
  final existingBillTypes = await billRepository.getBillTypes();

  if (existingBillTypes.isNotEmpty) {
    return;
  }

  final defaultBillTypes = [
    BillType.create(name: 'Elektrik'),
    BillType.create(name: 'Su'),
    BillType.create(name: 'Doğalgaz'),
    BillType.create(name: 'İnternet'),
    BillType.create(name: 'Kira'),
    BillType.create(name: 'Aidat'),
    BillType.create(
      name: 'Telefon',
      category: BillCategory.personal,
      shareType: BillShareType.onlyMe,
      mySharePercentage: 100,
      partnerSharePercentage: 0,
    ),
    BillType.create(
      name: 'Kredi Kartı',
      category: BillCategory.personal,
      shareType: BillShareType.onlyMe,
      mySharePercentage: 100,
      partnerSharePercentage: 0,
    ),
    BillType.create(
      name: 'Sigorta',
      category: BillCategory.personal,
      shareType: BillShareType.onlyMe,
      mySharePercentage: 100,
      partnerSharePercentage: 0,
    ),
    BillType.create(
      name: 'Netflix',
      category: BillCategory.personal,
      shareType: BillShareType.onlyMe,
      mySharePercentage: 100,
      partnerSharePercentage: 0,
    ),
  ];

  for (final billType in defaultBillTypes) {
    await billRepository.addBillType(billType);
  }
}

Future<void> _seedMePerson(PersonRepository personRepository) async {
  final existingMe = await personRepository.getMe();

  if (existingMe != null) {
    return;
  }

  await personRepository.addPerson(Person.createMe(name: 'Ben'));
}
