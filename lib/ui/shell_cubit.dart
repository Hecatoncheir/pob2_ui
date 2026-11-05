import 'package:flutter_bloc/flutter_bloc.dart';

enum AppPage { library, workspace, components }

enum WorkshopTab { tree, items, skills, conditions, calculations }

typedef ShellState = ({
  AppPage page,
  WorkshopTab tab,
  bool motion,
  List<String> pins,
});

class ShellCubit extends Cubit<ShellState> {
  ShellCubit()
    : super((
        page: AppPage.workspace,
        tab: WorkshopTab.tree,
        motion: true,
        pins: const ['Life', 'EnergyShield', 'Mana', 'Spirit'],
      ));
  void page(AppPage page) => emit((
    page: page,
    tab: state.tab,
    motion: state.motion,
    pins: state.pins,
  ));
  void tab(WorkshopTab tab) => emit((
    page: state.page,
    tab: tab,
    motion: state.motion,
    pins: state.pins,
  ));
  void motion(bool value) =>
      emit((page: state.page, tab: state.tab, motion: value, pins: state.pins));
  void pin(String key) {
    final pins = [...state.pins];
    if (pins.contains(key)) {
      if (pins.length > 1) pins.remove(key);
    } else if (pins.length < 6) {
      pins.add(key);
    }
    emit((
      page: state.page,
      tab: state.tab,
      motion: state.motion,
      pins: List.unmodifiable(pins),
    ));
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
