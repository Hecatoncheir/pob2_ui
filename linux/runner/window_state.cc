#include "window_state.h"

namespace {
struct WindowState {
  gint x = 10, y = 10, width = 1280, height = 720;
  gboolean maximized = FALSE;
};

gchar* state_path() {
  const gchar* explicit_root = g_getenv("POB2_UI_HOME");
  g_autofree gchar* root = explicit_root ? g_strdup(explicit_root)
      : g_build_filename(g_get_user_data_dir(), "pob2_ui", nullptr);
  g_mkdir_with_parents(root, 0700);
  return g_build_filename(root, "window-state.ini", nullptr);
}

gboolean configure(GtkWidget* widget, GdkEventConfigure* event, WindowState* state) {
  auto* window = gtk_widget_get_window(widget);
  if (!window || (gdk_window_get_state(window) & GDK_WINDOW_STATE_MAXIMIZED)) return FALSE;
  state->x = event->x;
  state->y = event->y;
  state->width = event->width;
  state->height = event->height;
  return FALSE;
}

gboolean state_changed(GtkWidget*, GdkEventWindowState* event, WindowState* state) {
  state->maximized = (event->new_window_state & GDK_WINDOW_STATE_MAXIMIZED) != 0;
  return FALSE;
}

gboolean save(GtkWidget*, GdkEvent*, WindowState* state) {
  g_autoptr(GKeyFile) file = g_key_file_new();
  g_key_file_set_integer(file, "window", "x", state->x);
  g_key_file_set_integer(file, "window", "y", state->y);
  g_key_file_set_integer(file, "window", "width", state->width);
  g_key_file_set_integer(file, "window", "height", state->height);
  g_key_file_set_boolean(file, "window", "maximized", state->maximized);
  gsize size = 0;
  g_autofree gchar* data = g_key_file_to_data(file, &size, nullptr);
  g_autofree gchar* path = state_path();
  g_file_set_contents(path, data, size, nullptr);
  return FALSE;
}

void keep_visible(GtkWindow* window, WindowState* state) {
  auto* display = gtk_widget_get_display(GTK_WIDGET(window));
  auto* monitor = gdk_display_get_monitor_at_point(display, state->x, state->y);
  if (!monitor) return;
  GdkRectangle area;
  gdk_monitor_get_workarea(monitor, &area);
  state->width = CLAMP(state->width, 360, MAX(360, area.width));
  state->height = CLAMP(state->height, 300, MAX(300, area.height));
  state->x = CLAMP(state->x, area.x, area.x + MAX(0, area.width - state->width));
  state->y = CLAMP(state->y, area.y, area.y + MAX(0, area.height - state->height));
}
}

void restore_window_state(GtkWindow* window) {
  auto* state = new WindowState();
  g_autoptr(GKeyFile) file = g_key_file_new();
  g_autofree gchar* path = state_path();
  if (g_key_file_load_from_file(file, path, G_KEY_FILE_NONE, nullptr)) {
    state->x = g_key_file_get_integer(file, "window", "x", nullptr);
    state->y = g_key_file_get_integer(file, "window", "y", nullptr);
    gint width = g_key_file_get_integer(file, "window", "width", nullptr);
    gint height = g_key_file_get_integer(file, "window", "height", nullptr);
    if (width >= 360 && height >= 300 && width <= 32768 && height <= 32768) {
      state->width = width;
      state->height = height;
      state->maximized = g_key_file_get_boolean(file, "window", "maximized", nullptr);
    }
  }
  keep_visible(window, state);
  gtk_window_set_default_size(window, state->width, state->height);
  gtk_window_move(window, state->x, state->y);
  if (state->maximized) gtk_window_maximize(window);
  g_object_set_data_full(G_OBJECT(window), "pob-window-state", state,
      [](gpointer data) { delete static_cast<WindowState*>(data); });
  g_signal_connect(window, "configure-event", G_CALLBACK(configure), state);
  g_signal_connect(window, "window-state-event", G_CALLBACK(state_changed), state);
  g_signal_connect(window, "delete-event", G_CALLBACK(save), state);
}
