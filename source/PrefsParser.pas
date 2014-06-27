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

unit PrefsParser;

interface

uses Classes;

type TPrefsParser = class
  private
    // path to prefs.js
    prefsFilePath: String;
    mailAccounts: TList;

    procedure parseConfigFile ();
    procedure addMailAccountValue (id: Integer; typ: Integer; value: String);
    procedure handleLine (key: String; value: String);
    procedure handleLineMail (key: String; value: String);
  protected
  public
    constructor Create (filename: String); overload;
    constructor Create (filename: String; parse:boolean); overload;
    destructor Destroy(); override;
    function getStrAfterQuote(str: String):String;
    function getStrBetweenQuote(str: String):String;
    function getPref(line: String):String;
    function getPrefValue (line: String):String;
    function getValueObject (str: String):String;
    function setPrefValue (line: String; newValue: String):String;
        
    function getMailAccounts():TList;
end;

implementation

// TODO: add test integrity of prefs.js

uses Config, PrefsParserAccount, SysUtils, Utils, dialogs, StrUtils;

constructor TPrefsParser.Create (filename: String);
begin
  Create (filename, true);
end;

constructor TPrefsParser.Create (filename: String; parse:boolean);
begin
  self.prefsFilePath:= filename;
  mailAccounts:= TList.Create;

  if parse then
    begin
      parseConfigFile ();
    end;
end;

destructor TPrefsParser.Destroy;
begin
  clearList(mailAccounts);
end;

// vrátí øetìzec za uvozovkami nebo prázdný øetìzec, pokud tam už nic není
function TPrefsParser.getStrAfterQuote(str: String):String;
var position: Integer;
begin
  if Length(str) = 0 then
    begin
      Result:= '';
    end
  else
    begin
      position:= Pos ('"', str);
      if position > 0 then
        begin
          position:= position + 1;
          Result:= Copy (str, position, Length (str) - position + 1);
        end
      else
        begin
          Result:= '';
        end;
    end;
end;

// vrátí øetìzec, který je do první uvozovky v øetìzci
function TPrefsParser.getStrBetweenQuote(str: String):String;
var position: Integer;
    rPosition: Integer;
begin
  Result:= '';

  if (Length (str) > 0) then
    begin
      position:= Pos ('"', str);
      if position > 0 then
        begin
          rPosition:= position - 1;
          Result:= Copy (str, 0, rPosition);
        end;
    end;
end;

// vrátí hodnotu ke klíèi. Tato hodnota není v uvozovkách, takže
// se typicky jedná o èíslo, boolean hodnotu apod.
function TPrefsParser.getValueObject (str: String):String;
var position: Integer;
    rPosition: Integer;
begin
  Result:= '';
  if (Length (str) > 0) then
    begin
      position:= Pos (',', str);
      if position > 0 then
        begin
          rPosition:= Pos (')', str);
          if rPosition > 0 then
            begin
              position:= position + 1;
              Result:= Copy (str, position, rPosition - position);
            end;
        end;
    end;  
end;

// vrátí pøedvolbu
function TPrefsParser.getPref(line: String):String;
begin
  Result:= '';

  line:= getStrAfterQuote (line);
  Result:= getStrBetweenQuote (line);
end;

// vrátí hodnotu pøedvolby
function TPrefsParser.getPrefValue(line: String):String;
var value: String;
begin
  Result:= '';

  line:= getStrAfterQuote (line);
  line:= getStrAfterQuote (line);
  value:= getStrAfterQuote (line);
  value:= getStrBetweenQuote (value);

  // pokud má øetìzec nulovou velikost, není pravdìpodobnì hodnota v uvozovkách
  if Length (value) = 0 then
    begin
      value:= getValueObject (line);
    end;

  Result:= value;
end;

procedure TPrefsParser.parseConfigFile;
var f: TextFile;
    s: String;
    pref: String;
    prefValue: String;
