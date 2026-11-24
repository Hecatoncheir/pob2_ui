import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path;

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/tree_progression_exchange.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
import 'package:pob2_ui/domain/tree_progression.dart';
import 'package:pob2_ui/ui/tree_class_dialog.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:xml/xml.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

const _masteryNode = 7;

String buildXml(
  int level, {
  String notes = '',
  String characterClass = 'Witch',
  String ascendancy = '',
  int? activeTreeSpec,
  int? masteryEffect,
}) {
  final ascendancyAttribute = ascendancy.isEmpty
      ? ''
      : ' ascendClassName="$ascendancy"';
  final firstSpec = masteryEffect == null
      ? '<Spec title="Урон" nodes="1"/>'
      : '<Spec title="Урон" nodes="1,$_masteryNode" '
            'masteryEffects="{$_masteryNode,$masteryEffect}"/>';
  final tree = activeTreeSpec == null
      ? ''
      : '<Tree activeSpec="$activeTreeSpec">$firstSpec'
            '<Spec title="Защита" nodes="1,2"/>'
            '</Tree>';
  return '<PathOfBuilding2><Build className="$characterClass" level="$level"'
      '$ascendancyAttribute/>$tree<Notes>$notes</Notes></PathOfBuilding2>';
}

class _SyncEngine extends WorkbenchClient {
  _SyncEngine() {
    tools = {'pob_get_tree', 'pob_tree_options'};
  }

  int level = 0;
  int loads = 0;
  int treeEdits = 0;
  int? activeTreeSpec;
  int? masteryEffect;
  int allocationMode = 0;
  String notes = '';
  String characterClass = 'Witch';
  String ascendancy = '';
  final treeOptions = <JsonMap>[];
  final masteryActions = <JsonMap>[];
  Completer<void>? editStarted, resumeEdit;
  bool exitDuringEdit = false;
  bool _connected = true;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect(Installations pair) async {
    _connected = true;
    level = 0;
  }

  @override
  Future<JsonMap> call(String tool, [JsonMap arguments = const {}]) async {
    if (!connected) throw StateError('Подключите Lua');
    switch (tool) {
      case 'pob_catalog':
        return {
          'entries': [
            {
              'id': 1,
              'name': 'Witch',
              'ascendancies': [
                {'id': 0, 'name': 'None'},
                {'id': 1, 'name': 'Infernalist'},
              ],
            },
            {
              'id': 2,
              'name': 'Ranger',
              'ascendancies': [
                {'id': 0, 'name': 'None'},
                {'id': 1, 'name': 'Deadeye'},
              ],
            },
          ],
        };
      case 'pob_import_xml':
        loads++;
        final xml = arguments['xml'] as String;
        final build = PobBuildDocument(xml);
        final root = XmlDocument.parse(xml).rootElement;
        level = build.level;
        notes = build.notes;
        characterClass = build.characterClass;
        ascendancy =
            root.getElement('Build')!.getAttribute('ascendClassName') ?? '';
        final tree = root.getElement('Tree');
        activeTreeSpec = int.tryParse(tree?.getAttribute('activeSpec') ?? '');
        final selections = tree
            ?.getElement('Spec')
            ?.getAttribute('masteryEffects');
        masteryEffect = int.tryParse(
          RegExp(r'\{\d+,(\d+)\}').firstMatch(selections ?? '')?.group(1) ?? '',
        );
        allocationMode = 0;
        return {};
      case 'pob_export_xml':
        if (level == 0) throw StateError('Сначала загрузите сборку');
        return {
          'xml': buildXml(
            level,
            notes: notes,
            characterClass: characterClass,
            ascendancy: ascendancy,
            activeTreeSpec: activeTreeSpec,
            masteryEffect: masteryEffect,
          ),
        };
      case 'pob_tree_options':
        treeOptions.add(arguments);
        if (arguments case {'spec': final int spec}) {
          activeTreeSpec = spec;
          allocationMode = 0;
          return {};
        }
        if (arguments case {'mode': final int mode}) {
          allocationMode = mode;
          return {};
        }
        if (arguments.containsKey('class')) {
          if (arguments['connect'] != true && arguments['reset'] != true) {
            throw StateError(
              'Смена класса требует соединения или сброса дерева',
            );
          }
          characterClass = 'Ranger';
        }
        ascendancy = characterClass == 'Ranger' ? 'Deadeye' : 'Infernalist';
        return {};
      case 'pob_tree_action':
        if (arguments case {'mastery': final int mastery}) {
          masteryActions.add(arguments);
          masteryEffect = mastery;
          return {};
        }
        treeEdits++;
        editStarted?.complete();
        await resumeEdit?.future;
        level++;
        if (exitDuringEdit) {
          _connected = false;
          final error = StateError('MCP завершился во время правки');
          onDisconnected?.call(error);
          throw error;
        }
        return {};
      case 'pob_check_build':
        return {
          'report': {
            ...fixture.raw,
            'snapshot': {
              'treeVersion': tree.version,
              'buildInfo': {
                ...fixture.character,
                'class': characterClass,
                'ascendancy': ascendancy,
                'level': level,
              },
            },
            'stats': {'Life': level * 10 + _treeBonus},
            if (activeTreeSpec case final active?) ...{
              'sets': {
                'tree': [
                  {'id': 1, 'title': 'Урон'},
                  {'id': 2, 'title': 'Защита'},
                ],
              },
              'activeSets': {'tree': active},
            },
          },
        };
      case 'pob_get_tree':
        return {
          'version': tree.version,
          'nodes': [
            for (final node in tree.nodes)
              {
                'id': node.id,
                'x': node.x,
                'y': node.y,
                'name': node.name,
                'type': node.kind,
                'allocated': node.allocated,
              },
          ],
          'edges': [
            for (final (from, to) in tree.edges) [from, to],
          ],
        };
      default:
        throw StateError(tool);
    }
  }

