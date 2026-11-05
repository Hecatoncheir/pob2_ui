import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_client.dart';
import '../domain/build_report.dart';
import '../domain/node_power.dart';
import '../domain/original_tree_scene.dart';

class NodePowerCubit extends Cubit<NodePowerState> {
  NodePowerCubit(this.engine, this.loadImages)
    : super((
        metrics: const [],
        options: (stat: 'Evasion', distance: 10, allocation: 'unallocated'),
        progress: null,
        report: null,
        error: null,
      ));
  final McpClient engine;
  final Future<Map<String, Uint8List>> Function(OriginalTreeScene) loadImages;
  int _generation = 0;
  int? _job;

  void _publish({
    List<JsonMap>? metrics,
    NodePowerOptions? options,
    double? progress,
    NodePowerReport? report,
    String? error,
  }) {
    if (isClosed) return;
    emit((
      metrics: metrics ?? state.metrics,
      options: options ?? state.options,
      progress: progress,
      report: report,
      error: error,
    ));
  }

  Future<void> load() async {
    try {
      if (!engine.tools.contains('pob_node_power')) {
        throw StateError(
          'Для поиска по характеристике обновите MCP до 0.9.0 в разделе «Компоненты».',
        );
      }
      final metrics = jsonRows((await _call({'action': 'catalog'}))['entries']);
      if (metrics.isEmpty)
        throw const FormatException('Lua не вернул характеристики');
      final stat = metrics.any((metric) => metric['id'] == state.options.stat)
          ? state.options.stat
          : '${metrics.first['id']}';
      _publish(
        metrics: metrics,
        options: (
          stat: stat,
          distance: state.options.distance,
          allocation: state.options.allocation,
        ),
      );
    } catch (error) {
      _publish(error: '$error');
    }
  }

  Future<JsonMap> _call(JsonMap arguments) =>
      engine.call('pob_node_power', arguments);
  bool _current(int generation) => !isClosed && generation == _generation;

  Future<void> configure(NodePowerOptions options) async {
    final pending = cancel();
    _publish(options: options);
    await pending;
  }

  Future<void> calculate() async {
    final pending = cancel();
    final generation = ++_generation;
    final options = state.options;
    _publish(progress: 0);
    try {
      await pending;
      if (!_current(generation)) return;
      final start = await _call({
        'action': 'start',
        'stat': options.stat,
        if (options.distance != null) 'maxDistance': options.distance,
      });
      final job = start['job'] as int;
      if (!_current(generation)) {
        await _cancelJob(job);
        return;
      }
      _job = job;
      await _poll(job, generation, options);
    } catch (error) {
      if (_current(generation)) _publish(error: '$error');
    }
  }

  Future<void> _poll(int job, int generation, NodePowerOptions options) async {
    while (_current(generation)) {
      final result = await _call({
        'action': 'poll',
        'job': job,
        'allocation': options.allocation,
        'includeScene': true,
      });
      if (!_current(generation)) return;
      if (result['complete'] == true) {
        final scene = OriginalTreeScene.fromJson(jsonMap(result['scene']));
        final images = await loadImages(scene);
        if (_current(generation))
          _publish(report: NodePowerReport.fromJson(result, images));
        return;
      }
      _publish(progress: (result['progress'] as num).toDouble() / 100);
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<void> _cancelJob(int? job) async {
    if (job == null) return;
    try {
      await _call({'action': 'cancel', 'job': job});
    } catch (_) {
      /* Сессия могла уже закрыться или сменить сборку. */
    }
  }

  Future<void> cancel() async {
    _generation++;
    final job = _job;
    _job = null;
    _publish();
    await _cancelJob(job);
  }

  @override
  Future<void> close() async {
    _generation++;
    await _cancelJob(_job);
    return super.close();
  }
}
