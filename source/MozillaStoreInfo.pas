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

unit MozillaStoreInfo;

interface

type
  TMozillaStoreInfo = record
    IsStoreVersion: Boolean;
    Version: string;
    InstallLocation: string;
  end;

function GetMozillaStore(packageName:String): TMozillaStoreInfo;

implementation

uses
  System.SysUtils, System.Classes, Windows, ShellAPI;

function GetTempDir: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetTempPath(MAX_PATH, Buffer));
end;

function RunPowerShellAndWait(const CommandLine: string): Boolean;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: string;
begin
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;

  CmdLine := 'powershell -command ' + CommandLine;

  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, SI, PI);

  if Result then
  begin
    WaitForSingleObject(PI.hProcess, INFINITE);
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
  end;
end;

function GetMozillaStore(packageName: String): TMozillaStoreInfo;
var
  TmpFileName, PSCommand: string;
  OutputList: TStringList;
begin
  Result.IsStoreVersion := False;
  Result.Version := '';
  Result.InstallLocation := '';

  TmpFileName := IncludeTrailingPathDelimiter(GetTempDir) + 'ffstore.txt';

  PSCommand :=
    '"Get-AppxPackage -Name ' + packageName + ' | ' +
    'Select-Object Version, InstallLocation | ' +
    'Out-File -Encoding UTF8 ''' + TmpFileName + '''"';

  if RunPowerShellAndWait(PSCommand) and FileExists(TmpFileName) then
  begin
    OutputList := TStringList.Create;
    try
      OutputList.LoadFromFile(TmpFileName, TEncoding.UTF8);
      if OutputList.Count > 1 then
      begin
        Result.IsStoreVersion := True;
        for var Line in OutputList do
        begin
          if Pos('Version', Line) > 0 then
            Result.Version := Trim(Copy(Line, Pos(':', Line) + 1, MaxInt));
          if Pos('InstallLocation', Line) > 0 then
            Result.InstallLocation := Trim(Copy(Line, Pos(':', Line) + 1, MaxInt));
        end;
      end;
    finally
      OutputList.Free;
      DeleteFile(PChar(TmpFileName));
    end;
  end;
end;

end.
