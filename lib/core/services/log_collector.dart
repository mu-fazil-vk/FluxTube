import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;

class LogCollector {
  static final LogCollector _instance = LogCollector._();
  factory LogCollector() => _instance;
  LogCollector._();

  final ListQueue<LogEntry> _entries = ListQueue();
  final _controller = StreamController<String>.broadcast();
  static const _maxEntries = 500;

  Stream<String> get stream => _controller.stream;
  List<LogEntry> get entries => List.unmodifiable(_entries);
  int get entryCount => _entries.length;

  void log(String message, {String tag = 'APP'}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      tag: tag,
    );
    _entries.add(entry);
    if (_entries.length > _maxEntries) _entries.removeFirst();
    if (_controller.hasListener) _controller.add(entry.formatted);
    dev.log(message, name: tag);
  }

  void clear() {
    _entries.clear();
    _controller.add('');
  }

  String get fullLog => _entries.map((e) => e.formatted).join('\n');
}

class LogEntry {
  final DateTime timestamp;
  final String message;
  final String tag;

  LogEntry({
    required this.timestamp,
    required this.message,
    this.tag = 'APP',
  });

  String get formatted {
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    return '[$time] [$tag] $message';
  }
}
