import 'package:isar/isar.dart';

part 'settings_db.g.dart';

@Collection()
class SettingsDBValue {
  Id id = Isar.autoIncrement;

  late String name;

  String? value;
}