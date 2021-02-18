[Setup]
AppName=HAB PADD
AppVersion=1.5
WizardStyle=modern
DefaultDirName=c:\HAB\PADD
DefaultGroupName=HAB
UninstallDisplayIcon={app}\HABPADD.exe
Compression=lzma2
SolidCompression=yes
OutputBaseFilename=HABPADDInstaller

[Files]
Source: "HABPADD.exe"; DestDir: "{app}"; Flags: replacesameversion restartreplace
Source: "..\Images\*"; DestDir: "{app}\Images"; Flags: onlyifdoesntexist
Source: "..\Fonts\tt0105m.ttf"; DestDir: "{fonts}"; FontInstall: "Swiss911 XCm BT"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "..\Fonts\tt0106m0.ttf"; DestDir: "{fonts}"; FontInstall: "Swiss911 UCm BT"; Flags: onlyifdoesntexist uninsneveruninstall

[Icons]
Name: "{group}\HAB PADD"; Filename: "{app}\HABPADD.exe"
Name: "{commondesktop}\HAB PADD"; Filename: "{app}\HABPADD.exe"
