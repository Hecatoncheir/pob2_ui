import 'dart:async';
import 'dart:convert';

import '../domain/gem_icon.dart';
import '../domain/build_report.dart';
import '../domain/condition_definition.dart';
import '../domain/skill_gem.dart';
import 'mcp_client.dart';

class GameCatalogRepository {
  GameCatalogRepository(this.engine);
  final McpClient engine;
  final Map<String, Future<List<JsonMap>>> _cache = {};
  final Map<String, Future<GemIcon>> _icons = {};
  final Map<String, Completer<GemIcon>> _queuedIcons = {};
  bool _iconScheduled = false;

  bool get hasGemEditor =>
      engine.tools.containsAll({'pob_gem_icons', 'pob_gem_supports'});

  void clear() {
    _cache.clear();
    _icons.clear();
  }

  Future<Set<String>> supports(List<JsonMap> gems, {int? groupId}) async {
    if (!hasGemEditor)
      throw const FormatException(
        'Обновите MCP для каталога камней и совместимости',
      );
    final result = await engine.call('pob_gem_supports', {
      'gems': gems,
      if (groupId != null) 'groupId': groupId,
    });
    return switch (result) {
      {'source': 'original-lua', 'supportIds': final List<dynamic> ids} =>
        Set.unmodifiable(ids.cast<String>()),
      _ => throw const FormatException('Lua не вернул совместимость камней'),
    };
  }

  Future<GemIcon> icon(String id) => _icons.putIfAbsent(id, () {
    final result = Completer<GemIcon>();
    _queuedIcons[id] = result;
    if (!_iconScheduled) {
      _iconScheduled = true;
      scheduleMicrotask(_flushIcons);
    }
    return result.future;
  });

  Future<void> _flushIcons() async {
    while (_queuedIcons.isNotEmpty) {
      final ids = _queuedIcons.keys.take(24).toList();
      final pending = {for (final id in ids) id: _queuedIcons.remove(id)!};
      await _readIcons(pending);
    }
    _iconScheduled = false;
  }

  Future<void> _readIcons(Map<String, Completer<GemIcon>> pending) async {
    try {
      if (!hasGemEditor)
        throw const FormatException(
          'Обновите MCP для оригинальных иконок камней',
        );
      final result = await engine.call('pob_gem_icons', {
        'ids': pending.keys.toList(),
      });
      final rows = {
        for (final row in jsonRows(result['icons'])) row['id']: row,
      };
      for (final entry in pending.entries) {
        _completeIcon(entry.key, entry.value, rows[entry.key]);
      }
    } catch (error, stack) {
      for (final completer in pending.values) {
        if (!completer.isCompleted) completer.completeError(error, stack);
      }
      for (final id in pending.keys) {
        _icons.remove(id);
      }
    }
  }

  void _completeIcon(String id, Completer<GemIcon> completer, JsonMap? row) {
    try {
      if (row case {'data': final String data, 'source': final String source}) {
        completer.complete((
          bytes: base64Decode(data).asUnmodifiableView(),
          source: source,
        ));
      } else {
        throw FormatException(
          row?['error'] as String? ?? 'Изображение камня не найдено',
        );
      }
    } catch (error, stack) {
      _icons.remove(id);
      completer.completeError(error, stack);
    }
  }

  Future<List<SkillGem>> gems() => _typed('gems', SkillGem.fromJson);

  Future<List<ConditionDefinition>> conditions() =>
      _typed('config', ConditionDefinition.fromJson);

  Future<List<T>> _typed<T>(String kind, T Function(JsonMap) parse) async {
    try {
      return List.unmodifiable((await _load(kind)).map(parse));
    } catch (_) {
      _cache.remove(kind);
      rethrow;
    }
  }

  Future<List<JsonMap>> _load(String kind) =>
      _cache.putIfAbsent(kind, () async {
        try {
          return await _pages(kind);
        } catch (_) {
          _cache.remove(kind);
          rethrow;
        }
      });

  Future<List<JsonMap>> _pages(String kind) async {
    final rows = <JsonMap>[];
    var total = 1;
    while (rows.length < total) {
      final page = await engine.call('pob_catalog', {
        'kind': kind,
        'offset': rows.length,
        'limit': 200,
      });
      total = page['total'] as int;
      final entries = jsonRows(page['entries']);
      if (entries.isEmpty && rows.length < total) {
        throw const FormatException('Lua вернул неполный каталог');
      }
      rows.addAll(entries);
    }
    return List.unmodifiable({for (final row in rows) row['id']: row}.values);
  }
}
