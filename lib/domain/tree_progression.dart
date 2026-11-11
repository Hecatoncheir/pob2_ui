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
    int level,
    Iterable<int> nodes, {
    String title = '',
    String note = '',
    String? allocation,
    String? skills,
    String? equipment,
    bool completed = false,
    Iterable<ProgressionTask> tasks = const [],
  }) : this._(
         level,
         nodes,
         title,
         note,
         allocation,
         skills,
         equipment,
         completed,
         tasks,
         Object(),
       );

  TreeProgressionStep._(
    this.level,
    Iterable<int> nodes,
    this.title,
    this.note,
    this.allocation,
    this.skills,
    this.equipment,
    this.completed,
    Iterable<ProgressionTask> tasks,
    this.identity,
  ) : nodes = Set.unmodifiable(nodes),
      tasks = List.unmodifiable(tasks);

  final int level;
  final Set<int> nodes;
  final String title;
  final String note;
  final String? allocation;
  final String? skills;
  final String? equipment;
  final bool completed;
  final List<ProgressionTask> tasks;
  final Object identity;

  Set<ProgressionPart> get parts => {
    ProgressionPart.tree,
    if (skills != null) ProgressionPart.skills,
    if (equipment != null) ProgressionPart.equipment,
  };

  TreeProgressionDetails get details =>
      (level: level, title: title, note: note);

  TreeProgressionStep withDetails(TreeProgressionDetails details) =>
      withProgress(details: details);

  TreeProgressionStep withProgress({
    TreeProgressionDetails? details,
    bool? completed,
    Iterable<ProgressionTask>? tasks,
  }) => TreeProgressionStep._(
    details?.level ?? level,
    nodes,
    details?.title ?? title,
    details?.note ?? note,
    allocation,
    skills,
    equipment,
    completed ?? this.completed,
    tasks ?? this.tasks,
    identity,
  );

  TreeProgressionStep withPartsFrom(
    TreeProgressionStep current,
    Set<ProgressionPart> parts,
  ) {
    final tree = parts.contains(ProgressionPart.tree) ? current : this;
    return TreeProgressionStep._(
      tree.level,
      tree.nodes,
      title,
      note,
      tree.allocation,
      parts.contains(ProgressionPart.skills) ? current.skills : skills,
      parts.contains(ProgressionPart.equipment) ? current.equipment : equipment,
      completed,
      tasks,
      identity,
    );
  }
}

enum ProgressionPart { tree, skills, equipment }

void verifyProgressionTree(
  TreeProgressionStep step,
  int level,
  Set<int> nodes,
) {
  if (level != step.level ||
      nodes.length != step.nodes.length ||
      !nodes.containsAll(step.nodes)) {
    throw const FormatException('Lua не смог применить этот этап');
  }
}

bool isProgressionNode(String kind) =>
    kind != 'ClassStart' && kind != 'AscendClassStart';

typedef TreeProgressionDetails = ({int level, String title, String note});
typedef ProgressionTask = ({String text, bool done});

typedef TreeProgressionChange = ({Set<int> added, Set<int> removed});

TreeProgressionChange treeProgressionChange(
  List<TreeProgressionStep> steps,
  int index,
) {
  final before = index == 0 ? const <int>{} : steps[index - 1].nodes;
  final after = steps[index].nodes;
  return (added: after.difference(before), removed: before.difference(after));
}
