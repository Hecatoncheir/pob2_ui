typedef TreeProgressionKey = ({
  String folder,
  String build,
  String version,
  String characterClass,
});

class TreeProgressionStep {
  TreeProgressionStep(this.level, Iterable<int> nodes)
    : nodes = Set.unmodifiable(nodes);

  final int level;
  final Set<int> nodes;
}

typedef TreeProgressionChange = ({Set<int> added, Set<int> removed});

TreeProgressionChange treeProgressionChange(
  List<TreeProgressionStep> steps,
  int index,
) {
  final before = index == 0 ? const <int>{} : steps[index - 1].nodes;
  final after = steps[index].nodes;
  return (added: after.difference(before), removed: before.difference(after));
}
