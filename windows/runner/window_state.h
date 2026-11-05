#ifndef RUNNER_WINDOW_STATE_H_
#define RUNNER_WINDOW_STATE_H_
#include <windows.h>

int RestoreWindowState(HWND window);
void SaveWindowState(HWND window);
#endif
