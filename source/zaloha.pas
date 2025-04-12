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

unit zaloha;

interface

uses BackupTask;

const Pocet_polozek = 13;       // number of items being backed up + 1

var backupTask: TBackupTask;

// saves the list of backed-up items
procedure CreateKomponenty (var F: textfile);
// copies file from backup
procedure Kopie2 (var F1: textfile; Soubor: string);
// performs backup restore
procedure Obnoveni;
// creates necessary directories in the path
procedure VytvorAdresar (S: string);
// performs backup
procedure Zalohovani;

implementation

//******************************************************************************
// Declaration of used units
//******************************************************************************

uses forms, dialogs, funkce, hlavni, chyby, okna, StrUtils,
     SysUtils, Windows, ZipMstr19, Config, JPDialogs,
     ZipFactory, classes, PrefsParser, PrefsParserAccount, UnknowFilesBL,
     UnknowItem, UnknowFiles, functions, ProgressWindow;


//******************************************************************************
// procedure Uzavrit_soubor
//
// - attempts to close and delete the backup file that failed to be created
//******************************************************************************

procedure Uzavrit_soubor (var F: textfile; Soubor: string);
begin
  try
    CloseFile (F);
    if FileExists (Soubor) then SysUtils.DeleteFile (Soubor);
  except
    on E:EInOutError do
      begin
        Form1.Chyba:= true;
        Form1.Close;
      end;
  end;
end;

procedure CorrectPrefsNew;
begin

end;

//******************************************************************************
// procedure VymazPrefs
//
// - deletes unused lines from the file
//******************************************************************************
procedure VymazPrefs;
var F, F2: textfile;
    S: string;
begin
  try
    if FileExists (Form1.Slozka_data + 'prefs.zal') then SysUtils.DeleteFile (Form1.Slozka_data + 'prefs.zal');
    if RenameFile (Form1.Slozka_data + 'prefs.js', Form1.Slozka_data + 'prefs.zal') then
      begin
        AssignFile (F, Form1.Slozka_data + 'prefs.zal');
        AssignFile (F2, Form1.Slozka_data + 'prefs.js');
        Reset (F);
        Rewrite (F2);

        Repeat
          Readln (F, S);
          // removal of emails
          if (Pos ('user_pref("mail.', S) = 1) and (Form1.Typ_programu = 2) then S:= '';
          if (Pos ('user_pref("mailnews', S) = 1) and (Form1.Typ_programu = 2) then S:= '';
          if (Pos ('user_pref("ldap', S) = 1) and (Form1.Typ_programu = 2) then S:= '';

          // removal of browser data
          if (Pos ('user_pref("browser.', S) = 1) and (Form1.Typ_programu = 3) then S:= '';

          // removal of email information
          if (Form1.CheckBox2.Checked = false) and (Pos ('user_pref("mail.', S) > 0) then S:= '';
          if (Form1.CheckBox2.Checked = false) and (Pos ('user_pref("mailnews.', S) > 0) then S:= '';

          // removal of contact information
          if (Form1.CheckBox3.Checked = false) and (Pos ('user_pref("ldap_2', S) > 0) then S:= '';

          // removal of passwords
          if (Form1.CheckBox9.Checked = false) and (Pos ('user_pref("signon.SignonFileName",', S) > 0) then S:= '';

          // filled-in forms
          if (Form1.CheckBox11.Checked = false) and (Pos ('user_pref("wallet.SchemaValueFileName"', S) > 0) then S:= '';
          if (Form1.CheckBox11.Checked = false) and (Pos ('user_pref("wallet.caveat",', S) > 0) then S:= '';          

          // removal of disk cache
          if Pos ('user_pref("browser.cache.disk.parent_directory"', S) > 0 then S:= '';          

          if Length(S) <> 0 then Writeln (F2, S);
        Until Eof (F);

        CloseFile (F2);
        CloseFile (F);
        SysUtils.DeleteFile (Form1.Slozka_data + 'prefs.zal');
      end;
   except
    on E:EInOutError do     // an exception occurred
      begin
        showWarningDialog(Config.l10n.getL10nString ('TForm1', 'LANG_WARNING'),
                          Config.l10n.getL10nString ('TForm1', 'LANG_NOT_FOUND2'));
        Halt (1);
      end;
  end;
end;


//******************************************************************************
// procedure CreateFileHeader
//
// - creating the index file of the archive
//******************************************************************************

procedure CreateFileHeader (unknowFilesList: TList);
var F: textfile;
    I: integer;
    unknowItem: TUnknowItem;
begin
  try
    // the program’s actual manipulation
    AssignFile (F, Form1.Slozka_data + 'indexfile.txt');
    Rewrite (F);
      Writeln (F, 'Mozilla Backup');
      Writeln (F, 'Revize: ' + IntToStr (Form1.Typ_programu));
      Writeln (F, 'Verze: ' + Form1.Verze);
      Writeln (F, '****////\\\\****');
      CreateKomponenty (F);

      // add paths to external accounts
      for I:= 1 to Form1.Pocet_extern-1 do
        Writeln (F, Form1.Extern_ucty[i]);
      Writeln (F, '****////\\\\****');

      // add list of unknow files in profile
      for I:= 0 to unknowFilesList.Count - 1 do
        begin
          unknowItem:= TUnknowItem(unknowFilesList[i]);
          if (unknowItem.isDirectory) then
            begin
              Writeln (F, 'dir');
            end
          else
            begin
              Writeln (F, 'file');
            end;
          Writeln (F, unknowItem.getFilename);
        end;
      Writeln (F, '****////\\\\****');
    CloseFile (F);

    backupTask.addFile('indexfile.txt');
  except
    on E:EInOutError do
      begin
        showWarningDialog(Config.l10n.getL10nString ('TForm1', 'LANG_WARNING'),
                          Config.l10n.getL10nString ('TForm1', 'LANG_WRITE_ERROR'));
        Uzavrit_soubor (F, Form1.StaticText3.Caption); 
        Halt (1);
      end;
  end;
end;

//******************************************************************************
// procedure CreateKomponenty
//
// - saves information about the components it contains to the backup file
//
// Input: F - reference to the output file
//******************************************************************************

procedure CreateKomponenty (var F: textfile);
begin
  try
    if Form1.CheckBox1.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox2.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox3.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox4.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox5.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox6.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox8.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox9.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox10.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox11.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox12.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox13.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox14.Checked then Write (F, 'Y') else Write (F, 'N');
    if Form1.CheckBox15.Checked then Writeln (F, 'Y') else Writeln (F, 'N');
    Writeln (F, '****////\\\\****');
  except
    on E:EInOutError do
      begin
        showWarningDialog(Config.l10n.getL10nString ('TForm1', 'LANG_WARNING'),
                          Config.l10n.getL10nString ('TForm1', 'LANG_WRITE_ERROR'));
        Uzavrit_soubor (F, Form1.StaticText3.Caption);
        Halt (1);
      end;
  end;
end;




//******************************************************************************
// procedure Kopie2
//
// - copies a file from the backup to the specified folder
//
// Input: F1 - reference to the source file
//        Soubor - name of the output file
//******************************************************************************

