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

unit input_dialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms,
  Dialogs, StdCtrls, Controls;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Button3: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Potvrzeno: boolean;
  end;

var
  Form2: TForm2;

implementation

uses Config, funkce, hlavni, shellapi, shlObj, FileCtrl;

{$R *.dfm}

procedure TForm2.Button2Click(Sender: TObject);
begin
  Form2.Close;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Potvrzeno:= true;
  Form2.Close;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Form2.Font.Name:= Config.l10n.getDefaultFont();
  Form2.Font.Charset:=  Config.l10n.getDefaultCharset();
  Edit1.SetFocus;
end;

procedure TForm2.Button3Click(Sender: TObject);
var choosenDirectory: String;
    dialogMsg: String;
begin
  dialogMsg:= Config.l10n.getL10nString ('MozBackup14', 'LANG_SELECT_PROFILE_FOLDER');
  if SelectDirectory (dialogMsg, '', choosenDirectory) then
    begin
      Label2.Caption:= Zkraceny_adresar (choosenDirectory);
      Label2.Hint:= choosenDirectory;
    end;
end;

end.
