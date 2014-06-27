program MozBackup;

uses
  Forms,
  hlavni in 'hlavni.pas' {Form1},
  funkce in 'funkce.pas',
  okna in 'okna.pas',
  zaloha in 'zaloha.pas',
  input_dialog in 'input_dialog.pas' {Form2},
  WinUtils in 'WinUtils.pas',
  heslo in 'heslo.pas' {Form4},
  heslo2 in 'heslo2.pas' {Form5},
  JP_Registry in 'JP_Registry.pas',
  l10n in 'l10n.pas',
  Config in 'Config.pas',
  JPDialogs in 'JPDialogs.pas',
  ZipFactory in 'ZipFactory.pas',
  MozProfile in 'MozProfile.pas',
  UnknowFiles in 'UnknowFiles.pas' {UnknowFilesFM},
  UnknowFilesBL in 'UnknowFilesBL.pas',
  UnknowItem in 'UnknowItem.pas',
  SQLite3 in 'sqlite\SQLite3.pas',
  sqlite3udf in 'sqlite\sqlite3udf.pas',
  SQLiteTable3 in 'sqlite\SQLiteTable3.pas',
  CmdLine in 'CmdLine.pas',
  MozUtils in 'MozUtils.pas',
  MozApp in 'apps\MozApp.pas',
  MozManager in 'MozManager.pas',
  SeaMonkeyApp in 'apps\SeaMonkeyApp.pas',
  FirefoxApp in 'apps\FirefoxApp.pas',
  ThunderbirdApp in 'apps\ThunderbirdApp.pas',
  SunbirdApp in 'apps\SunbirdApp.pas',
  FlockApp in 'apps\FlockApp.pas',
  NetscapeApp in 'apps\NetscapeApp.pas',
  MessengerApp in 'apps\MessengerApp.pas',
  Functions in 'Functions.pas',
  AppProfile in 'AppProfile.pas',
  SpiceBirdApp in 'apps\SpiceBirdApp.pas',
  BackupTask in 'BackupTask.pas',
  BackupTaskExternal in 'BackupTaskExternal.pas',
  ProgressWindow in 'ProgressWindow.pas',
  ProfileDetection in 'ProfileDetection.pas',
  Configuration in 'Configuration.pas',
  TesterHelper in 'TesterHelper.pas',
  SongbirdApp in 'apps\SongbirdApp.pas',
  PostBoxApp in 'apps\PostBoxApp.pas',
  WyzoApp in 'apps\WyzoApp.pas';

{$R Icons.res}
{$R ZipMsgUS.RES}

begin
  Application.Initialize;
  Application.Title := 'MozBackup';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TUnknowFilesFM, UnknowFilesFM);
  Application.Run;
end.
