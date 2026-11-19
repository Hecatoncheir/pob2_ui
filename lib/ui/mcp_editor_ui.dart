import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_editor_gateway.dart';
import '../domain/app_language.dart';
import '../domain/appearance.dart';
import '../domain/build_report.dart';
import 'appearance_bloc.dart';
import 'interface_scale_bloc.dart';
import 'language_bloc.dart';
import 'shell_bloc.dart';

class McpEditorUi {
  McpEditorUi(this.context);
  final BuildContext context;

  JsonMap status() {
    final shell = context.read<ShellBloc>().state;
    return {
      'page': shell.page.name,
      'tab': shell.tab.name,
      'motion': shell.motion,
      'pins': shell.pins,
      'theme': context.read<AppearanceBloc>().state.theme.name,
      'language': context.read<LanguageBloc>().state.language.code,
      'scale': context.read<InterfaceScaleBloc>().state.percent / 100,
    };
  }

  Future<JsonMap> call(JsonMap args) async {
    switch (args['action']) {
      case 'navigate':
        await _navigate(args);
      case 'preferences':
        await _preferences(args);
      default:
        throw const McpEditorFault(
          'INVALID_ARGUMENTS',
          'Неизвестное действие интерфейса.',
        );
    }
    return status();
  }

  Future<void> _navigate(JsonMap args) async {
    final shell = context.read<ShellBloc>();
    if (args['page'] case final String name) {
      final page = AppPage.values.byName(name);
      if (shell.state.page != page) {
        final changed = shell.stream.firstWhere((s) => s.page == page);
        shell.add(PageSelected(page));
        await changed;
      }
    }
    if (args['tab'] case final String name) {
      final tab = WorkshopTab.values.byName(name);
      if (shell.state.tab != tab) {
        final changed = shell.stream.firstWhere((s) => s.tab == tab);
        shell.add(WorkshopTabSelected(tab));
        await changed;
      }
    }
  }

  Future<void> _preferences(JsonMap args) async {
    if (args['theme'] case final String name) {
      final bloc = context.read<AppearanceBloc>();
      final theme = AppTheme.values.byName(name);
      if (bloc.state.theme != theme) {
        final changed = bloc.stream.firstWhere((s) => s.theme == theme);
        bloc.add(ThemeSelected(theme));
        await changed;
        await bloc.pendingSave;
        _checkPreference(bloc.state.error);
      }
    }
    await _language(args);
    await _scale(args);
    await _motion(args);
  }

  Future<void> _language(JsonMap args) async {
    if (args['language'] case final String code) {
      final bloc = context.read<LanguageBloc>();
      final language = AppLanguage.values
          .where((e) => e.code == code)
          .firstOrNull;
      if (language == null)
        throw const McpEditorFault('INVALID_ARGUMENTS', 'Неизвестный язык.');
      if (bloc.state.language == language) return;
      final changed = bloc.stream.firstWhere(
        (s) => s.language == language && !s.loading,
      );
      bloc.add(LanguageSelected(language));
      await changed;
      await bloc.pendingSave;
      if (bloc.state.error case final error?)
        throw McpEditorFault('PREFERENCE_FAILED', error);
    }
  }

  Future<void> _scale(JsonMap args) async {
    if (args['scale'] case final num scale) {
      if (scale < 0.75 || scale > 2)
        throw const McpEditorFault(
          'INVALID_ARGUMENTS',
          'Масштаб должен быть от 0.75 до 2.',
        );
      final bloc = context.read<InterfaceScaleBloc>();
      final target = ((scale * 100 / 5).round() * 5).clamp(75, 200);
      if (bloc.state.percent == target) return;
      final changed = bloc.stream.firstWhere((s) => s.percent == target);
      bloc.add(InterfaceScaleSet(target));
      await changed;
      await bloc.pendingSave;
      _checkPreference(bloc.state.error);
    }
  }

  void _checkPreference(String? error) {
    if (error != null) throw McpEditorFault('PREFERENCE_FAILED', error);
  }

  Future<void> _motion(JsonMap args) async {
    if (args['motion'] case final bool enabled) {
      final shell = context.read<ShellBloc>();
      if (shell.state.motion == enabled) return;
      final changed = shell.stream.firstWhere((s) => s.motion == enabled);
      shell.add(ShellMotionChanged(enabled));
      await changed;
    }
  }
}
