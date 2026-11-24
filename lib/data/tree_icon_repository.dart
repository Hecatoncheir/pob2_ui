import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../domain/build_report.dart';
import '../domain/original_tree_scene.dart';
import '../domain/tree_geometry.dart';
import 'workbench_client.dart';

typedef _Texture = ({String key, TreeTextureReference reference, File? file});

class TreeIconRepository {
  Future<Map<String, Uint8List>> overlay(
    TreeGeometry tree,
    WorkbenchClient engine,
    String source,
  ) async {
    final loaded = await _loadArtwork(tree, engine, source, null);
    if (loaded.iconError case final error?) throw StateError(error);
    return loaded.icons;
  }

  TreeIconRepository({this.root, this.readShared, this.readSharedBatch});
  final Directory? root;
  final Stream<Uint8List>? Function(List<TreeTextureReference>)?
  readSharedBatch;
  final Future<Uint8List?> Function(TreeTextureReference)? readShared;
  final _cache = <(String, String), Map<String, Uint8List>>{};

  void clear() => _cache.clear();

  Future<TreeGeometry> load(
    TreeGeometry tree,
    WorkbenchClient engine,
    String source, {
    bool Function()? canContinue,
    Rectangle<double>? viewport,
    void Function(TreeGeometry)? onVisible,
  }) async {
    if (tree.original != null) {
      return _loadArtwork(
        tree,
        engine,
        source,
        canContinue,
        viewport: viewport,
        onVisible: onVisible,
      );
    }
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
    WorkbenchClient engine,
    String source,
    bool Function()? canContinue, {
    Rectangle<double>? viewport,
    void Function(TreeGeometry)? onVisible,
  }) {
    final scene = tree.original!;
    final reader = readShared;
    if (scene.assetId != null && reader != null) {
      return _loadEngineArtwork(
        tree,
        reader,
        canContinue,
        viewport: viewport,
        onVisible: onVisible,
      );
    }
    return _loadScene(tree, engine, source, canContinue);
  }

  Future<TreeGeometry> _loadEngineArtwork(
    TreeGeometry tree,
    Future<Uint8List?> Function(TreeTextureReference) reader,
    bool Function()? canContinue, {
    Rectangle<double>? viewport,
    void Function(TreeGeometry)? onVisible,
  }) async {
    final scene = tree.original!;
    final references = {
      for (final command in scene.commands)
        if (command.reference case final reference?) command.texture: reference,
    };
    final cache = _cache.putIfAbsent((scene.assetId!, tree.version), () => {});
    final visible = _visibleTextures(scene, viewport);
    final pendingVisible = visible.difference(cache.keys.toSet());
    var published = false;
    void notifyVisible() {
      if (published ||
          visible.isEmpty ||
          pendingVisible.isNotEmpty ||
          references.keys.every(cache.containsKey))
        return;
      published = true;
      onVisible?.call(
        _sceneResult(tree, references.keys.toSet(), cache, null, true),
      );
    }

    try {
      final groups = _textureGroups(tree, references, cache, visible);
      notifyVisible();
      for (final group in groups) {
        final completed = await _loadTextureGroup(
          group,
          cache,
          reader,
          canContinue,
          (key) {
            pendingVisible.remove(key);
            notifyVisible();
          },
        );
        if (!completed) return tree;
      }
      return _sceneResult(tree, references.keys.toSet(), cache);
    } catch (error) {
      return _sceneResult(tree, references.keys.toSet(), cache, '$error', true);
    }
  }

  Set<String> _visibleTextures(
    OriginalTreeScene scene,
    Rectangle<double>? viewport,
  ) {
    if (viewport == null) return {};
    final area = Rectangle(
      scene.offsetX + viewport.left * scene.scale,
      scene.offsetY + viewport.top * scene.scale,
      viewport.width * scene.scale,
      viewport.height * scene.scale,
    );
    return {
      for (final command in scene.commands)
        if (command.reference != null && _overlaps(command.positions, area))
          command.texture,
    };
  }

