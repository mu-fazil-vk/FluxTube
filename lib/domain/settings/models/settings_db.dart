import 'package:isar/isar.dart';

part 'settings_db.g.dart';

//--------SETTINGS MODEL--------//
// `flutter pub run build_runner build` to generate file

@Collection()
class SettingsDBValue {
  Id id = Isar.autoIncrement;

  late String name;

  String? value;
}
