import 'dart:io';

void main() {
  final dir = Directory('e:/mafioso1/lib');
  final regex = RegExp(r'\.withOpacity\(\s*([^)]+)\s*\)');
  int count = 0;
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains('.withOpacity(')) {
        final newContent = content.replaceAllMapped(regex, (match) {
          final param = match.group(1);
          return '.withValues(alpha: $param)';
        });
        if (newContent != content) {
          entity.writeAsStringSync(newContent);
          count++;
          print('Fixed ${entity.path}');
        }
      }
    }
  }
  print('Fixed $count files');
}