  bool _overlaps(List<double> p, Rectangle<double> area) {
    final left = min(min(p[0], p[2]), min(p[4], p[6]));
    final right = max(max(p[0], p[2]), max(p[4], p[6]));
    final top = min(min(p[1], p[3]), min(p[5], p[7]));
    final bottom = max(max(p[1], p[3]), max(p[5], p[7]));
    return left <= area.right &&
        right >= area.left &&
        top <= area.bottom &&
        bottom >= area.top;
  }

  Iterable<List<_Texture>> _textureGroups(
    TreeGeometry tree,
    Map<String, TreeTextureReference> references,
    Map<String, Uint8List> cache,
    Set<String> visible,
  ) sync* {
    final groups = <String, List<_Texture>>{};
    final keys = {...visible, ...references.keys};
    for (final key in keys.where((key) => !cache.containsKey(key))) {
      final reference = references[key]!;
      (groups[reference.file] ??= []).add((
        key: key,
        reference: reference,
        file: _file(tree.original!.assetId!, tree.version, key),
      ));
    }
    for (final group in groups.values) {
      for (var start = 0; start < group.length; start += 256) {
        yield group.sublist(start, min(start + 256, group.length));
      }
    }
  }

  Future<bool> _loadTextureGroup(
    List<_Texture> group,
    Map<String, Uint8List> cache,
    Future<Uint8List?> Function(TreeTextureReference) reader,
    bool Function()? canContinue,
    void Function(String) ready,
  ) async {
    final missing = <_Texture>[];
    void accept(_Texture texture, Uint8List bytes) {
      cache[texture.key] = bytes;
      ready(texture.key);
    }

    for (final texture in group) {
      if (canContinue?.call() == false) return false;
      final stored = await _readCache(texture.file);
      if (stored == null) {
        missing.add(texture);
      } else {
        accept(texture, stored);
      }
    }
    if (missing.isEmpty) return true;
    final references = missing.map((entry) => entry.reference).toList();
    final responses =
        readSharedBatch?.call(references) ??
        Stream.fromIterable(references).asyncMap<Uint8List?>(reader);
    return _readTextureGroup(missing, responses, accept, canContinue);
  }

  Future<bool> _readTextureGroup(
    List<_Texture> missing,
    Stream<Uint8List?> responses,
    void Function(_Texture, Uint8List) accept,
    bool Function()? canContinue,
  ) async {
    var index = 0;
    await for (final bytes in responses) {
      if (canContinue?.call() == false) return false;
      if (index >= missing.length || bytes == null || !_validPng(bytes)) {
        throw const FormatException('Некорректная текстура готового дерева');
      }
      final texture = missing[index++];
      accept(texture, bytes);
      await _saveCache(texture.file, bytes);
    }
    if (index != missing.length) {
      throw const FormatException('Движок вернул не все слои атласа');
    }
    return true;
  }

  Future<TreeGeometry> _loadScene(
    TreeGeometry tree,
    WorkbenchClient engine,
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
    bool partial = false,
  ]) => tree.withIcons(
    {
      for (final key in keys)
        if (cache[key] case final bytes?) key: bytes,
    },
    error,
    partial: partial,
  );

  File? _file(String source, String version, String token) {
    if (root == null || source.isEmpty) return null;
    if (!RegExp(r'^(?:[a-f0-9]{64}|[a-f0-9]{40}(?:-[a-f0-9]{40})?)$')
            .hasMatch(source) ||
        !RegExp(r'^[0-9_]{1,32}$').hasMatch(version) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Некорректный ключ кеша дерева');
    }
    return File.fromUri(root!.uri.resolve('$source/$version/$token.png'));
  }

  Future<Uint8List?> _texture(
    WorkbenchClient engine,
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
    if (canContinue?.call() != false) await _saveCache(file, bytes);
    return bytes;
  }

  Future<void> _saveCache(File? file, Uint8List bytes) async {
    if (file == null || bytes.length > 4 * 1024 * 1024) return;
    await file.parent.create(recursive: true);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    await temporary.writeAsBytes(bytes);
    await temporary.rename(file.path);
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
    WorkbenchClient engine,
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