  int get _treeBonus => switch ((activeTreeSpec, masteryEffect)) {
    (2, _) => 200,
    (_, 31) => 50,
    (_, 32) => 100,
    _ => 0,
  };
}

class _SyncLibrary extends PobBuildLibrary {
  _SyncLibrary(super.profile);

  Completer<void>? preserveStarted, resumePreserve;

  @override
  Future<LibraryEntry?> preserveLocal(PobBuildVersion disk) async {
    preserveStarted?.complete();
    await resumePreserve?.future;
    return super.preserveLocal(disk);
  }
}

String _comparisonXml(
  int level,
  String skill,
  int partyDamage, {
  int? enemyLevel,
}) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/>'
    '<Skills><SkillSet id="1"><Skill><Gem nameSpec="$skill"/></Skill>'
    '</SkillSet></Skills><Config activeConfigSet="2">'
    '<ConfigSet id="1"><Input name="enemyLevel" number="50"/></ConfigSet>'
    '<ConfigSet id="2">'
    '${enemyLevel == null ? '' : '<Input name="enemyLevel" number="$enemyLevel"/>'}'
    '<Placeholder name="multiplierEnemyPoisonStacks" number="$level"/>'
    '</ConfigSet></Config><Party><ImportedBuffs name="EnemyMods">'
    '$partyDamage% increased Damage</ImportedBuffs></Party>'
    '<Notes>$skill</Notes></PathOfBuilding2>';

class _ComparisonEngine extends WorkbenchClient {
  String xml = '';
  Installations? pair;
  bool closed = false;
  final reports = <JsonMap>[];
  final pinnedLevels = <num>[];
  num? _pinnedLevel;

  @override
  bool get connected => pair != null && !closed;

  @override
  Future<void> connect(Installations pair) async {
    this.pair = pair;
    closed = false;
  }

  @override
  Future<void> close() async => closed = true;

  @override
  Future<JsonMap> call(String tool, [JsonMap arguments = const {}]) async {
    if (!connected) throw StateError('Подключите Lua');
    return switch (tool) {
      'pob_import_xml' => _import(arguments['xml'] as String),
      'pob_export_xml' => {'xml': xml},
      'pob_set_config' => _setConfig(arguments),
      'pob_check_build' => {'report': _report()},
      _ => throw StateError(tool),
    };
  }

  JsonMap _import(String value) {
    xml = value;
    _pinnedLevel = null;
    return {};
  }

  JsonMap _setConfig(JsonMap arguments) {
    final level = jsonMap(arguments['values'])['enemyLevel'] as num;
    _pinnedLevel = level;
    pinnedLevels.add(level);
    return {};
  }

