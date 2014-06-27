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

unit SunbirdApp;

interface

uses Dialogs, Hlavni, Funkce, MozApp, Registry, Windows;

type TSunbirdApp = class(TMozApp)
  private
    // TODO: temporary
    Registr: TRegistry;
  protected
    procedure init; override;
  public
    procedure searchApplication; override;
end;

implementation

uses Classes;

{ Search application in system }
procedure TSunbirdApp.searchApplication();
begin
  Registr:= TRegistry.Create;
  Registr.Access:= KEY_READ;
  Registr.RootKey:= HKEY_LOCAL_MACHINE;

  // called function need rewrite
  SearchProgram (Registr, 'SOFTWARE\mozilla\Mozilla Sunbird', 'CurrentVersion', 4, 0, true);
  SearchDirectory (Registr, 'SOFTWARE\mozilla\Mozilla Sunbird\'+ Programy[4].Verze + '\Main', 'Install Directory', 2);

  if Programy[4].Nalezen then
    begin
      found:= true;
      version:= Programy[4].Verze;
      pathToApplication:= Programy[4].Cesta;
    end
  else
    begin
      found:= false;
    end;

  Registr.CloseKey;
  Registr.Destroy;
end;


procedure TSunbirdApp.init;
var stringList: TStringList;
begin
  id:= 4;
  name:= 'Mozilla Sunbird';
  shortName:= 'sunbird';

  stringList:= TStringList.Create;
  stringList.Add('[AppData]\Mozilla\Sunbird');
  profilesLocations:= stringList;

  stringList:= TStringList.Create;
  stringList.Add('sunbird.exe');
  exeNames:= stringList;
end;

end.
