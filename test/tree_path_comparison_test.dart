import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/tree_path_comparison.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/tree_allocation_mode.dart';

const _source = '''
<PathOfBuilding2><Build/><Tree><Spec nodes="1,11,21">
<WeaponSet1 nodes="11"/><WeaponSet2 nodes="21"/>
</Spec></Tree></PathOfBuilding2>
''';

class _PathEngine extends McpClient {
  var mode = 0;
  var target = 0;
  var imports = 0;
  var closed = false;
  var wrongWeapon = false;
  var reachable = true;
  final modes = <int>[];

  @override
  Future<void> connect(Installations pair) async {}

  @override
  Future<void> close() async => closed = true;

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    switch (name) {
      case 'pob_import_xml':
        imports++;
        mode = 0;
        target = 0;
        return {};
      case 'pob_tree_options':
        mode = arguments['mode'] as int;
        modes.add(mode);
        return {};
      case 'pob_node_tooltip':
        return {
          'path': reachable ? [arguments['id']] : [],
          'points': 1,
        };
      case 'pob_tree_action':
        target = arguments['id'] as int;
        return {};
      case 'pob_check_build':
        return {'report': _report()};
      case 'pob_export_xml':
        return {'xml': _xml()};
      default:
        throw StateError(name);
    }
  }

  JsonMap _report() => {
    'source': 'original-lua',
    'weaponSet': wrongWeapon && target != 0 ? 2 : 1,
    'pointDisplay':
        '1 / 123 ${target == 22
            ? 4
            : target == 12
            ? 2
            : 1} / 24 1 / 24 0 / 8',
    'stats': {'TotalDPS': 10, 'Life': 100},
  };

  String _xml() {
    if (target == 0) return _source;
    final extra = target == 12 ? '12' : '13,14,22';
    return _source
        .replaceAll('nodes="1,11,21"', 'nodes="1,11,21,$extra"')
        .replaceAll('nodes="11"', 'nodes="11,$extra"');
  }
}

void main() {
  test(
    'Стоимость и узлы берутся из результата Lua при другом пути подсказки',
    () async {
      final engine = _PathEngine();
      final result = await compareTreePaths(
        engine,
        {},
        _source,
        12,
        22,
        mode: TreeAllocationMode.weaponOne,
      );
      expect(result.first.points, 1);
      expect(result.second.points, 3);
      expect(result.second.nodes, [13, 14, 22]);
      expect(PobBuildDocument(result.second.xml).allocationModes[21], 2);
      expect(engine.imports, 2);
      expect(engine.modes, [1, 1]);
      expect(engine.closed, isTrue);
    },
  );

  test('Смена активного оружия в пробной сессии отклоняет сравнение', () async {
    final engine = _PathEngine()..wrongWeapon = true;
    await expectLater(
      compareTreePaths(
        engine,
        {},
        _source,
        12,
        22,
        mode: TreeAllocationMode.weaponOne,
      ),
      throwsFormatException,
    );
    expect(engine.closed, isTrue);
  });

  for (final allocated in [false, true]) {
    test(
      'Уже назначенная или недоступная цель отклоняется: $allocated',
      () async {
        final engine = _PathEngine()..reachable = allocated;
        await expectLater(
          compareTreePaths(
            engine,
            {},
            _source,
            allocated ? 11 : 12,
            22,
            mode: TreeAllocationMode.weaponOne,
          ),
          throwsFormatException,
        );
        expect(engine.target, 0);
        expect(engine.closed, isTrue);
      },
    );
  }

  test('Порядок узлов I/II в XML не меняет распределение', () {
    final before = PobBuildDocument(
      _source.replaceAll('nodes="11"', 'nodes="11,12"'),
    );
    final after = PobBuildDocument(
      _source.replaceAll('nodes="11"', 'nodes="12,11"'),
    );
    expect(before.hasSameTreeAllocation(after), isTrue);
  });

  test('Порядок узлов атрибутов после импорта Lua не меняет распределение', () {
    const template =
        '<PathOfBuilding2><Build/><Tree><Spec nodes="11,12">'
        '<Overrides><AttributeOverride strNodes="11,12" dexNodes="" intNodes=""/>'
        '</Overrides></Spec></Tree></PathOfBuilding2>';
    final before = PobBuildDocument(template);
    final after = PobBuildDocument(
      template.replaceAll('strNodes="11,12"', 'strNodes="12,11"'),
    );
    expect(before.hasSameTreeAllocation(after), isTrue);
    final changed = PobBuildDocument(
      template.replaceAll('strNodes="11,12"', 'strNodes="11"'),
    );
    expect(before.hasSameTreeAllocation(changed), isFalse);
  });
}
