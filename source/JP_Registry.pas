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

unit JP_Registry;

interface

function LoadDirectory (Typ: byte): string;
function SaveDirectory (Cesta: string; Typ: byte): boolean;

implementation

uses Dialogs, SysUtils, Registry, Windows;

//******************************************************************************
// function LoadDirectory
//
// - loads the saved default directory from the registry
//******************************************************************************

function LoadDirectory (Typ: byte): string;
var Registr: TRegistry;
    Klic: string;
begin
  Result:= '';

  Registr:= TRegistry.Create;
  try
    Registr.Access:= KEY_READ;
    Registr.RootKey:= HKEY_CURRENT_USER;
    if Registr.OpenKey('Software\Mozilla Backup', false) then
      begin
        Klic:= 'Directory' + IntToStr (Typ);
        Result:= Trim(Registr.ReadString(Klic));
      end;
  except
    Registr.Free;
  end;

end;


//******************************************************************************
// function SaveDirectory
//
// - saves the default directory to the registry
//******************************************************************************

function SaveDirectory (Cesta: string; Typ: byte): boolean;
var Registr: TRegistry;
begin
  Result:= false;
  
  Registr:= TRegistry.Create;
  try
    Registr.Access:= KEY_Write;
    Registr.RootKey:= HKEY_CURRENT_USER;

    if Registr.OpenKey('Software', false) then
      begin
        if Registr.ValueExists('Mozilla Backup') = false then Registr.CreateKey ('Mozilla Backup');
        if Registr.OpenKey('Mozilla Backup', false) then
          begin
            case Typ of
               1: Registr.WriteString('Directory1', ExtractFilePath (Cesta));
               2: Registr.WriteString('Directory2', ExtractFilePath (Cesta));
               3: Registr.WriteString('Directory3', ExtractFilePath (Cesta));
               4: Registr.WriteString('Directory4', ExtractFilePath (Cesta));
               5: Registr.WriteString('Directory5', ExtractFilePath (Cesta));
               6: Registr.WriteString('Directory6', ExtractFilePath (Cesta));
               7: Registr.WriteString('Directory7', ExtractFilePath (Cesta));
               8: Registr.WriteString('Directory8', ExtractFilePath (Cesta));
               9: Registr.WriteString('Directory9', ExtractFilePath (Cesta));
               11: Registr.WriteString('Directory11', ExtractFilePath (Cesta));
               12: Registr.WriteString('Directory12', ExtractFilePath (Cesta));
            end;
            Result:= true;
          end;
      end;
    Registr.CloseKey;
    Registr.Destroy;
  except
    Registr.Free;
  end;
end;

end.
