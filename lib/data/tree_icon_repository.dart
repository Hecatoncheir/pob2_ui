import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../domain/build_report.dart';
import '../domain/original_tree_scene.dart';
import '../domain/tree_geometry.dart';
import 'mcp_client.dart';

class TreeIconRepository {
  Future<Map<String, Uint8List>> overlay(
    TreeGeometry tree,
    McpClient engine,
    String source,
  ) async {
    final loaded = await _loadArtwork(tree, engine, source, null);
    if (loaded.iconError case final error?) throw StateError(error);
    return loaded.icons;
  }

  TreeIconRepository({this.root, this.readShared});
  final Directory? root;
  final Future<Uint8List?> Function(TreeTextureReference)? readShared;
  final _cache = <(String, String), Map<String, Uint8List>>{};

  void clear() => _cache.clear();

  Future<TreeGeometry> load(
    TreeGeometry tree,
    McpClient engine,
    String source, {
    bool Function()? canContinue,
  }) async {
    if (tree.original != null)
      return _loadArtwork(tree, engine, source, canContinue);
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
      final complete = await _loadMissing(missing, cache, engine, canContinue);
      return complete ? tree.withIcons(cache, null) : tree;
    } catch (error) {
      return tree.withIcons(cache, 'Часть иконок недоступна: $error');
    }
  }

  Future<TreeGeometry> _loadArtwork(
    TreeGeometry tree,
    McpClient engine,
    String source,
    bool Function()? canContinue,
  ) {
    final scene = tree.original!;
    final reader = readShared;
    if (scene.assetId != null && reader != null) {
      return _loadEngineArtwork(tree, scene, reader, canContinue);
    }
    return _loadScene(tree, engine, source, canContinue);
  }

  Future<TreeGeometry> _loadEngineArtwork(
    TreeGeometry tree,
    OriginalTreeScene scene,
    Future<Uint8List?> Function(TreeTextureReference) reader,
    bool Function()? canContinue,
  ) async {
    final references = {
      for (final command in scene.commands)
        if (command.reference case final reference?) command.texture: reference,
    };
    final cache = _cache.putIfAbsent((scene.assetId!, tree.version), () => {});
    final missing =
        references.entries
            .where((entry) => !cache.containsKey(entry.key))
            .toList()
          ..sort((a, b) => a.value.file.compareTo(b.value.file));
    try {
      for (final entry in missing) {
        final file = _file(scene.assetId!, tree.version, entry.key);
        final bytes = await _cachedTexture(file, canContinue, () async {
          final texture = await reader(entry.value);
          if (texture == null || !_validPng(texture)) {
            throw const FormatException(
              'Некорректная текстура готового дерева',
            );
          }
          return texture;
        });
        if (bytes == null) return tree;
        cache[entry.key] = bytes;
      }
      return _sceneResult(tree, references.keys.toSet(), cache);
    } catch (error) {
      return _sceneResult(tree, references.keys.toSet(), cache, '$error');
    }
  }

  Future<TreeGeometry> _loadScene(
    TreeGeometry tree,
    McpClient engine,
    String source,
    bool Function()? canContinue,
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
    try {
      for (final token in keys.where((key) => !cache.containsKey(key))) {
        if (canContinue?.call() == false) return tree;
        final bytes = await _texture(
          engine,
          token,
          source,
          tree.version,
          canContinue,
        );
        if (bytes == null) return tree;
        cache[token] = bytes;
      }
      return _sceneResult(tree, keys, cache);
    } catch (error) {
      return _sceneResult(
        tree,
        keys,
        cache,
        'Готовая сцена загружена не полностью: $error',
      );
    }
  }

  TreeGeometry _sceneResult(
    TreeGeometry tree,
    Set<String> keys,
    Map<String, Uint8List> cache, [
    String? error,
  ]) => tree.withIcons({
    for (final key in keys)
      if (cache[key] case final bytes?) key: bytes,
  }, error);

  File? _file(String source, String version, String token) {
    if (root == null) return null;
    if (!RegExp(r'^(?:[a-f0-9]{64}|[a-f0-9]{40}-[a-f0-9]{40})$')
            .hasMatch(source) ||
        !RegExp(r'^[0-9_]{1,32}$').hasMatch(version) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Некорректный ключ кеша дерева');
    }
    return File.fromUri(root!.uri.resolve('$source/$version/$token.png'));
  }

  Future<Uint8List?> _texture(
    McpClient engine,
    String token,
    String source,
    String version,
    bool Function()? canContinue,
  ) => _cachedTexture(_file(source, version, token), canContinue, () async {
    return _sceneImage(
      await engine.call('pob_tree_textures', {'token': token}),
      token,
    );
  });

  Future<Uint8List?> _cachedTexture(
    File? file,
    bool Function()? canContinue,
    Future<Uint8List> Function() read,
  ) async {
    final stored = await _readCache(file);
    if (stored != null) return stored;
    if (canContinue?.call() == false) return null;
    final bytes = await read();
    if (file != null &&
        bytes.length <= 4 * 1024 * 1024 &&
        canContinue?.call() != false) {
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

  Uint8List _sceneImage(JsonMap json, String token) => switch (json) {
    {'token': final String key, 'png': final String png}
        when key == token && png.length < 6 * 1024 * 1024 =>
      base64Decode(png),
    _ => throw const FormatException('Некорректная текстура готового дерева'),
  };

  Future<bool> _loadMissing(
    List<String> keys,
    Map<String, Uint8List> cache,
    McpClient engine,
    bool Function()? canContinue,
  ) async {
    for (var start = 0; start < keys.length; start += 32) {
      if (canContinue?.call() == false) return false;
      final batch = keys.skip(start).take(32).toList();
      final result = await engine.call('pob_tree_icons', {'icons': batch});
      _read(result, batch, cache);
    }
    return true;
  }

  void _read(JsonMap result, List<String> batch, Map<String, Uint8List> cache) {
    final entries = jsonRows(result['icons']);
    for (final entry in entries) {
      final (key, bytes) = _decodeIcon(entry, batch);
      cache[key] = bytes;
    }
    if (batch.any((key) => !cache.containsKey(key))) {
      throw const FormatException('Lua вернул не все иконки');
    }
  }

  (String, Uint8List) _decodeIcon(JsonMap entry, List<String> batch) {
    if (entry case {'key': final String key, 'png': final String png}
        when batch.contains(key)) {
      final bytes = base64Decode(png);
      if (bytes.length > 1024 * 1024)
        throw const FormatException('Слишком большая иконка');
      return (key, bytes);
    }
    throw FormatException(
      '${entry['key']}: ${entry['error'] ?? 'Некорректная иконка Lua'}',
    );
  }
}
