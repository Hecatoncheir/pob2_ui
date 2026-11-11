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
    this.skills,
    this.equipment,
  }) : nodes = Set.unmodifiable(nodes);

  final int level;
  final Set<int> nodes;
  final String title;
  final String note;
  final String? allocation;
  final String? skills;
  final String? equipment;

  Set<ProgressionPart> get parts => {
    ProgressionPart.tree,
    if (skills != null) ProgressionPart.skills,
    if (equipment != null) ProgressionPart.equipment,
  };

  TreeProgressionDetails get details =>
      (level: level, title: title, note: note);

  TreeProgressionStep withDetails(TreeProgressionDetails details) =>
      TreeProgressionStep(
        details.level,
        nodes,
        title: details.title,
        note: details.note,
        allocation: allocation,
        skills: skills,
        equipment: equipment,
      );
}

enum ProgressionPart { tree, skills, equipment }

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
