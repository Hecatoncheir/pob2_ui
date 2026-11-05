// Кандидат для проверки отката: процесс жив, но запуск оболочки не подтверждён.
Future<void> main() async {
  await Future<void>.delayed(const Duration(minutes: 1));
}
