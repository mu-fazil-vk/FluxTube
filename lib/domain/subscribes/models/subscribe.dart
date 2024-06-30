// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:isar/isar.dart';

import '../../../core/operations/math_operations.dart';

part 'subscribe.g.dart';

@Collection()
class Subscribe {
  late String id;
  Id get isarId => fastHash(id);
  late String channelName;
  late bool? isVerified;
  Subscribe({
    required this.id,
    required this.channelName,
    this.isVerified,
  });
}