procedure Kopie2 (var F1: textfile; Soubor: string);
var F: textfile;
    S: string;
    I: integer;
    Detekce: boolean;
begin
  Detekce:= false; I:= 0;
  try
    AssignFile (F, Form1.Slozka_data + Soubor);
    Rewrite (F);
      Repeat
        Inc (I);
        Readln (F1, S);
        if S <> '****////\\\\****' then Writeln (F, S);
        if I mod 100 = 0 then
          begin
            Application.ProcessMessages;
            While (IsRunning) and (Detekce = false) do
              begin
                case Form1.Typ_programu of
                  1: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'SeaMonkey')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  2: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Mozilla Firefox')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  3: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Mozilla Thunderbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  4: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Mozilla Sunbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  5: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Flock')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  6: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Netscape Navigator')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  7: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Netscape Messenger')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  8: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Spicebird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  9: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Songbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  11: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Postbox')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  12: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'Wyzo')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                  13: if Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE', 'LibreWolf')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_RETRYCANCEL + MB_ICONERROR) = IDCANCEL then Detekce:= true;
                end;
              end;
            if Detekce = true then
              begin
                case Form1.Typ_programu of
                  1: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'SeaMonkey')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  2: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Mozilla Firefox')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  3: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Mozilla Thunderbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  4: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Mozilla Sunbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  5: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Flock')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  6: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Netscape Navigator')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  7: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Netscape Messenger')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  8: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Spicebird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  9: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Songbird')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  11: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'PostBox')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  12: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'Wyzo')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                  13: Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DETEKCE2', 'LibreWolf')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                end;
                Halt (1);
              end;
          end;
      Until S = '****////\\\\****';
    CloseFile (F);
  except
    on E:EInOutError do
      begin
        if Eof (F1) then Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_END_FILE')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING)
        else Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WRITE_ERROR2')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
        Halt (1);
      end;
  end;
end;


