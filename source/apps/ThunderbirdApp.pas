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

unit ThunderbirdApp;

interface

uses Dialogs, Hlavni, Funkce, MozApp, Registry, Windows;

type TThunderbirdApp = class(TMozApp)
  private
    // tempporary
    Registr: TRegistry;  
  protected
    procedure init; override;
    procedure searchApplication; override;
  public
end;

implementation

uses Classes;

//******************************** private methods *****************************

{ Search application in system }
procedure TThunderbirdApp.searchApplication();
begin
  Registr:= TRegistry.Create;
  Registr.Access:= KEY_READ;
  Registr.RootKey:= HKEY_LOCAL_MACHINE;

  // called function need rewrite
  SearchProgram (Registr, 'SOFTWARE\mozilla\Mozilla Thunderbird', 'CurrentVersion', 3, 0, false);
  SearchDirectory (Registr, 'SOFTWARE\mozilla\Mozilla Thunderbird\' + Programy[3].Verze + '\Main', 'Install Directory', 3);

  if Length (Programy[3].Cesta) = 0 then
    begin
      SearchProgram (Registr, 'SOFTWARE\mozilla.org\Mozilla Thunderbird', 'CurrentVersion', 3, 0, true);
      SearchDirectory (Registr, 'SOFTWARE\mozilla.org\Mozilla Thunderbird\' + Programy[3].Verze + '\Main', 'Install Directory', 3);
    end;

  if Programy[3].Nalezen then
    begin
      found:= true;
      version:= Programy[3].Verze;
      pathToApplication:= Programy[3].Cesta;
    end
  else
    begin
      found:= false;
    end;


  Registr.CloseKey;
  Registr.Destroy;
end;

//******************************** public methods ******************************


procedure TThunderbirdApp.init;
var stringList: TStringList;
begin
  id:= 3;
  name:= 'Mozilla Thunderbird';
  shortName:= 'thunderbird';

  stringList:= TStringList.Create;
  stringList.Add('[AppData]\Thunderbird');
  profilesLocations:= stringList;

  stringList:= TStringList.Create;
  stringList.Add('thunderbird.exe');
  exeNames:= stringList;
end;

end.
