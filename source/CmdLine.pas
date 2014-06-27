{/* ***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* Original author:
* - Pavel Cvrcek <jasnapaka@jasnapaka.com>
*
* Contributor(s):
*
* Alternatively, the contents of this file may be used under the terms of
* either of the GNU General Public License Version 2 or later (the "GPL"),
* or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */}

unit CmdLine;

interface

uses AppProfile, Config, Functions, Funkce, Hlavni, MozManager, MozApp, Okna, Zaloha;

procedure BackupAction();
function GetProfileLocation():String;

implementation

uses Forms, Dialogs, ErrorLog, IniFiles, SysUtils;

var action: String;
    applicationStr: String;
    profile: String;
    output: String;
    MozManager: TMozManager;
    MozApp: TMozApp;
    MozProfile: TAppProfile;
    Password: String;

procedure ParseProfileFile(PathToConfig: String);
var inifile: TIniFile;
    str: String;
    Directory: String;
begin
  inifile:= nil;
  try
    inifile:= TINIFile.Create(PathToConfig);

    // action
    str:= lowercase (trim (inifile.ReadString('General', 'action', '')));
    if str = 'backup' then
      begin
        action:= str;
      end
    else
      begin
        WriteMessage (Config.l10n.getL10nString('LANG_SECTION_MOZBACKUP15', 'LANG_CMD_BAD_ACTION'));
        Application.Terminate;
      end;

    // applicationStr
    str:= lowercase(trim (inifile.ReadString('General', 'application', '')));
    MozApp:=  MozManager.getAppOrderByName(str);
    if MozApp <> nil then
      begin
        applicationStr:= str;
      end
    else
      begin
        WriteMessage (Config.l10n.getL10nString('LANG_SECTION_MOZBACKUP15', 'LANG_CMD_BAD_APPLICATION'));
        Application.Terminate;
      end;

    // profile
    str:= lowercase (trim (inifile.ReadString('General', 'profile', '')));
    MozProfile:= MozApp.findProfile(str);
    if (MozProfile <> nil) then
      begin
        Profile:= str;
      end
    else
      begin
        WriteMessage (Config.l10n.getL10nString('LANG_SECTION_MOZBACKUP15', 'LANG_CMD_BAD_PROFILE'));
        Application.Terminate;
      end;

    // output
    Form1.Typ_programu:= MozApp.getId();    
    str:= trim (inifile.ReadString('General', 'output', ''));
    str:= ReplacePlaceholdersInPath (str, Form1.PortableDirectory);
    Directory:= ExtractFilePath(str);
    if not DirectoryExists (Directory) then
      begin
        if not CreateDir(Directory) then
          begin
            WriteMessage (Config.l10n.getL10nString('LANG_SECTION_MOZBACKUP15', 'LANG_CMD_BAD_OUTPUT_DIR'));
            Application.Terminate;
          end;
      end;
    Output:= str;

    // password for backup
    str:= trim (inifile.ReadString('General', 'password', ''));
    str:= Trim (Str);
    Password:= Trim (Str);

    inifile.Free;
  except
    if inifile <> nil then
      begin
        inifile.Free;
      end;
  end;
end;

procedure StartCmdLine(Manager: TMozManager);
var PathToConfig: String;
    FileName: String;
    DirPath: String;
begin
  MozManager:= Manager;

  FileName:= ExtractFileName(ParamStr (1));
  DirPath:= ExtractFilePath (ParamStr(1));

  if (Length (DirPath) > 0) then
    begin
      PathToConfig:= DirPath + FileName;
    end
  else
    begin
      PathToConfig:= ExtractFilePath(Application.ExeName) + FileName;
    end;

  if FileExists(PathToConfig) then
    begin
      ParseProfileFile(PathToConfig);
    end
  else
    begin
      WriteMessage (Config.l10n.getL10nString('LANG_SECTION_MOZBACKUP15', 'LANG_CMD_CONFIG_NOT_FOUND', ParamStr (1)));
      Application.Terminate;
    end;


end;

procedure BackupAction();
begin
  // start MozManager
  Form1.MozManager:= TMozManager.Create;
  MozManager:= Form1.MozManager;
  StartCmdLine(MozManager);

  if (MozManager = nil) then
    begin
      raise Exception.Create('Cannot call BackupAction before init!');
    end;

  // init l10n and gui
  DefaultL10n;

  // prepare values for backup
  Form1.Akce:= 1;
  Form1.Vyst_soubor:= Output;
  Form1.Slozka_data:= MozProfile.getFullPath();
  Form1.Password:= Password;

  DetekceSoucasti;

  Okno5;

  // backup
  Zalohovani;
end;

function GetProfileLocation():String;
var S: String;
    I: integer;
begin
  S:= MozProfile.getFullPath();
  I:= Length (S);
  
  if (S[I] <> '\') then
    begin
      S:= S + '\';
    end;

  Result:= S;
end;

end.
