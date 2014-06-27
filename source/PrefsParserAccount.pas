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

unit PrefsParserAccount;

interface

uses hlavni; // just for now, remove later

type TPrefsParserAccount = class
  private
    id: Integer;
    accountType: String;
    accountPath: String;
    accountRelativePath: String;
    charset: String;
    externalMailBox: boolean;
    newsrc: String;

    function getExistAcountDirectoryFromPath(MailBoxDirectory:String):String;
  protected
  public
    constructor Create (id: Integer);

    function getId():Integer;
    function getAccountType():String;
    function getAccountPath():String;
    function getAccountRelativePath():String;
    function getCharset():String;
    function isExternalMailBox():boolean;
    function getNewsrc():String;
    function getExistAccountDirectory():String;

    procedure setId(id: Integer);
    procedure setAccountType(accountType: String);
    procedure setAccountPath(accountPath: String);
    procedure setAccountRelativePath(accountRelativePath: String);
    procedure setCharset(charset: String);
    procedure setExternalMailBox(externalMailBox:boolean);
    procedure setNewsrc(newsrc: String);
end;

implementation

uses Dialogs, StrUtils, SysUtils;

constructor TPrefsParserAccount.Create(id: Integer);
begin
  self.id:= id;
end;

function TPrefsParserAccount.getId():Integer;
begin
  Result:= id;
end;

function TPrefsParserAccount.getAccountType():String;
begin
  Result:= accountType;
end;

function TPrefsParserAccount.getAccountPath():String;
begin
  Result:= accountPath;
end;

function TPrefsParserAccount.getAccountRelativePath():String;
begin
  Result:= accountRelativePath;
end;

function TPrefsParserAccount.getCharset():String;
begin
  Result:= charset;
end;

function TPrefsParserAccount.isExternalMailBox;
begin
  Result:= externalMailBox;
end;

function TPrefsParserAccount.getNewsrc():String;
begin
  Result:= newsrc;
end;

procedure TPrefsParserAccount.setId(id: Integer);
begin
  self.id:= id;
end;

procedure TPrefsParserAccount.setAccountType(accountType: String);
begin
  self.accountType:= accountType;
end;

procedure TPrefsParserAccount.setAccountPath(accountPath: String);
begin
  self.accountPath:= accountPath;
end;

procedure TPrefsParserAccount.setAccountRelativePath(accountRelativePath: String);
begin
  self.accountRelativePath:= accountRelativePath;
end;

procedure TPrefsParserAccount.setCharset(charset: string);
begin
  self.charset:= charset;
end;

procedure TPrefsParserAccount.setExternalMailBox(externalMailBox: Boolean);
begin
  self.externalMailBox:= externalMailBox; 
end;

procedure TPrefsParserAccount.setNewsrc(newsrc: string);
begin
  self.newsrc:= newsrc;
end;

function TPrefsParserAccount.getExistAcountDirectoryFromPath(MailBoxDirectory: String):String;
begin
  Result:= '';

  if DirectoryExists(MailBoxDirectory) then
    begin
      Result:= MailBoxDirectory;
    end
  else
    begin
      MailBoxDirectory:= Utf8ToAnsi (MailBoxDirectory);
      if DirectoryExists (MailBoxDirectory) then
        begin
          Result:= MailBoxDirectory; 
        end;      
    end;
end;


function TPrefsParserAccount.getExistAccountDirectory(): String;
var ProfileDirectory: String;
    MailBoxDirectory: String;
    S: String;
begin
  Result:= '';

  // TODO: Just for now, remove later
  ProfileDirectory:= Form1.Slozka_data;

  // get exist mailbox folder from relative path
  MailBoxDirectory:= getAccountRelativePath();
  MailBoxDirectory:= StringReplace (MailBoxDirectory, '[ProfD]', ProfileDirectory + '/', []);
  S:= getExistAcountDirectoryFromPath(MailBoxDirectory);

  if Length (S) > 0 then
    begin
      Result:= S;
    end
  else
    begin
      // get exist maildir folder from absolute path
      MailBoxDirectory:= getAccountPath();
      MailBoxDirectory:= AnsiReplaceStr (MailBoxDirectory, '\\', '\');
      Result:= getExistAcountDirectoryFromPath (MailBoxDirectory);
    end;
end;

end.
