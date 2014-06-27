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

{***************************************************************************
  MozProfile

  - this unit is for manipulation with MozBackup profile directory which is
    in path [appdata]/mozbackup
***************************************************************************}

unit MozProfile;

interface

procedure CreateProfileDirectory();
procedure ResetOperationLog();
procedure WriteMsgToErrorLog(msg:String);
procedure WriteMsgToOperationLog(msg:String);

implementation

uses Config, SysUtils, WinUtils;

{***************************************************************************
  procedure CreateFile

  - create file in profile
*****************************************************************************}
procedure CreateFile (pathToFile: String);
var F: TextFile;
begin
  if not FileExists (pathToFile) then
    begin
      AssignFile (F, pathToFile);
      Rewrite (F);
      CloseFile (F);
    end;
end;


{***************************************************************************
  procedure WriteToFile

  - write msg to file in profile
*****************************************************************************}
procedure WriteToFile (pathToFile: String; msg: String);
var F: TextFile;
begin
  AssignFile (F, pathToFile);
  Reset (F);
  Writeln (F, msg);
  CloseFile (F);
end;


{***************************************************************************
  procedure ResetOperationLog

  - clean operation log
*****************************************************************************}
procedure ResetOperationLog();
var F: TextFile;
    filePath: String;
begin
  filePath:= GetSpecialDir (11) + '\MozBackup\' + Config.OPERATION_LOG_FILENAME;

  AssignFile (F, filePath);
  Rewrite (F);
  CloseFile (F);
end;


{***************************************************************************
  procedure CreateProfileDirectory

  - create profile for MozBackup if this profile doesn't exists. This
    directory is in path [appdata]/MozBackup.
  - procedure raise exception when this directory cannot be created.
*****************************************************************************}
procedure CreateProfileDirectory();
var profileDirectory: String;
    bool: boolean;
begin
  profileDirectory:= GetSpecialDir (11) + '\MozBackup';
  if not DirectoryExists (profileDirectory) then
    begin
      bool:= CreateDir(profileDirectory);
      if bool = false then
        begin
          raise Exception.Create(Config.l10n.getL10nString ('MozBackup14', 'LANG_CANNOT_CREATE_PROFILE_DIR'));
        end;      
    end;  
end;


{***************************************************************************
  procedure WriteMsgToErrorLog

  - write message to error log
*****************************************************************************}
procedure WriteMsgToErrorLog(msg:String);
var filePath: String;
begin
  // create profile directory
  CreateProfileDirectory();

  // create log file if this file doesn't exist
  filePath:= GetSpecialDir (11) + '\MozBackup\' + Config.ERROR_LOG_FILENAME;
  CreateFile (filePath);

  // write msg to error log
  WriteToFile (filePath, msg);
end;

{***************************************************************************
  procedure WriteMsgToOperationLog

  - write message to operation log
*****************************************************************************}
procedure WriteMsgToOperationLog(msg:String);
var filePath: String;
begin
  // create profile directory
  CreateProfileDirectory();

  // create log file if this file doesn't exist
  filePath:= GetSpecialDir (11) + '\MozBackup\' + Config.OPERATION_LOG_FILENAME;
  CreateFile (filePath);

  // write msg to error log
  WriteToFile (filePath, msg);
end;

end.
