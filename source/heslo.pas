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

unit heslo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm4 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Potvrzeno: boolean;
  end;

var
  Form4: TForm4;

implementation

uses hlavni, Config;

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  if (Edit1.Text = Edit2.Text) then
    begin
      if Length (Edit1.Text) >= 3 then
        begin
          Potvrzeno:= true;
          Form4.Close;
        end
      else Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm4', 'LANG_NO_PASS')),
            pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONINFORMATION);
    end
  else Application.MessageBox(pchar (Config.l10n.getL10nString ('TForm4', 'LANG_NO_STEJ')),
        pchar (Config.l10n.getL10nString ('TForm1', 'LANG_WARNING')), MB_OK + MB_ICONINFORMATION);
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
 Form4.Close;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Form4.Font.Name:= Config.l10n.getDefaultFont();
  Form4.Font.Charset:=  Config.l10n.getDefaultCharset();
  Edit1.SetFocus;
end;

end.
