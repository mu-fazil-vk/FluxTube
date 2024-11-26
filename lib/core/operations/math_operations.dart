import 'package:intl/intl.dart';

/// FNV-1a 64bit hash algorithm optimized for Dart Strings FROM ISAR DOC
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

// format likes & subs from 10000 => 10k
String formatCount(String count) {
  int? intCount = int.tryParse(count);
  if (intCount == null) {
    return count;
  } else {
    return intCount > 1000
        ? NumberFormat.compact().format(intCount).toString()
        : intCount.toString();
  }
}

// format time, from int to 00:12:10
String formatDuration(int? totalSeconds) {
  if (totalSeconds == null) {
    return "00:00";
  } else if (totalSeconds == -1) {
    return "Live";
  }
  // Calculate hours, minutes, and seconds
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  // Create formatted strings
  String formattedHours =
      hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
  String formattedMinutes = '${minutes.toString().padLeft(2, '0')}:';
  String formattedSeconds = seconds.toString().padLeft(2, '0');

  // Concatenate the parts
  return formattedHours + formattedMinutes + formattedSeconds;
}
