enum AppCommand {
  undo,
  redo,
  newBuild,
  importXml,
  exportXml,
  zoomIn,
  zoomOut,
  resetZoom,
}

typedef KeyBinding = ({int key, bool control, bool alt, bool shift, bool meta});

class WorkspacePreferences {
  WorkspacePreferences({
    this.sidebarWidth = 198,
    this.expandedWidth = 198,
    Map<AppCommand, KeyBinding?> shortcuts = const {},
  }) : shortcuts = Map.unmodifiable(shortcuts);

  final double sidebarWidth;
  final double expandedWidth;
  final Map<AppCommand, KeyBinding?> shortcuts;

  WorkspacePreferences copyWith({
    double? sidebarWidth,
    double? expandedWidth,
    Map<AppCommand, KeyBinding?>? shortcuts,
  }) => WorkspacePreferences(
    sidebarWidth: sidebarWidth ?? this.sidebarWidth,
    expandedWidth: expandedWidth ?? this.expandedWidth,
    shortcuts: shortcuts ?? this.shortcuts,
  );
}

double settledSidebarWidth(double width) =>
    width < 140 ? 78 : width.clamp(160, 300);
