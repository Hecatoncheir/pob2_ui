import 'package:flutter_bloc/flutter_bloc.dart';

enum AppPage { library, workspace, components }

enum WorkshopTab { tree, items, skills, conditions, calculations }

typedef ShellState = ({
  AppPage page,
  WorkshopTab tab,
  bool motion,
  List<String> pins,
});

sealed class ShellEvent {
  const ShellEvent();
}

final class PageSelected extends ShellEvent {
  const PageSelected(this.page);
  final AppPage page;
}

final class WorkshopTabSelected extends ShellEvent {
  const WorkshopTabSelected(this.tab);
  final WorkshopTab tab;
}

final class ShellMotionChanged extends ShellEvent {
  const ShellMotionChanged(this.enabled);
  final bool enabled;
}

final class StatisticPinToggled extends ShellEvent {
  const StatisticPinToggled(this.key);
  final String key;
}

class ShellBloc extends Bloc<ShellEvent, ShellState> {
  ShellBloc()
    : super((
        page: AppPage.workspace,
        tab: WorkshopTab.tree,
        motion: true,
        pins: const ['Life', 'EnergyShield', 'Mana', 'Spirit'],
      )) {
    on<ShellEvent>(_apply);
  }

  void _apply(ShellEvent event, Emitter<ShellState> emit) {
    final (:page, :tab, :motion, :pins) = state;
    emit(switch (event) {
      PageSelected(page: final next) => (
        page: next,
        tab: tab,
        motion: motion,
        pins: pins,
      ),
      WorkshopTabSelected(tab: final next) => (
        page: page,
        tab: next,
        motion: motion,
        pins: pins,
      ),
      ShellMotionChanged(:final enabled) => (
        page: page,
        tab: tab,
        motion: enabled,
        pins: pins,
      ),
      StatisticPinToggled(:final key) => (
        page: page,
        tab: tab,
        motion: motion,
        pins: _togglePin(pins, key),
      ),
    });
  }

  List<String> _togglePin(List<String> pins, String key) {
    if (pins.contains(key)) {
      if (pins.length == 1) return pins;
      return List.unmodifiable(pins.where((pin) => pin != key));
    }
    if (pins.length >= 6) return pins;
    return List.unmodifiable([...pins, key]);
  }
}

const pageLabels = {
  AppPage.library: 'Мои сборки',
  AppPage.workspace: 'Мастерская',
  AppPage.components: 'Компоненты',
};
const pageIcons = {
  AppPage.library: 'grid',
  AppPage.workspace: 'tree',
  AppPage.components: 'box',
};
const tabLabels = {
  WorkshopTab.tree: 'Дерево',
  WorkshopTab.items: 'Предметы',
  WorkshopTab.skills: 'Умения',
  WorkshopTab.conditions: 'Условия',
  WorkshopTab.calculations: 'Расчёты',
};
const tabIcons = {
  WorkshopTab.tree: 'tree',
  WorkshopTab.items: 'sword',
  WorkshopTab.skills: 'gem',
  WorkshopTab.conditions: 'flask',
  WorkshopTab.calculations: 'chart',
};
