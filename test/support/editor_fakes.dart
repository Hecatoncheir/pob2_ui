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
    tools = {'pob_gem_icons', 'pob_gem_supports'};
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
}
