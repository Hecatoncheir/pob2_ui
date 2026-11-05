import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import 'mcp_client.dart';

class TreeIconRepository {
  Future<Map<String, Uint8List>> overlay(
    TreeGeometry tree,
    McpClient engine,
    String source,
  ) async {
    final loaded = await _loadScene(tree, engine, source, null);
    if (loaded.iconError case final error?) throw StateError(error);
    return {
      for (final key
          in tree.original!.commands.map((command) => command.texture).toSet())
        key: loaded.icons[key]!,
    };
  }

  TreeIconRepository({this.root});
  final Directory? root;
  final _cache = <(String, String), Map<String, Uint8List>>{};

  Future<TreeGeometry> load(
    TreeGeometry tree,
    McpClient engine,
    String source, {
    void Function(int, int)? onProgress,
  }) async {
    if (tree.original != null)
      return _loadScene(tree, engine, source, onProgress);
    if (!engine.tools.contains('pob_tree_icons')) {
      return tree.withIcons(
        {},
        'Для оригинальных иконок обновите MCP до 0.6.0.',
      );
    }
    final cache = _cache.putIfAbsent((source, tree.version), () => {});
    final missing = tree.nodes
        .map((node) => node.icon)
        .nonNulls
        .toSet()
        .where((key) => key.isNotEmpty && !cache.containsKey(key))
        .toList();
    try {
      await _loadMissing(missing, cache, engine);
      return tree.withIcons(cache, null);
    } catch (error) {
      return tree.withIcons(cache, 'Часть иконок недоступна: $error');
    }
  }

  Future<TreeGeometry> _loadScene(
    TreeGeometry tree,
    McpClient engine,
    String source,
    void Function(int, int)? onProgress,
  ) async {
    if (!engine.tools.contains('pob_tree_textures')) {
      return tree.withIcons(
        {},
        'Для готового дерева PoB обновите MCP до 0.7.0.',
      );
    }
    final cache = _cache.putIfAbsent((source, tree.version), () => {});
    final keys = tree.original!.commands
        .map((command) => command.texture)
        .toSet();
    var loaded = keys.where(cache.containsKey).length;
    onProgress?.call(loaded, keys.length);
    try {
      for (final token in keys.where((key) => !cache.containsKey(key))) {
        cache[token] = await _texture(engine, token, source, tree.version);
        loaded++;
        _progress(onProgress, loaded, keys.length);
      }
      return tree.withIcons(cache, null);
    } catch (error) {
      return tree.withIcons(
        cache,
        'Готовая сцена загружена не полностью: $error',
      );
    }
  }

  File? _file(String source, String version, String token) {
    if (root == null) return null;
    if (!RegExp(r'^[a-f0-9]{40}-[a-f0-9]{40}$').hasMatch(source) ||
        !RegExp(r'^[0-9_]{1,32}$').hasMatch(version) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Некорректный ключ кеша дерева');
    }
    return File.fromUri(root!.uri.resolve('$source/$version/$token.png'));
  }

  Future<Uint8List> _texture(
    McpClient engine,
    String token,
    String source,
    String version,
  ) async {
    final file = _file(source, version, token);
    final stored = await _readCache(file);
    if (stored != null) return stored;
    final bytes = _sceneImage(
      await engine.call('pob_tree_textures', {'token': token}),
      token,
    );
    if (file != null) {
      await file.parent.create(recursive: true);
      final temporary = File(
        '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
      );
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(file.path);
    }
    return bytes;
  }

  Future<Uint8List?> _readCache(File? file) async {
    if (file == null || !await file.exists()) return null;
    if (await file.length() > 4 * 1024 * 1024) return null;
    final bytes = await file.readAsBytes();
    return _validPng(bytes) ? bytes : null;
  }

  bool _validPng(Uint8List bytes) =>
      bytes.length >= 8 && base64Encode(bytes.sublist(0, 8)) == 'iVBORw0KGgo=';

  void _progress(void Function(int, int)? callback, int loaded, int total) {
    if (loaded % 16 == 0 || loaded == total) callback?.call(loaded, total);
  }

  Uint8List _sceneImage(JsonMap json, String token) => switch (json) {
    {'token': final String key, 'png': final String png}
        when key == token && png.length < 6 * 1024 * 1024 =>
      base64Decode(png),
    _ => throw const FormatException('Некорректная текстура готового дерева'),
  };

  Future<void> _loadMissing(
    List<String> keys,
    Map<String, Uint8List> cache,
    McpClient engine,
  ) async {
    for (var start = 0; start < keys.length; start += 32) {
      final batch = keys.skip(start).take(32).toList();
      final result = await engine.call('pob_tree_icons', {'icons': batch});
      _read(result, batch, cache);
    }
  }

  void _read(JsonMap result, List<String> batch, Map<String, Uint8List> cache) {
    final entries = jsonRows(result['icons']);
    for (final entry in entries) {
      switch (entry) {
        case {'key': final String key, 'png': final String png}
            when batch.contains(key):
          final bytes = base64Decode(png);
          if (bytes.length > 1024 * 1024)
            throw const FormatException('Слишком большая иконка');
          cache[key] = bytes;
        default:
          throw FormatException(
            '${entry['key']}: ${entry['error'] ?? 'Некорректная иконка Lua'}',
          );
      }
    }
    if (batch.any((key) => !cache.containsKey(key))) {
      throw const FormatException('Lua вернул не все иконки');
    }
  }
}
