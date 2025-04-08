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

unit inifile;

interface

procedure LoadIni;

implementation

uses hlavni, dialogs, functions, errorlog, inifiles, Config, sysutils;

//******************************************************************************
// procedure CreateIni
//
// - vytvori vychozi ini soubor (pokud neexistuje)
//******************************************************************************

procedure CreateIni;
var F: textfile;
begin

  try
    AssignFile (F, GetApplicationDirectory + Config.CONFIG_FILE);
    Rewrite (F);
    CloseFile (F);
  except
    // provede se zapis do souboru error.log
    try
      WriteMessage (Config.l10n.getL10nString ('TForm1', 'LANG_BADINIWRITE'));
    except

    end;
  end;
end;


//******************************************************************************
// procedure LoadIni
//
// - nacte ini soubor s konfiguraci
//******************************************************************************

// Deprecated
procedure LoadIni;
var IniFile: TIniFile;
    S: string;
    I: integer;
begin
  try
    // existuje INI soubor?
    if FileExists (GetApplicationDirectory + Config.CONFIG_FILE) = true then
      begin
        IniFile:= TIniFile.Create(GetApplicationDirectory + Config.CONFIG_FILE);

        // Format jmena vystupniho souboru
        Form1.VystupniFormat:= Trim (IniFile.ReadString('General', 'fileformat', ''));
        if Length (Form1.VystupniFormat) = 0 then Form1.VystupniFormat:= Config.FORMAT_FILENAME;

        // Adresar pro zalohy (obecne)
        S:= Trim (IniFile.ReadString('General', 'backupdir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.GeneralDir:= S;
        S:= '';

        // Adresar pro zalohy (Firefox)
        S:= Trim (IniFile.ReadString('General', 'firefoxdir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.FirefoxDir:= S;
        S:= '';
        
        // Adresar pro zalohy (Thunderbird)
        S:= Trim (IniFile.ReadString('General', 'thunderbirddir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.ThunderbirdDir:= S;
        S:= '';

        // Adresar pro zalohy (SeaMonkey)
        S:= Trim (IniFile.ReadString('General', 'suitedir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.SuiteDir:= S;
        S:= '';

        // Adresar pro zalohy (Sunbird)
        S:= Trim (IniFile.ReadString('General', 'sunbirddir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.SunbirdDir:= S;
        S:= '';

        // Adresar pro zalohy (Flock)
        S:= Trim (IniFile.ReadString('General', 'flockdir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.FlockDir:= S;
        S:= '';

        // Adresar pro zalohy (Netscape)
        S:= Trim (IniFile.ReadString('General', 'netscapedir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.NetscapeDir:= S;
        S:= '';

        // Adresar pro zalohy (Netscape Messenger)
        S:= Trim (IniFile.ReadString('General', 'netscapemessdir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.NetscapeMessengerDir:= S;
        S:= '';

        // Adresar pro zalohy (Spicebirdu)
        S:= Trim (IniFile.ReadString('General', 'spicebirddir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.SpicebirdDir:= S;
        S:= '';

        // Adresar pro zalohy (Songbirdu)
        S:= Trim (IniFile.ReadString('General', 'songbirddir', ''));
        if (Length (S) > 0) and (DirectoryExists (S)) then Form1.SongbirdDir:= S;
        S:= '';

        // Monitor, na kterém bude aplikace zobrazena
        S:= Trim (IniFile.ReadString('General', 'monitor', ''));
        Form1.Monitor:= 1;
        if (Length (S) > 0) then
          begin
            try
              I:= StrToInt (S);
              if (I > 0) then Form1.Monitor:= I;
            except
            end;
          end;
        
        // Info, zda bude uživatel pøi zálohování dotazován na heslo
        S:= Trim (IniFile.ReadString('General', 'askForPassword', ''));
        if (S = 'false') then
          begin
            Form1.AskForPassword:= false;
          end
        else
          begin
            Form1.AskForPassword:= true;
          end;
      end
    else CreateIni;
  except
    // zapis do log souboru
    try
      WriteMessage (Config.l10n.getL10nString ('TForm1', 'LANG_BADINIREAD'));
    except

    end;
  end;
end;

end.
