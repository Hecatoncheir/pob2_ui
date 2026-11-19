import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final profile = Platform.environment['POB2_UI_HOME'];
  if (profile == null) throw StateError('Нужен отдельный профиль проверки');
  final root = Directory(profile);
  await root.create(recursive: true);
  await File.fromUri(root.uri.resolve('launches.jsonl')).writeAsString(
    '${jsonEncode({'executable': Platform.resolvedExecutable, 'arguments': arguments})}\n',
    mode: FileMode.append,
    flush: true,
  );
  final index = arguments.indexOf('--pob-update-token');
  if (index < 0) return;
  final health = File.fromUri(
    root.uri.resolve('updates/health-${arguments[index + 1]}.ready'),
  );
  await health.parent.create(recursive: true);
  await health.writeAsString('ready', flush: true);
}