begin
  // if prefs.js not found, create exception
  if not FileExists (prefsFilePath) then
    begin
      raise Exception.Create(Config.l10n.getL10nString ('LANG_DIRECTORY', 'LANG_PREFS_JS_NOT_FOUND'));
    end;

  AssignFile (f, prefsFilePath);
  Reset (f);
  Repeat
    Readln (f, s);
    pref:= getPref(s);
    prefValue:= getPrefValue(s);

    if (Length (pref) > 0) and (Length (prefValue) > 0) then
      begin
        handleLine (pref, prefValue);
      end;
  Until Eof (f);
  CloseFile (f);
end;

// provede zpracování øádky
procedure TPrefsParser.handleLine(key: string; value: string);
begin
  // jedná se o øádek pošty
  if Pos('mail.server.server', key) = 1  then
    begin
      handleLineMail (key, value);
    end;   
end;

// provede zpracování øádku s poštou
procedure TPrefsParser.handleLineMail(key: string; value: string);
var id: Integer;
    position: Integer;
begin
  // získá se id úètu
  id:= 0;
  Delete (key, 1, Length('mail.server.server'));  
  position:= Pos ('.', key);
  if position > 0 then
    begin
      try
        id:= StrToInt(Copy (key, 1, position - 1));
      Except
        on E : EConvertError  do
          begin
            // TODO:
          end;
      end;
    end;

  if id > 0 then
    begin
      // nalezen typ úètu
      if Pos ('.type', key) > 0 then
        begin
          addMailAccountValue (id, 1, value);          
        end;      

      // nalezena absolutní cesta k adresáøi
      if (Pos ('.directory', key) > 0) and (Pos ('.directory-rel', key) = 0)  then
        begin
          addMailAccountValue (id, 2, value);
        end;

      // nalezena relativní cesta k adresáøi
      if Pos ('.directory-rel', key) > 0 then
        begin
          addMailAccountValue (id, 3, value);        
        end;

      // znaková sada
      if Pos ('.charset', key) > 0 then
        begin
          addMailAccountValue (id, 4, value);        
        end;

      // newsrc u diskusní skupiny
      if Pos ('.newsrc.file', key) > 0 then
        begin
          addMailAccountValue (id, 5, value);        
        end;      
    end;
end;

procedure TPrefsParser.addMailAccountValue (id: Integer; typ: Integer; value: String);
var i: Integer;
    found: boolean;
    selectedAccount: TPrefsParserAccount;
    isExternal: boolean;
    S: String;
begin
  // Pokud e-mailový úèet neexistuje v listu, pak se tam pøidá
  found:= false;
  selectedAccount:= nil;
  for I := 0 to mailAccounts.Count - 1 do
    begin
      if TPrefsParserAccount (mailAccounts[i]).getId = id then
        begin
          selectedAccount:= mailAccounts[i];
          found:= true;
        end;
    end;

  if not found then
    begin
      selectedAccount:= TPrefsParserAccount.Create(id);
      mailAccounts.Add(selectedAccount);
    end;

  case typ of
    1: selectedAccount.setAccountType(value);
    2: begin
         s:= AnsiReplaceStr (value, '\\', '\');
         s:= Utf8ToAnsi(s);
         isExternal:= (Pos (ExtractFileDir(prefsFilePath), s) = 0);         
         selectedAccount.setAccountPath(s);
         selectedAccount.setExternalMailBox(isExternal);
       end;
    3: selectedAccount.setAccountRelativePath(Utf8ToAnsi(value));
    4: selectedAccount.setCharset(value);
    5: selectedAccount.setNewsrc(value);
  end;
end;

function TPrefsParser.setPrefValue (line: String; newValue: String):String;
var s: String;
    lPosition: integer;
begin
  // najde se carka
  lPosition:= Pos (',', line);
  s:= Copy (line, 1, lPosition);
  line:= Copy (line, lPosition + 1, Length (line) - lPosition - 1);

  // najde se uvozovka
  lPosition:= Pos ('"', line);
  s:= s + Copy (line, 1, lPosition);

  // nastavi se nova hodnota a ukonci se radek
  s:= s + newValue + '");';

  Result:= S;
end;

function TPrefsParser.getMailAccounts():TList;
begin
  Result:= mailAccounts;
end;

end.