function getDirectoryFromPref (Directory:String):String;
begin
  Directory:= Utf8ToAnsi(directory);
  Result:= AnsiReplaceStr (Directory, '\\', '\');
end;

function getDirectoryToPref (Directory:String):String;
begin
  Directory:= AnsiToUtf8(directory);
  Result:= AnsiReplaceStr (Directory, '\', '\\');
end;

function isExternAccount(accountDir: String):boolean;
var i: integer;
begin
  Result:= false;

  for i:= 0 to Form1.Pocet_extern - 1 do
    begin
      if Form1.Extern_ucty[i] = accountDir then
        begin
          Result:= true;
        end;
    end;
end;

// if the second-to-last is true, it returns the path from the second-to-last slash,
// otherwise, it returns everything before the last slash
// TODO: This could be written more elegantly
// type:
// 1 - removes everything up to the second-to-last slash
// 2 - removes everything after the last slash
// 3 - removes everything up to the last slash
function getRelativeMailBoxPathToProfile(path:String; typ: integer):String;
var i, j, k: integer;
begin
  j:= 0; k:= 0;
  for I := 1 to Length (path) do
    begin
      if path[i] = '\' then
        begin
          k:= j;
          j:= i;
        end;
    end;

  case typ of
    1: Delete(path, 1, k);
    2: Delete(path, j, Length (Path) - j + 1);
    3: Delete(path, 1, j);  
  end;

  Result:= path;
end;

// creates the directory structure except for the last directory in the path
procedure CreateDirectoryRecursive (directory:String);
var i: integer;
    s: String;
begin
  for i := 1 to Length (directory) do
    begin
      if directory[i] = '\' then
        begin
          s:= Copy (directory, 1, i);
          if not DirectoryExists (s) then
            begin
              CreateDir (S);
            end;
        end;
    end;

  CreateDir (directory);
end;


function isAccountInList (AccountList: TStringList; Account: String):boolean;
var I: Integer;
begin
  Result:= false;
  for I := 0 to AccountList.Count - 1 do
    begin
      if Pos (AccountList[I], Account) > 0 then
        begin
          Result:= true;
        end;
    end;
end;


procedure RestoreEmails (Directory: String; zipFactory: TZipFactory);
var f1, f2: TextFile;
    s: String;
    prefsParser: TPrefsParser;
    value: String;
    mailAccountB: boolean;
    mailAccountNewdsB: boolean;
    directoryExt: String;
    dir: String;
    RelativePath: String;
    FilesExtracted: integer;
    AccountList: TStringList;

    // if program delete relative path to account in prefs.js
    DeleteRelativePath: boolean;
begin
   // Restores mailboxes located in the profile
  zipFactory.extractDirectory('ImapMail', '*.*');
  zipFactory.extractDirectory('Mail', '*.*');
  zipFactory.extractDirectory('News', '*.*');

  // Restores external mailboxes located outside the profile
  prefsParser := TPrefsParser.Create(Directory + '\prefs.js');
  AccountList := TStringList.Create;

  // If an old backup file (prefs.js) exists, delete it
  if FileExists(Directory + 'prefs.zal') then SysUtils.DeleteFile(Directory + 'prefs.zal');

  // Rename prefs.js to backup from which the new prefs.js will be created
  RenameFile(Directory + '\' + 'prefs.js', Directory + '\' + 'prefs.zal');

  // Editing the configuration file
  AssignFile(f1, Directory + '\' + 'prefs.zal');
  Reset(f1);
  AssignFile(f2, Directory + '\' + 'prefs.js');
  ReWrite(f2);
  Repeat
    Readln(f1, s);

    // Check if the line contains information about a mail account directory
    mailAccountB := ((Pos('user_pref("mail.server.server', s) > 0) and (Pos('.directory"', s) > 0));

    // Absolute path to mail accounts
    if mailAccountB then
    begin
      value := prefsParser.getPrefValue(s);
      value := getDirectoryFromPref(value);

      if isExternAccount(value) then
      begin
        // It is an external email account
        CreateDirectoryRecursive(value);

        if not DirectoryExists(value) then
        begin
          // TODO: If the directory creation fails, offer the user to choose a different location
          showErrorDialog(Config.l10n.getL10nString('MozBackup14', 'LANG_ERROR'),
                          Config.l10n.getL10nString('MozBackup14', 'LANG_CANNOT_RESTORE_ORIG_EXT') + ' ' + value);
        end
        else
        begin
          // Remove the last directory from the path
          directoryExt := getRelativeMailBoxPathToProfile(value, 2);
          dir := getRelativeMailBoxPathToProfile(value, 3);

          SysUtils.ForceDirectories(directoryExt + '\' + dir);
          zipFactory.extractDirectory(dir, '*.*', directoryExt);

          // Set the new property value
          s := prefsParser.setPrefValue(s, getDirectoryToPref(directoryExt + '\' + dir));
        end;
      end;
    end;

    // If there is any output, write it to the output file
    if Length(s) > 0 then
    begin
      Writeln(f2, s);
    end;
  until eof(f1);
  CloseFile(f2);
  CloseFile(f1);
end;

{procedure RestoreEmailsNew (Directory: String; zipFactory: TZipFactory);
var f1, f2: TextFile;
    s: String;
    prefsParser: TPrefsParser;
    value: String;
    mailAccountB: boolean;
    mailAccountNewdsB: boolean;
    directoryExt: String;
    dir: String;
    RelativePath: String;
    FilesExtracted: integer;
    AccountList: TStringList;

    // if program delete relative path to account in prefs.js
    DeleteRelativePath: boolean;
begin
  prefsParser:= TPrefsParser.Create(Directory + '\prefs.js');
  AccountList:= TStringList.Create;

  // pokud existuje stary soubor se zalohou prefs.js, pak jej smazat
  if FileExists (Directory + 'prefs.zal') then SysUtils.DeleteFile (Directory + 'prefs.zal');

  // prefs.js prejmenovat na zalohu, z ktere se bude novy prefs.js vytvaret
  RenameFile (Directory + '\' + 'prefs.js', Directory + '\' + 'prefs.zal');

  // editace konfiguracniho souboru
  AssignFile (f1, Directory + '\' + 'prefs.zal');
  Reset (f1);
  AssignFile (f2, Directory + '\' + 'prefs.js');
  ReWrite (f2);
  Repeat
    Readln (f1, s);
    DeleteRelativePath:= false;

    // je v radku informace o adresari s postou
    mailAccountB:= ((Pos ('user_pref("mail.server.server', s) > 0) and (Pos ('.directory"', s) > 0));
    // je v radku informace o souboru se seznamem prihlasenych diskusnich skupin
    mailAccountNewdsB:= ((Pos ('user_pref("mail.server.server', s) > 0) and (Pos ('.newsrc.file"', s) > 0));

    // cesta k uctum (absolutni)
    if mailAccountB or mailAccountNewdsB then
      begin
        value:= prefsParser.getPrefValue(s);
        value:= getDirectoryFromPref (value);

        if not isExternAccount (value) then
          begin
            // ziskam relativni cestu (musim najit predposledni uvozovku)
            value:= getRelativeMailBoxPathToProfile(value, 1);

            // rozbaleni posty
            if mailAccountB then
              begin
                // Nejprve to zkusit rozbalit skrze relativni cestu
                if not isAccountInList (AccountList, Directory + Value) then
                  begin
                    if ((Pos ('.newsrc.file"', s) = 0)) then
                      begin
                        SysUtils.ForceDirectories(Directory + '\' + value);
                      end;

                    FilesExtracted:= zipFactory.extractDirectory(value, '*.*', Directory);
                    if FilesExtracted > 0 then
                      begin
                        AccountList.Add(Directory + value);
                      end;
                  end;
              end;

            // rozbaleni newds cesty
            if mailAccountNewdsB then
              begin
                // odrizne se cast cesty za poslednim lomitkem
                dir:= getRelativeMailBoxPathToProfile (value, 2);
                zipFactory.extractDirectory(dir, '*.rc', Directory);
                zipFactory.extractDirectory(dir, '*.msf', Directory);                              
              end;

            // nastavení nové hodnoty vlastnosti
            s:= prefsParser.setPrefValue(s, getDirectoryToPref(Directory + '\' + value));
          end
        else
          begin
            // jedna se o externi postovni ucet
            CreateDirectoryRecursive (value);

            if not DirectoryExists (value) then
              begin
                // TODO: Pokud se to nepovede, dat uzivateli vyber jineho umisteni
                showErrorDialog (Config.l10n.getL10nString ('MozBackup14', 'LANG_ERROR'),
                              Config.l10n.getL10nString ('MozBackup14', 'LANG_CANNOT_RESTORE_ORIG_EXT') + ' ' + value);
              end
            else
              begin
                // odrizne se z cesty posledni adresar
                directoryExt:= getRelativeMailBoxPathToProfile (value, 2);
                dir:= getRelativeMailBoxPathToProfile (value, 3);

                SysUtils.ForceDirectories(directoryExt + '\' + dir);
                zipFactory.extractDirectory(dir, '*.*', directoryExt);

                // nastavení nové hodnoty vlastnosti
                s:= prefsParser.setPrefValue(s, getDirectoryToPref(directoryExt + '\' + dir));
              end;

          end;
    end;

    // cesta k uctum (relativni)
    if ((Pos ('user_pref("mail.server.server', s) > 0)) and ((Pos ('.directory-rel"', s) > 0)
        or (Pos ('.newsrc.file-rel"', s) > 0)) then
      begin
        value:= prefsParser.getPrefValue(s);
        value:= getDirectoryFromPref (value);

        value:= StringReplace (value, '[ProfD]', Form1.AktualniProfil + '/', []);
        value:= getRelativeMailBoxPathToProfile(value, 1);

        if not isAccountInList (AccountList, Directory + Value) then
          begin
             if ((Pos ('.newsrc.file-rel"', s) = 0)) then
               begin
                 SysUtils.ForceDirectories(Directory + '\' + value);
               end;

             FilesExtracted:= zipFactory.extractDirectory(value, '*.*', Directory);
             if FilesExtracted > 0 then
               begin
                 AccountList.Add(Directory + value);
               end;
             end;

         // Pokud se nepodarilo obnovit, smaz relativni cestu
         if not DirectoryExists (Directory + Value) then
           begin
             S:= '';
           end;
         
      end;

    // "root" cesty
    if (Pos ('user_pref("mail.root', s) > 0) or (Pos ('user_pref("mail.newsrc_root', s) > 0) then
      begin
        // nejedna se o relativni cesty?
        if (Pos ('-rel"', s) > 0) then
          begin
            s:= '';
          end
        else
          begin
            if (Pos ('.nntp', s) > 0) or (Pos ('.newsrc_root', s) > 0) then
              begin
                s:= prefsParser.setPrefValue(s, getDirectoryToPref(Directory + '\News'));
              end;
            if (Pos ('.pop3', s) > 0) or (Pos ('.none', s) > 0)  then
              begin
                s:= prefsParser.setPrefValue(s, getDirectoryToPref(Directory + '\Mail'));
              end;
            if Pos ('.imap', s) > 0 then
              begin
                s:= prefsParser.setPrefValue(s, getDirectoryToPref(Directory + '\ImapMail'));
              end;
          end;
        
      end;

    // pokud je neco na vystup, zapis to tam    
    if Length (s) > 0 then
      begin
        Writeln (f2, s);
      end;
  until eof (f1);
  CloseFile (f2);
  CloseFile (f1);

  // vymaze se zalozni prefs.js
  if FileExists (Directory + '\' + 'prefs.zal') then
    begin
      SysUtils.DeleteFile(Directory + '\' + 'prefs.zal');
    end;

  AccountList.Free;
end;    }


//******************************************************************************
// procedure ModifChrome
//
// - correct path in /chrome/chrome.rdf
//******************************************************************************

procedure ModifChrome;
var F1: textfile;
    F2: textfile;
    S: string;
    S1: string;
    L: integer;
    R: integer;
    I: integer;
    J: integer;
    c: char;
    zavorka: boolean;
begin
  if SysUtils.FileExists(Form1.Slozka_data + 'chrome' + '\' + 'chrome.rdf') = true then
    begin
      SysUtils.RenameFile(Form1.Slozka_data + 'chrome' + '\' + 'chrome.rdf',
                          Form1.Slozka_data + 'chrome' + '\' + 'chrome.bak');

      AssignFile (F1, Form1.Slozka_data + 'chrome' + '\' + 'chrome.bak');
      Reset (F1);
      AssignFile (F2, Form1.Slozka_data + 'chrome' + '\' + 'chrome.rdf');
      Rewrite (F2);

      Repeat
        Readln (F1, S);
        if Pos ('c:baseURL', S) > 0 then
          begin
            // first, the left part of the path is found
            if Pos ('/extensions/', S) > 0 then
              begin
                L:= Pos ('/extensions/', S);
                L:= L + 11;
                S1:= copy (S, L, Length (S) - L + 1);

                // right part of the path
                if Pos ('"', S1) > 0 then
                  begin
                    R:= Pos ('"', S1);
                    I:= Length (S1) - R;
                    S1:= copy (S1, 1, Length (S1) - I - 1);
                    //S1:= Utf8ToAnsi (S1);

                    if Pos ('>', S) > 0 then zavorka:= true
                    else zavorka:= false;

                    // now a new line is constructed for the configuration file
                    S:= 'c:baseURL="jar:file:///';
                    S:= S + AnsiReplaceStr (Form1.Slozka_data, '\', '/');
                    S:= S + '/extensions';
                    S:= S + S1 + '"';
                    if zavorka = true then S:= S + '>';


                    // typecasting
                    for i:=1 to length (s) do
                      begin
                        c:= S[i];
                        j:= Ord (c);
                        if (j > 127) then
                          begin
                            S1:= IntToHex (j, 2);
                            S1:= '%' + S1;
                            Delete (S, I, 1);
                            Insert (S1, S, I);
                          end;
                      end;

                    S:= AnsiReplaceStr (S, ' ', '%20');
                   // S:= AnsiReplaceStr (S, 'è', '%E8');
                   // S:= AnsiReplaceStr (S, 'í', '%ED');

                    S:= '                   ' + S;

                    S:= AnsiToUtf8 (S);


                  end;
              end;
          end;
        Writeln (F2, S);
      Until Eof (f1); 

      CloseFile (F2);
      CloseFile (F1);

      Sysutils.DeleteFile(Form1.Slozka_data + 'chrome' + '\' + 'chrome.bak');
    end;
end;


//******************************************************************************
// procedure Obnoveni
//
// - // restoring profile from backup
//******************************************************************************

procedure Obnoveni_ext (zipFactory: TZipFactory);
begin
  // Adblock Plus
  zipFactory.extractDirectory('adblockplus', '*.*');

  // Bookmarks Synchronizer
  zipFactory.extractFile('bookmarks.xml');

  // Clippings
  zipFactory.extractFile('clipdat.rdf');  

  // ColorZilla
  zipFactory.extractDirectory('colorzilla', '*.*');  

  // Crash Recovery
  zipFactory.extractFile('crashrecovery.dat');

  // Google Toolbar
  zipFactory.extractDirectory('GoogleToolbarData', '*.*');  

  // Greasemonkey
  zipFactory.extractDirectory('gm_scripts', '*.*');  

  // ForecastFox
  zipFactory.extractDirectory('forecastfox', '*.*');  

  // ChatZilla
  zipFactory.extractDirectory('ChatZilla', '*.*');  

  // Lightning
  zipFactory.extractFile('storage.sdb');
  zipFactory.extractDirectory('calendar-data', '*.*');

  // Menu editor
  zipFactory.extractFile('menuedit.rdf');  

  // Mouse Gestures
  zipFactory.extractFile('mousegestures.rdf');  

  // Prefbar
  zipFactory.extractFile('prefbar.rdf');  

  // ScrapBook
  zipFactory.extractDirectory('ScrapBook', '*.*');  

  // Stylish
  zipFactory.extractFile('stylish.rdf');  

  // Tab Mix Plus
  zipFactory.extractFile('session.rdf');  

  // Tabbrowser Extensions
  zipFactory.extractFile('tabextensions.js');
  zipFactory.extractFile('tabextensions.rdf');   

  // View Source With
  zipFactory.extractFile('viewSource.xml');  
end;


//******************************************************************************
// procedure Obnoveni
//
// - restoring profile from backup
//******************************************************************************

procedure Obnoveni;
var F: textfile;
    I: integer;
    S, S1: string;
    Profil: string;
    P: TProfily;
    Nalezen: boolean;
    zipFactory: TZipFactory;
    stringList: TStringList;
    filename: String;
    isDirectory: boolean;
begin

  if FileExists (Form1.Vyst_soubor) then
    begin
      try
        // determining the path to the profile
        Profil:= Form1.ListBox2.Items.Strings[Form1.ListBox2.ItemIndex];

        Nalezen:= false;
        P:= Form1.Prvni_profil;
        While (P <> nil) and (Nalezen = false) do
          begin
            if (P^.Jmeno = Profil) then
              begin
                Form1.Slozka_data:= P^.Cesta;
                Nalezen:= true;
              end;
            P:= P^.Dalsi;
          end;

        // portable profile?
        if (nalezen = false) and (Length (Form1.PortableDirectory) > 0) then
          begin
            Form1.Slozka_data:= Form1.PortableDirectory;            
          end;

      {  Form1.Slozka_data:= Form1.Slozka_data + '\Profiles\' + Form1.ListBox2.Items.Strings[Form1.ListBox2.ItemIndex];

        // je tato cesta platna? -> neni, pak se nejspis jedna o novy typ profilu
        if (DirectoryExists (Form1.Slozka_data) = false)  
        
        FindFirst (Form1.Slozka_data + '\*.*', faDirectory, Vyhledej);
        While (Vyhledej.Name = '.') or (Vyhledej.Name = '..') do
          FindNext (Vyhledej);
          
        if Length (Vyhledej.Name) > 0 then
          begin
            // doplneni cesty k profilu
            Form1.Slozka_data:= Form1.Slozka_data + '\' + Vyhledej.Name;    }


          if Form1.Verze_souboru = 1 then begin
            // opening the file for reading
            AssignFile (F, Form1.Vyst_soubor);
              Reset (F);
                // loading first 6 lines
                for I:= 1 to 6 do
                  Readln (F, S);
                // loading lines
                Repeat
                  Readln (F, S);
                  S:= Trim (S);

                  // general settings
                  if (S = 'Nastaveni') and (Form1.CheckBox1.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_AKCE_OBECNE1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;
                                                      // TbsCorePolyglot.GetCorePolyglot.GetString ('TForm1', 'LANG_PROFIL_NAME', 'External profile');
                  // mail
                  if (S = 'Mail') and (Form1.CheckBox2.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_AKCE_MAIL1');
                      Readln (F, S);     // loading the filename
                      VytvorAdresar (S); // create the necessary directories
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // contacts
                  if (S = 'Kontakty') and (Form1.CheckBox3.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_KONTATKY1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // oblibene polozky
                  if (S = 'Oblibene polozky') and (Form1.CheckBox4.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_FAVORITES1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // historie
                  if (S = 'Historie') and (Form1.CheckBox5.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_HISTORIE1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // postranni panely
                  if (S = 'Postranni panely') and (Form1.CheckBox6.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_PANELY1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // Uzivatelske styly
                  if (S = 'Uzivatelske styly') and (Form1.CheckBox8.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_STYLY1');
                      Readln (F, S);     // loading the filename
                      VytvorAdresar (S); // creates the necessary directories
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // ulozena hesla
                  if (S = 'Ulozena hesla') and (Form1.CheckBox9.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_HESLA1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // cookies
                  if (S = 'Cookies') and (Form1.CheckBox10.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_COOKIES1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // doplnene formulare
                  if (S = 'Doplnene formulare') and (Form1.CheckBox11.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_FORMULAR1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;

                  // stahovani souboru
                  if (S = 'Download manager') and (Form1.CheckBox12.Checked = true) then
                    begin
                      Form1.StaticText6.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_DOWNLOAD1');
                      Readln (F, S);     // loading the filename
                      Readln (F, S1);
                      Kopie2 (F, S);     // create the file and copy it
                      Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;
                      Form1.ListBox3.Items.Add (Config.l10n.getL10nString ('TForm1', 'LANG_SOUBOR') + S);
                    end;
                Until Eof (F);
            CloseFile (F);
         end;

      if Form1.Verze_souboru = 2 then
        begin
          zipFactory:= TZipFactory.Create(Form1.Vyst_soubor, Form1.Slozka_data, '');
          stringList:= TStringList.Create;

          Form1.ProgressBar1.Max:= 140;
          Form1.ProgressBar1.Position:= 0;

          // restore settings
          if Form1.CheckBox1.Checked = true then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_AKCE_OBECNE1'));

              stringList.Add('prefs.js');
              stringList.Add('cookperm.txt');
              stringList.Add('hostperm.1');
              stringList.Add('permissions.sqlite');
              stringList.Add('mimeTypes.rdf');
              stringList.Add('user.js');
              stringList.Add('ac-weights.txt');
              stringList.Add('localstore.rdf');
              stringList.Add('localstore-safe.rdf');
              stringList.Add('persdict.dat');
              stringList.Add('search.rdf');
              stringList.Add('search.json');
              stringList.Add('search.sqlite');
              stringList.Add('listing-downloaded.xml');
              stringList.Add('listing-uploaded.xml');             
              stringList.Add('sessionstore.js');
              stringList.Add('sessionstore.json');
              stringList.Add('urlclassifier.sqlite');
              stringList.Add('urlclassifier2.sqlite');
              stringList.Add('urlclassifier3.sqlite');
              stringList.Add('kf.txt');
              stringList.Add('webappsstore.sqlite');             
              stringList.Add('blocklist.xml');
              stringList.Add('metrics.xml');
              stringList.Add('metrics-config.xml');
              stringList.Add('content-prefs.sqlite');
              stringList.Add('session.json');
              stringList.Add('chromeappsstore.sqlite');
              stringList.Add('urlclassifierkey3.txt');
              stringList.Add('urlclassifierkey4.txt');
              stringList.Add('search-metadata.json');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              zipFactory.extractDirectory('microsummary-generators', '*.*');
              zipFactory.extractDirectory('weave', '*.*');

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_OBECNE_R_OK'));
            end;

          // restore mail
          if (Form1.CheckBox2.Checked = true) and (Form1.Typ_programu <> 2) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_AKCE_MAIL1'));

              stringList.Add('prefs.js');
              stringList.Add('mailViews.dat');
              stringList.Add('panacea.dat');
              stringList.Add('training.dat');
              stringList.Add('virtualFolders.dat');
              stringList.Add('global-messages-db.sqlite');
              stringList.Add('folderTree.json');
              stringList.Add('traits.dat');
              stringList.Add('junklog.html');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              // restore the accounts themselves
              RestoreEmails (Form1.Slozka_data, zipFactory);

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_MAIL_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // restore the contacts
          if (Form1.CheckBox3.Checked = true) and (Form1.Typ_programu <> 2) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_KONTATKY1'));

              zipFactory.extractDirectory('Photos', '*.*');              
              zipFactory.extractDirectory('', '*.mab');

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_KONTAKTY_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // restore the favorite items
          if (Form1.CheckBox4.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_FAVORITES1'));

              stringList.Add('bookmarks.html');
              stringList.Add('bookmarks.bak');
              stringList.Add('bookmarks_history.sqlite');
              stringList.Add('places.sqlite');
              stringList.Add('places.sqlite-journal');
              stringList.Add('bookmarks.postplaces.html');
              stringList.Add('bookmarks.preplaces.html');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              zipFactory.extractDirectory('bookmarkbackups', '*.*');

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_FAVORITES_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

         // restore history
          if (Form1.CheckBox5.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_HISTORIE1'));

              stringList.Add('history.dat');
              stringList.Add('bookmarks_history.sqlite');
              stringList.Add('places.sqlite');
              stringList.Add('places.sqlite-journal');              
              stringList.Add('url-data.txt');
              stringList.Add('urlbarhistory.sqlite');              

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_HISTORIE_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // sidebars
          if (Form1.CheckBox6.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_PANELY1'));

              stringList.Add('panels.rdf');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_PANELY_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // user styles
          if Form1.CheckBox8.Checked = true then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_STYLY1'));

              stringList.Add('chrome\userContent.css');
              stringList.Add('chrome\userChrome.css');              

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_STYLY_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            

          // saved passwords
          if Form1.CheckBox9.Checked = true then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_HESLA1'));

              zipFactory.extractDirectory('', '*.s');

              stringList.Add('signons.txt');
              stringList.Add('signons2.txt');
              stringList.Add('signons3.txt');
              stringList.Add('signons4.txt');
              stringList.Add('signons5.txt');
              stringList.Add('signons.sqlite');              
              stringList.Add('key3.db');                            

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_HESLA_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // cookies
          if (Form1.CheckBox10.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_COOKIES1'));

              stringList.Add('cookies.txt');
              stringList.Add('cookies.sqlite');
              stringList.Add('cookies.sqlite-journal');              

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_COOKIES_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // forms
          if (Form1.CheckBox11.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_FORMULAR1'));

              stringList.Add('formhistory.dat');
              stringList.Add('formhistory.sqlite');
              stringList.Add('URL.tbl');              

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              zipFactory.extractDirectory('', '*.w');

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_FORMULARE_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            

          // download
          if (Form1.CheckBox12.Checked = true) and (Form1.Typ_programu <> 3) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_DOWNLOAD1'));

              stringList.Add('downloads.rdf');
              stringList.Add('downloads.sqlite');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_SOUBORY_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            

          // certificates
          if Form1.CheckBox13.Checked = true then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_CERTIF1'));

              stringList.Add('cert7.db');
              stringList.Add('cert8.db');
              stringList.Add('key3.db');
              stringList.Add('secmod.db');
              stringList.Add('cert_override.txt');

              zipFactory.extractFileList(stringList);
              stringList.Clear;

              zipFactory.extractDirectory('cert7.dir', '*.*');
              zipFactory.extractDirectory('cert8.dir', '*.*');                           

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_CERTIF_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            

          // extensions
          if (Form1.CheckBox14.Checked = true) and (Form1.Typ_programu <> 1) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_EXTENSIONS1'));

              //stringList.Add('extensions.rdf');
              stringList.Add('extensions.log');
              stringList.Add('extensions.sqlite');
              stringList.Add('addons.sqlite');              
              stringList.Add('lightweighttheme-footer');
              stringList.Add('lightweighttheme-header');
              stringList.Add('applications.sqlite');                             

              zipFactory.extractFileList(stringList);
              stringList.Clear;              

              zipFactory.extractDirectory('extensions', '*.*');
              zipFactory.extractDirectory('chrome', '*.*');
              zipFactory.extractDirectory('searchplugins', '*.*');

              if Form1.CheckBox8.Checked = false then
                begin
                  SysUtils.DeleteFile('chrome' + '\' + 'userContent.css');
                  SysUtils.DeleteFile('chrome' + '\' + 'userChrome.css');
                end;

              // restoration of extension files
              Obnoveni_ext (zipFactory);

              // Modifications
              ModifChrome;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_EXTENSIONS_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;

          // cache
          if (Form1.CheckBox15.Checked = true) and (Form1.Typ_programu <> 1) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('TForm1', 'LANG_CACHE1'));

              zipFactory.extractDirectory('cache', '*.*');
              zipFactory.extractDirectory('OfflineCache', '*.*');
              zipFactory.extractDirectory('indexedDB', '*.*');
              zipFactory.extractDirectory('thumbnails', '*.*');

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_CACHE_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            

          if (Form1.UnknowFiles.Count > 0) then
            begin
              Form1.StaticText6.Caption:= (Config.l10n.getL10nString ('MozBackup14', 'LANG_UNKNOW'));

              for I := 0 to UnknowFilesFM.CheckListBox1.Items.Count - 1 do
                begin
                  if UnknowFilesFM.CheckListBox1.Checked[i] then
                    begin
                      filename:= (TUnknowItem(Form1.UnknowFiles[i])).getFilename();
                      isDirectory:= (TUnknowItem(Form1.UnknowFiles[i])).isDirectory();

                      if not isDirectory then
                        begin
                          zipFactory.extractFile(filename);
                        end
                      else
                        begin
                          zipFactory.extractDirectory(filename, '*.*');
                        end;
                    end;
                end;

              Form1.ListBox3.Items.Add(Config.l10n.getL10nString ('MozBackup14', 'LANG_AKCE_UNKNOW_R_OK'));
            end;
          Form1.ProgressBar1.Position:= Form1.ProgressBar1.Position + 10;            
          Form1.ProgressBar1.Max:= 100;

        end;

        // correct file prefs.js
       // CorrectPrefs;

        // deletion of unnecessary files from prefs.js
        VymazPrefs;
            
          //end;
      except
       // an exception occurred
       on E:EInOutError do
         begin
          Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_KONEC')),
            pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
          ShowMessage (IntToStr (E.ErrorCode) + ': ' + E.Message);
          Halt (1);
         end;
        end;
    end
  else
    begin
      Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_NOT_FOUND_FILE')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_QUESTION')), MB_OK + MB_ICONQUESTION);
      Halt (1);
    end;
    
  // move to window 6
  Okno6;
end;


//******************************************************************************
// function PravostProfilu
//
// - detects whether the directory contains a valid Mozilla profile
//
// Input: directory - the directory containing the profile
// Output: - information on whether it is a valid profile or not
//******************************************************************************

function PravostProfilu (Adresar: string): boolean;
begin
  if FileExists (Adresar + '\' + 'prefs.js') = false then Result:= false else Result:= true; 
end;


//******************************************************************************
// procedure VytvorAdresar
//
// - creates the necessary directories in the given path
//
// Input: S - the path
//******************************************************************************

procedure VytvorAdresar (S: string);
var Adresar: string;
    I: byte;
begin
  Adresar:= '';
  for I:= 1 to Length (S) do
    begin
      if S[i] <> '\' then Adresar:= Adresar + S[i]
      else
        begin
          try
            if DirectoryExists (Form1.Slozka_data + '\' + Adresar) = false
            then CreateDir (Form1.Slozka_data + '\' + Adresar);
            Adresar:= Adresar + '\';
          except
            on E:EInOutError do
              begin
                Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_DIR_ERROR')), pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
                Halt (1);
              end;
          end;
        end;
    end;
end;


//******************************************************************************
// procedure Zalohovani_ext
//
// - backup of extension components
//******************************************************************************

procedure Zalohovani_ext (zipFactory: TZipFactory);
begin
  // Adblock Plus
  backupTask.addDirectory('adblockplus', '*.*');

  // Bookmarks Synchronizer
  backupTask.addFile('bookmarks.xml');

  // Clippings
  backupTask.addFile('clipdat.rdf');

  // ColorZilla
  backupTask.addDirectory('colorzilla', '*.*');

  // Crash Recovery
  backupTask.addFile('crashrecovery.dat');

  // Google Toolbar
  backupTask.addDirectory('GoogleToolbarData', '*.*');

  // Greasemonkey
  backupTask.addDirectory('gm_scripts', '*.*');

  // ForecastFox
  backupTask.addDirectory('forecastfox', '*.*');

  // ChatZilla
  backupTask.addDirectory('ChatZilla', '*.*');

  // Lightning
  backupTask.addFile('storage.sdb');
  backupTask.addDirectory('calendar-data', '*.*');  

  // Menu editor
  backupTask.addFile('menuedit.rdf');

  // Mouse Gestures
  backupTask.addFile('mousegestures.rdf');  

  // Prebar
  backupTask.addFile('prefbar.rdf');  

  // ScrapBook
  backupTask.addDirectory('ScrapBook', '*.*');

  // Stylish
  backupTask.addFile('stylish.rdf');

  // Tab Mix Plus
  backupTask.addFile('session.rdf');  

  // Tabbrowser Extensions
  backupTask.addFile('tabextensions.js');  
  backupTask.addFile('tabextensions.rdf');

  // View Source With
  backupTask.addFile('viewSource.xml');
end;




//******************************************************************************
// procedure TestBackupFile
//
// - tests if the resulting file is a valid ZIP file
//******************************************************************************

procedure TestBackupFile (zipFactory: TZipFactory);
begin
  try
    // As a test, the prefs.js file is unpacked
    zipFactory.extractFile('indexfile.txt', GetEnvironmentVariable('TEMP'));

    if not (FileExists (GetEnvironmentVariable('TEMP') + '\indexfile.txt')) then
      begin
        Application.MessageBox (pchar (Config.l10n.getL10nString ('MozBackup14', 'LANG_INVALID_OUTPUT')),
                                pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
        SysUtils.DeleteFile (Form1.Vyst_soubor);
        Form1.BackupFailed:= true;
      end
    else
      begin
        SysUtils.DeleteFile(GetEnvironmentVariable('TEMP') + '\indexfile.txt');
      end;
   except
     on E:EInOutError do
       begin
          if (FileExists (GetEnvironmentVariable('TEMP') + '\indexfile.txt')) then SysUtils.DeleteFile(GetEnvironmentVariable('TEMP') + '\indexfile.txt');
          Application.MessageBox (pchar (Config.l10n.getL10nString ('MozBackup14', 'LANG_INVALID_OUTPUT')),
                                  pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
          SysUtils.DeleteFile (Form1.Vyst_soubor);
          Form1.BackupFailed:= true;
       end;
   end;
end;

procedure BackupMail (zipFactory: TZipFactory; onlySettings: boolean);
var prefsParser: TPrefsParser;
    mailAccounts: TList;
    i, j, k: Integer;
    prefsParserAccount: TPrefsParserAccount;
    directory: String;
    s: string;
begin
  // Backup mailboxes which are in standard location in profile directory
  if not onlySettings then
    begin
      backupTask.addDirectory('ImapMail', '*.*');
      backupTask.addDirectory('Mail', '*.*');
      backupTask.addDirectory('News', '*.*');
    end
  else
    begin
      backupTask.addDirectory('Mail', '*.dat');
      backupTask.addDirectory('Mail', '*.rdf');
      backupTask.addDirectory('ImapMail', '*.dat');
      backupTask.addDirectory('ImapMail', '*.rdf');
      backupTask.addDirectory('News', '*.msf');
      backupTask.addDirectory('News', '*.rc');
    end;

  // Backup mailboxes which are in non-standard locations (outside profile directory)
  prefsParser:= TPrefsParser.Create(Form1.Slozka_data + 'prefs.js');
  mailAccounts:= prefsParser.getMailAccounts();

  for i := 0 to mailAccounts.Count - 1 do
    begin
      prefsParserAccount:= TPrefsParserAccount(mailAccounts[i]);
      directory:= prefsParserAccount.getExistAccountDirectory();
      directory:= AnsiReplaceStr(directory, '/', '\');

      if Length (Directory) > 0 then
        begin
          if prefsParserAccount.isExternalMailBox then
            begin
              j:= 0; s:= directory;
              for k:= 1 to Length (s) do
                begin
                  if s[k] = '\' then j:= k;
                end;
              Delete (s, 1, j);

              // Adding to the list of external paths
              Form1.Extern_ucty[Form1.Pocet_extern]:= directory;
              Form1.Pocet_extern:= Form1.Pocet_extern + 1;

              Delete (directory, J+1, Length (directory) - J);

              if not onlySettings then
                begin
                  backupTask.addDirectory(s, '*.*', directory);
                end
              else
                begin
                  backupTask.addDirectory(s, '*.dat', directory);
                  backupTask.addDirectory(s, '*.rdf', directory);
                  backupTask.addDirectory(s, '*.msf', directory);
                  backupTask.addDirectory(s, '*.rc', directory);
                end;
            end;
        end;
    end;
end;


// Perform backup of mail boxes
procedure BackupMailBoxs (zipFactory: TZipFactory; onlySettings: boolean);
var prefsParser: TPrefsParser;
    mailAccounts: TList;
    i, j, k: Integer;
    prefsParserAccount: TPrefsParserAccount;
    directory: String;
    s: String;
begin
  prefsParser:= TPrefsParser.Create(Form1.Slozka_data + 'prefs.js');
  mailAccounts:= prefsParser.getMailAccounts();

  for i := 0 to mailAccounts.Count - 1 do
    begin
      prefsParserAccount:= TPrefsParserAccount(mailAccounts[i]);
      directory:= prefsParserAccount.getExistAccountDirectory();
      directory:= AnsiReplaceStr(directory, '/', '\');

      if Length (Directory) > 0 then
        begin
          if not prefsParserAccount.isExternalMailBox then
            begin
              // Remove the unnecessary part of the path -> convert absolute to relative
              Delete (directory, 1, Length (Form1.Slozka_data));

              if not onlySettings then
                 backupTask.addDirectory(directory, '*.*');
              Application.ProcessMessages;

              // If it is about discussion groups, perform backup of configuration files
              if prefsParserAccount.getAccountType = 'nntp' then
                begin
                  // Find the last slash and trim the path at that point
                  s:= directory;
                  j:= 0;
                  for k:=1 to Length (s) do
                    begin
                      if S[k] = '\' then j:= k;
                    end;
                  s:= Copy (s, 1, j);

                  backupTask.addDirectory(s, '*.msf');
                  backupTask.addDirectory(s, '*.rc');
                end;
            end
          else
            begin
              // It is an external email
              j:= 0; s:= directory;
              for k:= 1 to Length (s) do
                begin
                  if s[k] = '\' then j:= k;
                end;
              Delete (s, 1, j);

              // Adding to the list of external paths
              Form1.Extern_ucty[Form1.Pocet_extern]:= directory;
              Form1.Pocet_extern:= Form1.Pocet_extern + 1;

              Delete (directory, J+1, Length (directory) - J);

              if not onlySettings then
                backupTask.addDirectory(s, '*.*', directory);
            end;
        end
      else
        begin
          Application.MessageBox (pchar (Config.l10n.getL10nString ('MozBackup14', 'LANG_MAILBOX_BACKUP_PROBLEM') + directory),
          pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
        end;      
    end;
end;



//******************************************************************************
// procedure BackupProfile
//
// - backs up the profile
//******************************************************************************

procedure Zalohovani;
var zipFactory: TZipFactory;
    fileList: TStringList;
    unknowFilesBL: TUnknowFilesBL;
    unknowItems: TList;
    i: integer;
    filename: String;
    isDirectory: boolean;
    unknowFilesList: TList;
begin
  try
    // resetting external accounts
    Form1.Pocet_extern:= 1;
    Form1.BackupFailed:= false;

    if PravostProfilu (Form1.Slozka_data) then
      begin
        // does a file with the same name exist?
        if FileExists (Form1.Vyst_soubor) then SysUtils.DeleteFile (Form1.Vyst_soubor);

        // instantion of backup task
        backupTask:= TBackupTask.Create(Form1.Slozka_data);

        // ** Beginning of backup. A ZIP file will be created
        zipFactory:= TZipFactory.Create(Form1.Vyst_soubor, Form1.Slozka_data, Form1.Password);

        fileList:= TStringList.Create;

        // ** Backup of general settings
        if (Form1.CheckBox1.Checked) and (FileExists (Form1.Slozka_data + 'prefs.js')) then
          begin
            backupTask.addFile('prefs.js');
            backupTask.addFile('user.js');            
            backupTask.addFile('cookperm.txt');
            backupTask.addFile('hostperm.1');
            backupTask.addFile('permissions.sqlite');
            backupTask.addFile('mimeTypes.rdf');
            backupTask.addFile('ac-weights.txt');
            backupTask.addFile('localstore.rdf');
            backupTask.addFile('localstore-safe.rdf');
            backupTask.addFile('persdict.dat');
            backupTask.addFile('search.rdf');
            backupTask.addFile('search.json');
            backupTask.addFile('search.sqlite');
            backupTask.addFile('listing-downloaded.xml');
            backupTask.addFile('listing-uploaded.xml');
            backupTask.addFile('sessionstore.js');
            backupTask.addFile('sessionstore.json');
            backupTask.addFile('urlclassifier.sqlite');
            backupTask.addFile('urlclassifier2.sqlite');
            backupTask.addFile('urlclassifier3.sqlite');
            backupTask.addFile('urlclassifierkey3.txt');
            backupTask.addFile('urlclassifierkey4.txt');
            backupTask.addFile('kf.txt');
            backupTask.addFile('webappsstore.sqlite');
            backupTask.addFile('blocklist.xml');
            backupTask.addFile('metrics.xml');
            backupTask.addFile('metrics-config.xml');
            backupTask.addFile('content-prefs.sqlite');
            backupTask.addFile('session.json');
            backupTask.addFile('chromeappsstore.sqlite');
            backupTask.addFile('search-metadata.json');


            backupTask.addDirectory('microsummary-generators', '*.*');
            backupTask.addDirectory('weave', '*.*');
          end;

        // ** Backup of contacts
        if Form1.CheckBox3.Checked then
          begin
            backupTask.addDirectory('Photos', '*.*');
            backupTask.addDirectory('.', '*.mab');
          end;

        // ** Backup of bookmarks
        if Form1.CheckBox4.Checked then
          begin
            backupTask.addFile('bookmarks.html');
            backupTask.addFile('bookmarks.bak');
            backupTask.addFile('bookmarks_history.sqlite');
            backupTask.addFile('places.sqlite');
            backupTask.addFile('places.sqlite-journal');
            backupTask.addFile('bookmarks.postplaces.html');
            backupTask.addFile('bookmarks.preplaces.html');

            backupTask.addDirectory('bookmarkbackups', '*.*');
          end;

        // ** Backup of history
        if Form1.CheckBox5.Checked then
          begin
            backupTask.addFile('history.dat');
            backupTask.addFile('bookmarks_history.sqlite');
            backupTask.addFile('places.sqlite');
            backupTask.addFile('url-data.txt');
            backupTask.addFile('urlbarhistory.sqlite');
          end;

        // ** Backup of sidebar panels
        if Form1.CheckBox6.Checked then
          begin
            backupTask.addFile('panels.rdf');
          end;

        // ** Backup of user styles
        if Form1.CheckBox8.Checked then
          begin
            backupTask.addFile('chrome\userContent.css');
            backupTask.addFile('chrome\userChrome.css');
          end;

        // ** Backup of saved passwords
        if Form1.CheckBox9.Checked then
          begin
            backupTask.addFile('signons.txt');
            backupTask.addFile('signons2.txt');
            backupTask.addFile('signons3.txt');
            backupTask.addFile('signons4.txt');
            backupTask.addFile('signons5.txt');
            backupTask.addFile('signons.sqlite');
            backupTask.addFile('key3.db');

            backupTask.addDirectory('.', '*.s');
          end;

        // ** cookies
        if Form1.CheckBox10.Checked then
          begin
            backupTask.addFile('cookies.txt');
            backupTask.addFile('cookies.sqlite');
          end;

        // ** Backup of filled forms
        if Form1.CheckBox11.Checked then
          begin
            backupTask.addFile('formhistory.dat');
            backupTask.addFile('URL.tbl');
            backupTask.addFile('formhistory.sqlite');

            backupTask.addDirectory('.', '*.w');
          end;


        // ** Backup of download manager
        if Form1.CheckBox12.Checked then
          begin
            backupTask.addFile('downloads.sqlite');
            backupTask.addFile('downloads.rdf');
          end;


        // ** certificates
        if Form1.CheckBox13.Checked then
          begin
            backupTask.addFile('cert7.db');
            backupTask.addFile('cert8.db');
            backupTask.addFile('key3.db');
            backupTask.addFile('secmod.db');
            backupTask.addFile('cert_override.txt');

            backupTask.addDirectory('cert7.dir', '*.*');
            backupTask.addDirectory('cert8.dir', '*.*');
          end;

        // extensions
        if Form1.CheckBox14.Checked then
          begin
            backupTask.addFile('extensions.rdf');
            backupTask.addFile('extensions.sqlite');            
            backupTask.addFile('extensions.log');
            backupTask.addFile('addons.sqlite');
            backupTask.addFile('lightweighttheme-footer');
            backupTask.addFile('lightweighttheme-header');
            backupTask.addFile('applications.sqlite');

            backupTask.addDirectory('extensions', '*.*');
            backupTask.addDirectory('chrome', '*.*');
            backupTask.addDirectory('searchplugins', '*.*');

            // ** Backup of extensions
            Zalohovani_ext (zipFactory);
          end;

        // Disk storage
        if Form1.CheckBox15.Checked then
          begin
            backupTask.addDirectory('cache', '*.*');
            backupTask.addDirectory('OfflineCache', '*.*');
            backupTask.addDirectory('thumbnails', '*.*');
            backupTask.addDirectory('indexedDB', '*.*');
          end;

        // ** mail
        if Form1.CheckBox2.Checked or Form1.CheckBox7.Checked then
          begin
            backupTask.addFile('prefs.js');
            backupTask.addFile('mailViews.dat');
            backupTask.addFile('panacea.dat');
            backupTask.addFile('training.dat');
            backupTask.addFile('virtualFolders.dat');
            backupTask.addFile('folderTree.json');
            backupTask.addFile('traits.dat');
            backupTask.addFile('mailsessionstore.js');
            backupTask.addFile('msgfti.sqlite');
            backupTask.addFile('junklog.html');

            if not Form1.CheckBox7.Checked then
              begin
                backupTask.addFile('global-messages-db.sqlite');
              end;

            BackupMail (zipFactory, Form1.CheckBox7.Checked);
          end;

        // ** Unknow files
        unknowFilesBL:= TUnknowFilesBL.Create();
        unknowItems:= unknowFilesBL.getUnknowFiles(Form1.Slozka_data);
        unknowFilesList:= TList.Create ();

        if UnknowFilesFM.CheckListBox1.Items.Count > 0 then
          begin
            for I := 0 to UnknowFilesFM.CheckListBox1.Items.Count - 1 do
              begin

                if UnknowFilesFM.CheckListBox1.Checked[i] then
                  begin
                    filename:= (TUnknowItem(unknowItems[i])).getFilename();
                    isDirectory:= (TUnknowItem(unknowItems[i])).isDirectory();

                    if not isDirectory then
                      begin
                        backupTask.addFile(filename);
                        unknowFilesList.Add(TUnknowItem.Create (filename, false));
                      end
                    else
                      begin
                        backupTask.addDirectory(filename, '*.*');
                        unknowFilesList.Add(TUnknowItem.Create (filename, true));
                     end;
                  end;
              end;
          end;

       // ** Creation of the index file
       CreateFileHeader (unknowFilesList);

       // Backup
       zipFactory.addBackupTask (backupTask);

      // ** Performing a test to check if the resulting PCV file is valid
      // TODO: Temporary hack
       if not IsRunCommandLineVersion() then
         begin
           TestBackupFile (zipFactory);
         end;
       SysUtils.DeleteFile (Form1.Slozka_data + 'indexfile.txt');

      end

  except
     on E:EInOutError do
       begin
        Application.MessageBox (pchar (Config.l10n.getL10nString ('TForm1', 'LANG_KONEC')),
              pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONWARNING);
        ShowMessage (E.Message);
        Halt (1);
       end;
     on E:Exception do
       begin
         ShowMessage (E.Message);
         Halt (1);
       end;
  end;

  // move to the last page of the program
  Okno6;
end;

end.

