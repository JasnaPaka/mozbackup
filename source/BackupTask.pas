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

unit BackupTask;

interface

uses Classes, Dialogs, Forms, IdGlobalProtocols, SysUtils, Windows,
// own
BackupTaskExternal, Hlavni, ProgressWindow;

type TBackupTask = class(TObject)
  private
    profileDirectory: String;
    files: TStringList;
    externalFiles: TList;    
    filesSize: int64;
  protected
  public
    constructor Create (ProfileDirectory: String);
    
    procedure addFile(relativePath: String); overload;
    procedure addFile(RelativePath: string; AbsolutePath: String); overload;
    procedure addDirectory(directory: String; Mask: String); overload;
    procedure addDirectory(directory: String; Mask: String; Path: String); overload;    

    function getFiles():TStringList;
    function getExternalFiles:TList;
    function getFilesSize():int64;
end;

implementation

//************************ Private *******************************************


//************************ Public *******************************************

constructor TBackupTask.Create (ProfileDirectory: String);
begin
  self.profileDirectory:= ProfileDirectory;
  files:= TStringList.Create;
  externalFiles:= TList.Create;
  filesSize:= 0;
end;

procedure TBackupTask.addFile(RelativePath: string);
var fullPath: String;
begin
  fullPath:= profileDirectory + '\' + RelativePath;

  if FileExists(fullPath) then
    begin
      files.Add(relativePath);
      filesSize:= filesSize + FileSizeByName (profileDirectory + '\' + RelativePath);
    end;     
end;

procedure TBackupTask.addFile(RelativePath: string; AbsolutePath: String);
var fullPath: String;
begin
  fullPath:= AbsolutePath + '\' + RelativePath;
  if FileExists(fullPath) then
    begin
      externalFiles.Add(TBackupTaskExternal.Create (AbsolutePath, RelativePath));
      filesSize:= filesSize + FileSizeByName (AbsolutePath + '\' + RelativePath);
    end;
end;

function TBackupTask.getFiles():TStringList;
begin
  Result:= files;
end;

function TBackupTask.getExternalFiles:TList;
begin
  Result:= externalFiles;
end;

function TBackupTask.getFilesSize():int64;
begin
  Result:= filesSize;
end;

procedure TBackupTask.addDirectory(Directory: String; Mask: String);
begin
  addDirectory(Directory, Mask, profileDirectory);
end;

procedure TBackupTask.addDirectory(Directory: String; Mask: String; Path: String);
var SearchRec: TSearchRec;
begin
  if FindFirst (Path + Directory + '\' + Mask, faAnyFile, SearchRec) = 0 then
    begin
      Repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          begin
            if DirectoryExists (Path + Directory + '\' + SearchRec.Name) = true then
              begin
                Application.ProcessMessages;
                
                // TODO: better handling
                if Pos ('.mozmsgs', Directory + '\' + SearchRec.Name) = 0 then
                  begin
                    addDirectory (Directory + '\' + SearchRec.Name, Mask, Path);
                  end;
              end
            else if FileExists (Path + Directory + '\' + SearchRec.Name) = true then
              begin
                if Pos (Form1.Slozka_data, Path + Directory + '\' + SearchRec.Name) = 0 then
                  begin
                    addFile(Directory + '\' + SearchRec.Name, Path);
                  end
                else
                  begin
                    addFile(Directory + '\' + SearchRec.Name);
                  end;

              end;
          end;
      Until FindNext (SearchRec) <> 0;
    end
  else
    begin
      if Mask <> '*.*' then
        begin
          if FindFirst (Path + Directory + '\*.*', faAnyFile, SearchRec) = 0 then
            begin
              Repeat
                if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
                  begin
                    if DirectoryExists (Path + Directory + '\' + SearchRec.Name) = true then
                      begin
                        addDirectory (Directory + '\' + SearchRec.Name, Mask, Path);
                      end;
                  end;
              Until FindNext (SearchRec) <> 0;
            end;
        end;
    end;

  SysUtils.FindClose (SearchRec);
end;

end.
