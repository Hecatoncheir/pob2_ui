typedef TreeProgressionKey = ({
  String folder,
  String build,
  String version,
  String characterClass,
});

typedef TreeProgressionTransfer = ({
  String version,
  String characterClass,
  List<TreeProgressionStep> steps,
});

class TreeProgressionStep {
  TreeProgressionStep(
    this.level,
    Iterable<int> nodes, {
    this.title = '',
    this.note = '',
    this.allocation,
  }) : nodes = Set.unmodifiable(nodes);

  final int level;
  final Set<int> nodes;
  final String title;
  final String note;
  final String? allocation;

  TreeProgressionDetails get details =>
      (level: level, title: title, note: note);
}

bool isProgressionNode(String kind) =>
    kind != 'ClassStart' && kind != 'AscendClassStart';

typedef TreeProgressionDetails = ({int level, String title, String note});

typedef TreeProgressionChange = ({Set<int> added, Set<int> removed});

TreeProgressionChange treeProgressionChange(
  List<TreeProgressionStep> steps,
  int index,
) {
  final before = index == 0 ? const <int>{} : steps[index - 1].nodes;
  final after = steps[index].nodes;
  return (added: after.difference(before), removed: before.difference(after));
}
