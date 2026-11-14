import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/github_service.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/setup_wizard.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

const _failure = 'Сеть недоступна';
const _privateOutput = 'https://user:private-token@example.com/';

void main() {
  testWidgets(
    'Мастер показывает этап, копирует причину и повторяет установку',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      String? clipboard;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard =
              (call.arguments as Map<Object?, Object?>)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final profile = Directory('unused-setup-wizard-test');
      final repository = _SetupRepository(InstallationStore(profile));
      final model = WorkshopCubit(
        repository,
        _SetupEngine(),
        library: PobBuildLibrary(profile),
        session: _SetupSession(profile),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: Spark.theme(),
          home: BlocProvider(
            create: (_) => ShellBloc(),
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showSetupWizard(context, model),
                  child: const Text('Открыть мастер'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Открыть мастер'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      await tester.tap(find.text('Установить компоненты'));
      await tester.pump();
      await tester.pump();

      expect(repository.attempts, 1);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Загрузка PoB MCP'), findsOneWidget);
      expect(find.text('Повторить'), findsNothing);

      repository.failDownload.complete();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(find.textContaining(_failure), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.tap(find.text('Скопировать диагностику'));
      await tester.pump();
      expect(clipboard, contains('Загрузка PoB MCP'));
      expect(clipboard, contains(_failure));
      expect(clipboard, contains('v1.0.0'));
      expect(clipboard, contains('v2.0.0'));
      expect(clipboard, isNot(contains('private-token')));
      expect(repository.attempts, 1);

      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(repository.attempts, 2);
      expect(model.luaReady, isTrue);
      expect(find.text('Найти папку PoB'), findsOneWidget);
      expect(find.textContaining(_failure), findsNothing);
      expect(find.text('Повторить'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await model.close();
    },
  );
}

class _SetupRepository extends ComponentRepository {
  _SetupRepository(InstallationStore store)
    : super(
        store: store,
        github: _SetupGitHub(),
        processes: _SetupProcesses(),
      ) {
    active = {
      Component.pob: const Installation(
        tag: 'v1.0.0',
        commit: 'old',
        directory: 'pob-old',
      ),
    };
  }

  final failDownload = Completer<void>();
  int attempts = 0;

  @override
  Future<void> installPair(
    Map<Component, Release> releases,
    void Function(String) log, {
    Future<void> Function(Installations)? validate,
    void Function(ComponentInstallStage)? onStage,
  }) async {
    attempts++;
    onStage?.call(ComponentInstallStage.mcp);
    if (attempts == 1) {
      log(_privateOutput);
      await failDownload.future;
      throw StateError(_failure);
    }
    final candidate = {
      for (final entry in releases.entries)
        entry.key: Installation(
          tag: entry.value.tag,
          commit: entry.key.name,
          directory: entry.key.name,
        ),
    };
    await validate?.call(candidate);
    active = candidate;
  }
}

class _SetupGitHub extends GitHubService {
  @override
  Future<Release> latest(Component component) async =>
      Release('v2.0.0', '', DateTime.utc(2026));
}

class _SetupProcesses extends ProcessService {
  @override
  Future<String> python() async => 'python';

  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async => 'git version';
}

class _SetupEngine extends McpClient {
  bool _connected = false;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect(Installations pair) async => _connected = true;

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async => {
    'entries': [
      {'id': 1, 'name': 'Witch'},
    ],
  };
}

class _SetupSession extends SessionRepository {
  _SetupSession(super.root);

  @override
  Future<bool> exists() async => false;
}
