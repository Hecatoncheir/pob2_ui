import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/process_service.dart';

void main() {
  test('Новый процесс получает текущий прокси и наследует окружение', () async {
    var proxy = 'first';
    final processes = ProcessService(
      environment: () => {'HTTPS_PROXY': 'http://$proxy.example.invalid:8080'},
    );
    final (executable, arguments) = Platform.isWindows
        ? (
            'powershell.exe',
            [
              '-NoProfile',
              '-NonInteractive',
              '-Command',
              r'if (!$env:SystemRoot) { exit 1 }; '
                  r'if ($env:HTTPS_PROXY -match '
                  r'"^http://(first|second)\.example\.invalid:8080$") '
                  r'{ $Matches[1] } else { exit 1 }',
            ],
          )
        : (
            '/bin/sh',
            [
              '-c',
              r'test -n "$HOME" || exit 1; '
                  r'case "$HTTPS_PROXY" in '
                  r'http://first.example.invalid:8080) printf first ;; '
                  r'http://second.example.invalid:8080) printf second ;; '
                  r'*) exit 1 ;; esac',
            ],
          );

    expect(await processes.run(executable, arguments), 'first');
    proxy = 'second';
    expect(await processes.run(executable, arguments), 'second');
  });
}
