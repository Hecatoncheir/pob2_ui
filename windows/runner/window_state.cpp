#include "window_state.h"

#include <filesystem>
#include <string>

namespace {
struct SavedWindow {
  DWORD version = 1;
  WINDOWPLACEMENT placement = {sizeof(WINDOWPLACEMENT)};
};

std::wstring Environment(const wchar_t* name) {
  DWORD length = GetEnvironmentVariableW(name, nullptr, 0);
  if (!length) return {};
  std::wstring value(length, L'\0');
  GetEnvironmentVariableW(name, value.data(), length);
  value.resize(length - 1);
  return value;
}

std::filesystem::path StatePath() {
  auto root = Environment(L"POB2_UI_HOME");
  if (root.empty()) {
    root = Environment(L"LOCALAPPDATA");
    if (root.empty()) return {};
    root += L"\\pob2_ui";
  }
  return std::filesystem::path(root) / L"window-state.bin";
}

bool Valid(const SavedWindow& state) {
  const RECT& rect = state.placement.rcNormalPosition;
  const long long width = static_cast<long long>(rect.right) - rect.left;
  const long long height = static_cast<long long>(rect.bottom) - rect.top;
  return state.version == 1 && state.placement.length == sizeof(WINDOWPLACEMENT)
      && width >= 360 && height >= 300 && width <= 32768 && height <= 32768;
}
}

int RestoreWindowState(HWND window) {
  auto path = StatePath();
  if (path.empty()) return SW_SHOWNORMAL;
  HANDLE file = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ,
      nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return SW_SHOWNORMAL;
  SavedWindow state;
  DWORD count = 0;
  bool loaded = ReadFile(file, &state, sizeof(state), &count, nullptr) != 0;
  CloseHandle(file);
  if (!loaded || count != sizeof(state) || !Valid(state)) return SW_SHOWNORMAL;
  int mode = state.placement.showCmd == SW_SHOWMAXIMIZED ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  state.placement.flags = 0;
  state.placement.showCmd = SW_HIDE;
  // SetWindowPlacement возвращает окно на доступный монитор при смене экранов.
  SetWindowPlacement(window, &state.placement);
  return mode;
}

void SaveWindowState(HWND window) {
  SavedWindow state;
  if (!GetWindowPlacement(window, &state.placement)) return;
  bool maximized = IsZoomed(window) ||
      (IsIconic(window) && (state.placement.flags & WPF_RESTORETOMAXIMIZED));
  state.placement.showCmd = maximized ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  if (!Valid(state)) return;
  auto path = StatePath();
  if (path.empty()) return;
  std::error_code error;
  std::filesystem::create_directories(path.parent_path(), error);
  if (error) return;
  auto temporary = path.wstring() + L"." + std::to_wstring(GetCurrentProcessId()) + L".tmp";
  HANDLE file = CreateFileW(temporary.c_str(), GENERIC_WRITE, 0, nullptr,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return;
  DWORD count = 0;
  bool written = WriteFile(file, &state, sizeof(state), &count, nullptr) != 0;
  FlushFileBuffers(file);
  CloseHandle(file);
  if (written && count == sizeof(state)) {
    MoveFileExW(temporary.c_str(), path.c_str(), MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH);
  } else {
    DeleteFileW(temporary.c_str());
  }
}
