import 'dart:io';

import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_edit_result.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'workshop_fixture.dart';

const fireball = {
  'id': 'gem-fireball',
  'name': 'Fireball',
  'naturalMaxLevel': 20,
};
const moving = {
  'id': 'conditionEnemyMoving',
  'name': 'Is the enemy Moving?',
  'type': 'check',
  'choices': <JsonMap>[],
};
const boss = {
  'id': 'enemyIsBoss',
  'name': 'Is the enemy a Boss?',
  'type': 'list',
  'choices': [
    {'value': 'None', 'label': 'No'},
    {'value': 'Pinnacle', 'label': 'Pinnacle Boss'},
    {'value': 'Pinnacle', 'label': 'Duplicate'},
  ],
};

class EditorCatalogEngine extends McpClient {
  EditorCatalogEngine({this.gemEntries = const [fireball]}) {
    tools = {
      'pob_gem_icons',
      'pob_gem_supports',
      'pob_update_skill_group',
      'pob_delete_skill_group',
    };
  }
  final List<JsonMap> gemEntries;
  final iconRequests = <List<dynamic>>[];
  final queries = <JsonMap>[];
  bool fail = false;
  @override
  bool get connected => true;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name == 'pob_gem_supports')
      return {
        'source': 'original-lua',
        'supportIds': gemEntries
            .where((gem) => gem['support'] == true)
            .map((gem) => gem['id'])
            .toList(),
      };
    if (name == 'pob_gem_icons') {
      iconRequests.add(arguments['ids'] as List<dynamic>);
      return {
        'icons': (arguments['ids'] as List<dynamic>)
            .map(
              (id) => {
                'id': id,
                'source': 'original-pob',
                'data': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
              },
            )
            .toList(),
      };
    }
    queries.add(arguments);
    if (fail) throw StateError('Ошибка чтения каталога');
    final rows = arguments['kind'] == 'gems' ? gemEntries : [moving, boss];
    return {'entries': rows, 'total': rows.length};
  }
}

class EditorWorkshop extends WorkshopCubit {
  EditorWorkshop(EditorCatalogEngine engine, {BuildReport? report})
    : super(
        ComponentRepository(
          store: InstallationStore(Directory('unused-editor-widget')),
        ),
        engine,
        initialState: WorkshopState(
          document: (
            report: report ?? fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
  BuildEditResult result = (committed: true, error: null);
  List<JsonMap>? savedGems;
  String? savedLabel;
  int? savedGroupId;
  int? deletedGroupId;
  (String, int)? selectedMain;
  (String, Object)? savedCondition;
  @override
  Future<BuildEditResult> addSkillGroup(
    String label,
    List<JsonMap> gems,
  ) async {
    savedGems = gems;
    savedLabel = label;
    return result;
  }

  @override
  Future<BuildEditResult> setCondition(String key, dynamic value) async {
    savedCondition = (key, value as Object);
    return result;
  }

  @override
  Future<BuildEditResult> updateSkillGroup(
    int id,
    String label,
    List<JsonMap> gems,
  ) async {
    savedGroupId = id;
    savedGems = gems;
    savedLabel = label;
    if (result.committed) {
      final catalog = (engine as EditorCatalogEngine).gemEntries;
      final groups = state.report!.groups
          .map(
            (group) => group['id'] != id
                ? group
                : {
                    ...group,
                    'customLabel': label,
                    'gems': gems.indexed
                        .map(
                          (entry) => {
                            ...entry.$2,
                            'name': catalog.firstWhere(
                              (gem) => gem['id'] == entry.$2['id'],
                            )['name'],
                            'support':
                                catalog.firstWhere(
                                  (gem) => gem['id'] == entry.$2['id'],
                                )['support'] ==
                                true,
                            'sourceIndex': entry.$1 + 1,
                          },
                        )
                        .toList(),
                  },
          )
          .toList();
      _report({...state.report!.raw, 'groups': groups});
    }
    return result;
  }

  @override
  Future<BuildEditResult> deleteSkillGroup(int id) async {
    deletedGroupId = id;
    if (!result.committed) return result;
    final groups = state.report!.groups
        .where((group) => group['id'] != id)
        .indexed
        .map((entry) => {...entry.$2, 'id': entry.$1 + 1})
        .toList();
    _report({...state.report!.raw, 'groups': groups});
    if (groups.isNotEmpty) await selectMain('groups', 1);
    return result;
  }

  @override
  Future<void> selectMain(String control, int id) async {
    selectedMain = (control, id);
    final raw = state.report!.raw;
    final snapshot = jsonMap(raw['snapshot']);
    final info = jsonMap(snapshot['buildInfo']);
    _report({
      ...raw,
      'snapshot': {
        ...snapshot,
        'buildInfo': {
          ...info,
          'groups': {...jsonMap(info['groups']), 'selected': id},
        },
      },
    });
  }

  void _report(JsonMap raw) => emit(
    state.copyWith(
      document: (
        report: BuildReport.fromJson(raw),
        tree: state.document!.tree,
        stale: false,
        treeError: null,
      ),
    ),
  );
}