  JsonMap _report() {
    final root = XmlDocument.parse(xml).rootElement;
    final config = root.getElement('Config')!;
    final selected = config.getAttribute('activeConfigSet') ?? '1';
    final settings = config
        .findElements('ConfigSet')
        .singleWhere((entry) => entry.getAttribute('id') == selected);
    final enemyLevel =
        _pinnedLevel ??
        int.tryParse(
          settings.getElement('Input')?.getAttribute('number') ?? '',
        );
    final placeholder = int.parse(
      settings.getElement('Placeholder')!.getAttribute('number')!,
    );
    final party = root.getElement('Party')!.getElement('ImportedBuffs')!;
    final skill = root.findAllElements('Gem').single.getAttribute('nameSpec')!;
    final level = PobBuildDocument(xml).level;
    final defaultEnemyLevel = level == 40 ? 83 : 70;
    final report = <String, dynamic>{
      'source': 'original-lua',
      'snapshot': {
        'buildInfo': {
          'level': level,
          'skills': {
            'selected': 1,
            'entries': [
              {'id': 1, 'label': skill},
            ],
          },
        },
      },
      'config': {if (enemyLevel != null) 'enemyLevel': enemyLevel},
      'configPlaceholders': {
        'multiplierEnemyPoisonStacks': placeholder,
        if (enemyLevel == null) 'enemyLevel': defaultEnemyLevel,
      },
      'stats': {'TotalDPS': level * 10 + (enemyLevel ?? defaultEnemyLevel)},
      'party': party.innerText,
    };
    reports.add(report);
    return report;
  }
}

