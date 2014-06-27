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

unit Functions;

interface

uses PrefsParser, Classes, PrefsParserAccount, SysUtils;

procedure testPrefsLoader (PrefsParser: TPrefsParser; filename: String);

implementation

var accounts: TList;

procedure loadAccounts (filename: String);
var f: textfile;
    s: string;
    id: integer;
    path: String;
    accountType: String;
    account: TPrefsParserAccount;
    isExternal: boolean;
begin
  accounts:= TList.Create;

  Assign (F, filename);
  Reset (F);
  Repeat
    // id
    Readln (f, s);
    id:= StrToInt (s);

    // path
    Readln (f, s);
    path:= s;

    // accounttype
    Readln (f, s);
    accountType:= s;

    // isExternal
    //Readln (f, s);
    //isExternal:= StrToBool(s);

    account:= TPrefsParserAccount.Create(id);
    account.setAccountType(accountType);
    account.setAccountPath(path);
    //account.setExternalMailBox(isExternal);
    
    accounts.Add(account);
  until Eof (F);
  CloseFile (F);
end;

procedure compareValues (i: Integer; PrefsParser: TPrefsParser);
var prefsAccounts: TList;
    prefsAccount: TPrefsParserAccount;
    txtAccount: TPrefsParserAccount;
begin
  prefsAccounts:= PrefsParser.getMailAccounts;
  prefsAccount:= TPrefsParserAccount(prefsAccounts[i]);
  txtAccount:= TPrefsParserAccount(accounts[i]);

  if prefsAccount.getId() <> txtAccount.getId then
    begin
      Writeln ('- neshoduje se hodnota ID');
      Writeln ('Ocekavano: ' + IntToStr(prefsAccount.getId()));
      Writeln ('Nalezeno: ' + IntToStr(txtAccount.getId()));
    end;

  if prefsAccount.getAccountPath <> txtAccount.getAccountPath then
    begin
      Writeln ('- neshoduje se cesta k uctu');
      Writeln ('Ocekavano: ' + prefsAccount.getAccountPath());
      Writeln ('Nalezeno: ' + txtAccount.getAccountPath());
    end;

  if prefsAccount.getAccountType <> txtAccount.getAccountType then
    begin
      Writeln ('- neshoduje se typ uctu');
      Writeln ('Ocekavano: ' + prefsAccount.getAccountType());
      Writeln ('Nalezeno: ' + txtAccount.getAccountType());
    end;

  //if prefsAccount.isExternalMailBox <> txtAccount.isExternalMailBox then
  //  begin
      //Writeln ('- neshoduje se informace, zda je ucet externi');
//      Writeln ('Ocekavano: ' + BoolToStr(txtAccount.isExternalMailBox));
//      Writeln ('Nalezeno: ' + BoolToStr(txtAccount.isExternalMailBox));
   // end;       
end;

procedure testPrefsLoader (PrefsParser: TPrefsParser; filename: String);
var i: integer;
begin
  loadAccounts (filename);

  Writeln ('Zahajuji test souboru ' + filename);

  for i:= 0 to PrefsParser.getMailAccounts.Count - 1 do
    begin
      compareValues (i, PrefsParser);
    end;

  Writeln ('Ukoncuji test souboru ' + filename);    
end;

end.
