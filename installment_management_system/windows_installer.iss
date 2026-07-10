[Setup]
; App details
AppName=Installment Management System
AppVersion=1.0.0
AppPublisher=Shubham
AppPublisherURL=https://example.com/
DefaultDirName={autopf}\Installment Management System
DisableProgramGroupPage=yes
; Output installer details
OutputDir=Output
OutputBaseFilename=Install_InstallmentSystem_v1
Compression=lzma
SolidCompression=yes
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\installment_management_system.exe

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Copy the main .exe and all other files in the Release folder
Source: "build\windows\x64\runner\Release\installment_management_system.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Exclude the msix and other unneeded files if any
; Note: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Installment Management System"; Filename: "{app}\installment_management_system.exe"
Name: "{autodesktop}\Installment Management System"; Filename: "{app}\installment_management_system.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\installment_management_system.exe"; Description: "{cm:LaunchProgram,Installment Management System}"; Flags: nowait postinstall skipifsilent
