#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef BundleDir
  #error BundleDir is required
#endif
#ifndef LauncherFile
  #error LauncherFile is required
#endif
#ifndef OutputDir
  #error OutputDir is required
#endif

[Setup]
AppId={{6A802B21-261C-4CDE-A626-D09BDD728029}
AppName=PoB II
AppVersion={#AppVersion}
AppPublisher=Hecatoncheir
AppPublisherURL=https://github.com/Hecatoncheir/pob2_ui
DefaultDirName={localappdata}\Programs\PoB II
DefaultGroupName=PoB II
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=pob2-ui-{#AppVersion}-windows-x64-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
CloseApplications=yes
RestartApplications=no
UninstallDisplayIcon={app}\versions\{#AppVersion}\pob2_ui.exe
SetupIconFile=..\windows\runner\resources\app_icon.ico

[Languages]
Name: russian; MessagesFile: compiler:Languages\Russian.isl
Name: english; MessagesFile: compiler:Default.isl

[Files]
Source: "{#BundleDir}\*"; DestDir: "{app}\versions\{#AppVersion}"; Flags: recursesubdirs createallsubdirs onlyifdoesntexist
Source: "{#LauncherFile}"; DestDir: "{app}"; DestName: "pob2_ui.exe"; Flags: ignoreversion
Source: "windows-marker.json"; DestDir: "{app}"; DestName: "pob2-install.json"; Flags: ignoreversion

[Icons]
Name: "{group}\PoB II"; Filename: "{app}\pob2_ui.exe"; WorkingDir: "{app}"; IconFilename: "{app}\versions\{#AppVersion}\pob2_ui.exe"
Name: "{userdesktop}\PoB II"; Filename: "{app}\pob2_ui.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: desktopicon; Description: "Создать ярлык на рабочем столе"; Flags: unchecked

[Run]
Filename: "{app}\pob2_ui.exe"; Description: "Открыть PoB II"; Flags: nowait postinstall skipifsilent
Filename: "{app}\pob2_ui.exe"; Flags: nowait skipifnotsilent; Check: WantsRelaunch

[Code]
function WantsRelaunch: Boolean;
var I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), '/RELAUNCH') = 0 then Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Temporary, Target: String;
begin
  if CurStep = ssPostInstall then begin
    Temporary := ExpandConstant('{app}\pending-version.tmp');
    Target := ExpandConstant('{app}\pending-version');
    if not SaveStringToFile(Temporary, '{#AppVersion}', False) then
      RaiseException('Не удалось подготовить новую версию');
    if FileExists(Target) then DeleteFile(Target);
    if not RenameFile(Temporary, Target) then
      RaiseException('Не удалось выбрать новую версию');
  end;
end;