void main() {
  const id = 'Общая.xml';
  late Directory root, profile, builds;
  late File original;
  late _SyncLibrary library;
  late _SyncEngine engine;
  late WorkshopCubit model;

  WorkshopCubit createWorkshop({WorkbenchClient Function()? createEngine}) {
    final components = ComponentRepository(store: InstallationStore(profile));
    components.active = {
      for (final component in Component.values)
        component: Installation(
          tag: 'v0.0.1',
          commit: component.name,
          directory: root.path,
        ),
    };
    engine = _SyncEngine();
    return WorkshopCubit(
      components,
      engine,
      library: library,
      createEngine: createEngine,
    );
  }

  Future<void> reopenWorkshop(String buildId) async {
    await model.close();
    library = _SyncLibrary(profile);
    await library.load();
    model = createWorkshop();
    await model.openBuild(buildId);
    expect(model.state.error, isNull);
  }

  Future<void> expectPlan(List<TreeProgressionStep> steps) async {
    expect(model.progressionKey, isNotNull);
    final plan = await model
        .progressionRepository(model.progressionKey!)
        .load();
    expect(encodeProgressionSteps(plan), encodeProgressionSteps(steps));
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-sync-');
    profile = Directory(path.join(root.path, 'profile'));
    builds = await Directory(path.join(root.path, 'builds')).create();
    original = await File(path.join(builds.path, id))
        .writeAsString(buildXml(40));
    library = _SyncLibrary(profile);
    await library.configure(builds.path);
    model = createWorkshop();
    await model.openBuild(id);
    expect(model.state.error, isNull);
  });

  tearDown(() async {
    if (!model.isClosed) await model.close();
    await removeTemporaryDirectory(root);
  });

  final step = TreeProgressionStep(
    42,
    [2, 3],
    title: 'Следующий этап',
    note: 'Проверить сопротивления',
    tasks: const [(text: 'Заменить посох', done: false)],
    keyNodes: const [3, 2],
  );

  test(
    'Сравнение XML использует общие условия и сохраняет рабочую сборку',
    () async {
      await model.close();
      final calculation = _ComparisonEngine();
      model = createWorkshop(createEngine: () => calculation);
      await original.writeAsString(buildXml(40, notes: 'Рабочая заметка'));
      await model.openBuild(id);
      await model.treeAction(10, false);
      await model.treeAction(11, false);
      await model.undo();
      final working = await original.readAsString();
      final workingReport = model.state.report;
      final loads = engine.loads;
      expect(model.state.undoCount, 1);
      expect(model.state.redoCount, 1);

      final baseline = _comparisonXml(40, 'Fireball', 83);
      final candidate = _comparisonXml(60, 'Spark', 70, enemyLevel: 70);
      final first = await File(path.join(builds.path, 'Первая.xml'))
          .writeAsString(baseline);
      final second = await File(path.join(builds.path, 'Вторая.xml'))
          .writeAsString(candidate);
      final result = await model.compareSavedBuilds(
        await first.readAsString(),
        await second.readAsString(),
      );

      expect(result.before.config, {'enemyLevel': 83});
      expect(result.after.config, result.before.config);
      expect(result.before.stats['TotalDPS'], 483);
      expect(result.after.stats['TotalDPS'], 683);
      expect(result.before.mainSkill, 'Fireball');
      expect(result.after.mainSkill, 'Spark');
      expect(result.components, calculation.pair);
      expect(calculation.reports.first['config'], isEmpty);
      expect(calculation.pinnedLevels, [83, 83]);
      expect(calculation.reports.last['configPlaceholders'], {
        'multiplierEnemyPoisonStacks': 40,
      });
      expect(calculation.reports.last['party'], '83% increased Damage');
      expect(calculation.closed, isTrue);

      expect(engine.loads, loads);
      expect(model.state.library.activeId, id);
      expect(model.state.report, same(workingReport));
      expect(model.state.undoCount, 1);
      expect(model.state.redoCount, 1);
      expect(await library.readNotes(id), 'Рабочая заметка');
      expect(await original.readAsString(), working);
      expect(await first.readAsString(), baseline);
      expect(await second.readAsString(), candidate);
    },
  );

  test('Переключение набора дерева сохраняется в XML и отменяется', () async {
    await original.writeAsString(
      buildXml(40, activeTreeSpec: 1, notes: 'Заметка сборки'),
    );
    await model.openBuild(id);
    final originalXml = await original.readAsString();
    expect(model.state.report?.activeTreeSpec, 1);
    expect(model.state.report?.treeSpecs, [
      (id: 1, title: 'Урон'),
      (id: 2, title: 'Защита'),
    ]);
    expect(model.state.report?.stats['Life'], 400);
    await model.selectTreeMode(TreeAllocationMode.weaponTwo);

    final changed = await model.selectTreeSpec(2);
    expect(changed.committed, isTrue, reason: changed.error);
    expect(engine.treeOptions, [
      {'mode': 2},
      {'spec': 2},
      {'mode': 2},
    ]);
    expect(engine.allocationMode, 2);
    expect(model.state.library.activeId, id);
    expect(model.state.report?.activeTreeSpec, 2);
    expect(model.state.report?.stats['Life'], 600);
    expect(model.state.undoCount, 1);
    final savedXml = await original.readAsString();
    expect(savedXml, buildXml(40, activeTreeSpec: 2, notes: 'Заметка сборки'));

    await model.undo();
    expect(engine.allocationMode, 2);
    expect(model.state.report?.activeTreeSpec, 1);
    expect(model.state.report?.stats['Life'], 400);
    expect(await original.readAsString(), originalXml);

    await model.redo();
    await reopenWorkshop(id);
    expect(model.state.report?.activeTreeSpec, 2);
    expect(model.state.report?.stats['Life'], 600);
    expect(await original.readAsString(), savedXml);
  });

  test('Выбор и смена мастерства сохраняются в XML и отменяются', () async {
    const notes = 'Заметка при выборе мастерства';
    final initialXml = buildXml(40, activeTreeSpec: 1, notes: notes);
    await original.writeAsString(initialXml);
    await model.openBuild(id);
    expect(model.state.report?.stats['Life'], 400);

    final first = await model.selectMastery(_masteryNode, 31);
    expect(first.committed, isTrue, reason: first.error);
    expect(model.state.report?.stats['Life'], 450);
    final firstXml = buildXml(
      40,
      activeTreeSpec: 1,
      masteryEffect: 31,
      notes: notes,
    );
    expect(await original.readAsString(), firstXml);

    final second = await model.selectMastery(_masteryNode, 32);
    expect(second.committed, isTrue, reason: second.error);
    expect(engine.masteryActions, [
      {'id': _masteryNode, 'action': 'allocate', 'mastery': 31},
      {'id': _masteryNode, 'action': 'allocate', 'mastery': 32},
    ]);
    expect(model.state.report?.stats['Life'], 500);
    expect(
      await original.readAsString(),
      buildXml(40, activeTreeSpec: 1, masteryEffect: 32, notes: notes),
    );
    expect(model.state.library.activeId, id);
    expect(model.state.undoCount, 2);

    await model.undo();
    expect(model.state.report?.stats['Life'], 450);
    expect(await original.readAsString(), firstXml);

    await model.undo();
    expect(model.state.report?.stats['Life'], 400);
    expect(await original.readAsString(), initialXml);
  });

  test(
    'Смена класса и восхождения сохраняется и отменяется через Undo',
    () async {
      await model.connect();
      expect(model.state.error, isNull);
      final before = await original.readAsString();
      final blocked = await model.selectTreeClass(classId: 2, ascendancyId: 1);
      expect(blocked.committed, isFalse);
      expect(blocked.error, contains('Смена класса требует'));
      expect(model.state.report?.characterClass, 'Witch');
      expect(model.state.undoCount, 0);
      expect(await original.readAsString(), before);

      final changed = await model.selectTreeClass(
        classId: 2,
        ascendancyId: 1,
        connect: true,
      );
      expect(changed.committed, isTrue, reason: changed.error);
      expect(engine.treeOptions.last, {
        'class': 2,
        'ascendancy': 1,
        'connect': true,
      });
      expect(model.state.library.activeId, id);
      expect(model.state.report?.characterClass, 'Ranger');
      expect(model.state.report?.character['ascendancy'], 'Deadeye');
      expect(model.state.undoCount, 1);
      expect(
        await original.readAsString(),
        buildXml(40, characterClass: 'Ranger', ascendancy: 'Deadeye'),
      );

      await model.undo();
      expect(model.state.error, isNull);
      expect(model.state.report?.characterClass, 'Witch');
      expect(model.state.report?.character['ascendancy'], isEmpty);
      expect(model.state.undoCount, 0);
      expect(model.state.redoCount, 1);
      expect(await original.readAsString(), before);

      final onlyAscendancy = await model.selectTreeClass(
        classId: 1,
        ascendancyId: 1,
      );
      expect(onlyAscendancy.committed, isTrue, reason: onlyAscendancy.error);
      expect(engine.treeOptions.last, {'ascendancy': 1});
      expect(model.state.report?.characterClass, 'Witch');
      expect(model.state.report?.character['ascendancy'], 'Infernalist');
    },
  );

  testWidgets('Диалог смены класса оставляет дерево при отмене', (
    tester,
  ) async {
    final before = await tester.runAsync(() async {
      await model.connect();
      return original.readAsString();
    });
    expect(model.state.error, isNull);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TreeClassButton(model))),
    );
    await tester.tap(find.byKey(const Key('tree-class')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tree-class-choice')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ranger').last);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final refused = model.stream
          .firstWhere((state) => !state.busy && state.error != null)
          .timeout(const Duration(seconds: 10));
      await tester.tap(find.text('Применить'));
      await refused;
    });
    await tester.pumpAndSettle();
    expect(find.text('Сбросить дерево'), findsOneWidget);
    expect(find.text('Соединить дерево'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(engine.treeOptions, [
      {'class': 2, 'ascendancy': 0},
    ]);
    expect(model.state.report?.characterClass, 'Witch');
    expect(model.state.undoCount, 0);
    expect(await tester.runAsync(original.readAsString), before);
  });

  test('План следует за сборкой при переименовании и Undo/Redo', () async {
    await model.progressionRepository(model.progressionKey!).save([step]);

    await model.renameBuild('Переименованная');
    expect(model.state.error, isNull);
    final renamedId = model.state.library.activeId!;
    expect(renamedId, isNot(id));
    await expectPlan([step]);

    final edited = step.withProgress(completed: true);
    await model.progressionRepository(model.progressionKey!).save([edited]);
    await model.undo();
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, id);
    await expectPlan([edited]);

    await model.redo();
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, renamedId);
    await expectPlan([edited]);
    await reopenWorkshop(renamedId);
    await expectPlan([edited]);

    await original.writeAsString(buildXml(28));
    await model.openBuild(id);
    expect(model.state.error, isNull);
    expect(model.state.report?.level, 28);
    await expectPlan([]);
  });

  test('Смена регистра имени XML сохраняет план и заметки', () async {
    await model.progressionRepository(model.progressionKey!).save([step]);
    await library.readNotes(id);
    await library.saveNotes(id, 'Заметка о сборке');

    await model.renameBuild('общая');

    const renamedId = 'общая.xml';
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, renamedId);
    expect((await library.scan()).entries.single.id, renamedId);
    expect(await library.readNotes(renamedId), 'Заметка о сборке');
    await expectPlan([step]);

    await model.undo();
    expect(model.state.error, isNull);
    expect((await library.scan()).entries.single.id, id);
    await expectPlan([step]);
  });

  test(
    'Создание копии переносит план и заметки независимо от оригинала',
    () async {
      await model.progressionRepository(model.progressionKey!).save([step]);
      await library.readNotes(id);
      await library.saveNotes(id, 'Заметка о сборке');

      await model.copyBuild();
      expect(model.state.error, isNull);
      final copyId = model.state.library.activeId!;
      expect(copyId, isNot(id));
      expect(await library.readNotes(copyId), 'Заметка о сборке');
      await expectPlan([step]);

      final copyStep = step.withProgress(
        tasks: const [(text: 'Заменить посох', done: true)],
        keyNodes: const [2, 3],
      );
      await model.progressionRepository(model.progressionKey!).save([copyStep]);
      await reopenWorkshop(copyId);
      await expectPlan([copyStep]);
      await model.openBuild(id);
      expect(model.state.error, isNull);
      expect(model.state.library.activeId, id);
      await expectPlan([step]);
    },
  );

  test('Занятое имя оставляет сборку и оба плана без изменений', () async {
    final source = model.progressionKey!;
    await model.progressionRepository(source).save([step]);
    const takenId = 'Занятая.xml';
    final taken = File(path.join(builds.path, takenId));
    await taken.writeAsString(buildXml(65));
    final otherKey = (
      folder: source.folder,
      build: takenId,
      version: source.version,
      characterClass: source.characterClass,
    );
    final otherStep = TreeProgressionStep(65, [1]);
    await model.progressionRepository(otherKey).save([otherStep]);

    await model.renameBuild('Занятая');
    expect(model.state.error, isNotNull);
    expect(model.state.library.activeId, id);
    expect(model.state.undoCount, 0);
    expect(await original.readAsString(), buildXml(40));
    expect(await taken.readAsString(), buildXml(65));
    await expectPlan([step]);
    final other = await model.progressionRepository(otherKey).load();
    expect(encodeProgressionSteps(other), encodeProgressionSteps([otherStep]));
  });

  test(
    'Сбой записи плана сохраняет исходный XML и позволяет повторить',
    () async {
      final source = model.progressionKey!;
      await model.progressionRepository(source).save([step]);
      const title = 'Переименованная';
      final key = sha256.convert(
        utf8.encode(
          jsonEncode([
            source.folder,
            '$title.xml',
            source.version,
            source.characterClass,
          ]),
        ),
      );
      final blocked = await Directory.fromUri(
        profile.uri.resolve('tree-progression/$key.json'),
      ).create();

      await model.renameBuild(title);
      expect(model.state.error, isNotNull);
      expect(model.state.library.activeId, id);
      expect(model.state.undoCount, 0);
      expect(await original.readAsString(), buildXml(40));
      expect((await library.scan()).entries, hasLength(1));
      await expectPlan([step]);

      await blocked.delete();
      await model.renameBuild(title);
      expect(model.state.error, isNull);
      await expectPlan([step]);
    },
  );

  test(
    'Внешний XML подхватывается автоматически, Lua пересчитывает показатели',
    () async {
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 55,
      );
      final temporary = await File(path.join(builds.path, '~~temp~~.xml'))
          .writeAsString(buildXml(55), flush: true);
      await temporary.rename(original.path);
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.stats['Life'], 550);
      expect(model.state.library.activeId, id);
      expect(model.state.library.entries, hasLength(1));
      expect(await original.readAsString(), buildXml(55));
    },
  );

  test(
    'Свои записи и неполный XML не перезагружаются, диалог защищён',
    () async {
      await model.treeAction(10, false);
      await model.syncOpenBuild();
      expect(engine.loads, 1);
      expect(model.state.undoCount, 1);
      await original.writeAsString('<PathOfBuilding2>');
      await model.syncOpenBuild();
      expect(model.state.error, isNull);
      expect(model.state.report!.level, 41);
      model.modalOpen = () => true;
      await original.writeAsString(buildXml(55, notes: 'Новые заметки'));
      await model.syncOpenBuild();
      expect(model.state.report!.level, 41);
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 55,
      );
      model.modalOpen = null;
      model.resumeBuildSync();
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.level, 55);
      expect(model.state.undoCount, 0);
      final copy = model.state.library.entries.singleWhere(
        (entry) => entry.id != id,
      );
      expect(await library.read(copy.id), buildXml(41));
      await model.syncOpenBuild();
      expect(model.state.library.entries, hasLength(2));
    },
  );

  test('Последние правки и заметки переживают перезапуск PoB II', () async {
    await model.treeAction(10, false);
    await library.readNotes(id);
    await library.saveNotes(id, 'Мой план');
    final localXml = await original.readAsString();
    await model.close();
    await original.writeAsString(buildXml(48, notes: 'План из PoB'));
    final reopened = PobBuildLibrary(profile);
    await reopened.load();
    final disk = await reopened.open(id);
    final copy = await reopened.preserveLocal(disk);
    expect(copy, isNotNull);
    expect(await reopened.read(copy!.id), localXml);
    expect(await reopened.readNotes(copy.id), 'Мой план');
    expect(await original.readAsString(), buildXml(48, notes: 'План из PoB'));
    expect(await reopened.preserveLocal(disk), isNull);
  });

  test(
    'Устаревший снимок наблюдателя не расходует резервную копию заметок',
    () async {
      await model.treeAction(10, false);
      final stale = await library.open(id);
      await library.readNotes(id);
      await library.saveNotes(id, 'Новый план');
      expect(await library.preserveLocal(stale), isNull);
      expect(await library.readNotes(id), 'Новый план');
      expect((await library.scan()).entries, hasLength(1));
      await model.close();
      await original.writeAsString(buildXml(48, notes: 'План из PoB'));
      final reopened = PobBuildLibrary(profile);
      await reopened.load();
      final copy = await reopened.preserveLocal(await reopened.open(id));
      expect(copy, isNotNull);
      expect(await reopened.readNotes(copy!.id), 'Новый план');
    },
  );

  test('После завершения MCP открывается сохранённая сборка и правка не повторяется', () async {
    await model.close();
    model = createWorkshop();
    await model.connect();
    expect(model.state.error, isNull);
    await model.openBuild(id);
    expect(model.state.error, isNull);
    await library.readNotes(id);
    await library.saveNotes(id, 'Рабочие заметки');
    await model.treeAction(10, false);
    expect(model.state.error, isNull);
    expect(model.state.report?.stats['Life'], 410);
    final savedXml = await original.readAsString();
    engine.exitDuringEdit = true;

    await model.treeAction(11, false);

    expect(engine.level, 42);
    expect(engine.connected, isFalse);
    expect(model.state.status, 'Соединение с Lua прервано');
    expect(model.state.error, contains('MCP завершился во время правки'));
    expect(model.state.document?.stale, isTrue);
    expect(await original.readAsString(), savedXml);

    await model.connect();

    expect(model.state.error, isNull);
    expect(model.state.document?.stale, isFalse);
    expect(model.state.library.activeId, id);
    expect(model.state.report?.stats['Life'], 410);
    expect(await library.readNotes(id), 'Рабочие заметки');
    expect(await original.readAsString(), savedXml);
    expect(engine.treeEdits, 2);
  });

  test('Закрытие ждёт сохранения копии при синхронизации', () async {
    await model.treeAction(10, false);
    final started = library.preserveStarted = Completer<void>();
    final resume = library.resumePreserve = Completer<void>();
    await original.writeAsString(buildXml(55));
    final sync = model.syncOpenBuild();
    await started.future.timeout(const Duration(seconds: 5));
    final closed = Completer<void>();
    final closing = model.close().then((_) => closed.complete());
    try {
      await expectLater(
        closed.future.timeout(const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    } finally {
      resume.complete();
      await sync;
      await closing;
    }
    final reopened = PobBuildLibrary(profile);
    final builds = await reopened.load();
    final copy = builds.entries.singleWhere((entry) => entry.id != id);
    expect(await reopened.read(copy.id), buildXml(41));
  });

  test(
    'Правка, которую Lua ещё считает при внешней записи, сохраняется отдельно',
    () async {
      final started = engine.editStarted = Completer<void>();
      final resume = engine.resumeEdit = Completer<void>();
      final localEdit = model.treeAction(10, false);
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 60,
      );
      await started.future.timeout(const Duration(seconds: 3));
      await original.writeAsString(buildXml(60));
      resume.complete();
      await localEdit;
      final copy = model.state.library.entries.singleWhere(
        (entry) => entry.id != id,
      );
      expect(model.state.error, contains(copy.title));
      expect(await library.read(copy.id), buildXml(41));
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.level, 60);
      expect(model.state.library.entries, hasLength(2));
      expect(await original.readAsString(), buildXml(60));
    },
  );
}
