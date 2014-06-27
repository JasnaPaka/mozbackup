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

unit UnknowFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst;

type
  TUnknowFilesFM = class(TForm)
    StaticText1: TStaticText;
    CheckListBox1: TCheckListBox;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    items: TStringList;
  public
    { Public declarations }
    procedure ResetItems();
  end;

var
  UnknowFilesFM: TUnknowFilesFM;

implementation

uses Config;

{$R *.dfm}

// close dialog (button OK)
procedure TUnknowFilesFM.Button1Click(Sender: TObject);
var i: integer;
begin
  for I := 0 to items.Count - 1 do
    begin
      if CheckListBox1.Checked[i] then
        begin
          items[i]:= 'true';
        end
      else
        begin
          items[i]:= 'false';        
        end;
    end;
    
  Self.Close;  
end;

// close dialog (button Cancel)
procedure TUnknowFilesFM.Button2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TUnknowFilesFM.CheckBox1Click(Sender: TObject);
var I: Integer;
begin
  for I := 0 to CheckListBox1.Count - 1 do
    begin
      if CheckBox1.Checked then
        begin
          CheckListBox1.Checked[I]:= true;
        end
      else
        begin
          CheckListBox1.Checked[I]:= false;        
        end;
    end;
end;

// dialog init
procedure TUnknowFilesFM.FormShow(Sender: TObject);
var I: integer;
begin
  // l10n
  UnknowFilesFM.Font.Name:= Config.l10n.getDefaultFont();
  UnknowFilesFM.Font.Charset:=  Config.l10n.getDefaultCharset();

  UnknowFilesFM.Caption:= Config.l10n.getL10nString ('MozBackup14', 'LANG_UNKNOW_FILES');
  Button1.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_OK');
  Button2.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_2');  
  StaticText1.Caption:= Config.l10n.getL10nString ('MozBackup14', 'LANG_UNKNOW_FILES_DESC');
  CheckBox1.Caption:= Config.l10n.getL10nString ('MozBackup14', 'LANG_SEL_DESEL_ALL');

  if items = nil then
    begin
      items:= TStringList.Create();

      for I := 0 to UnknowFilesFM.CheckListBox1.Items.Count - 1 do
        begin
          items.Add('true');        
        end;
    end
  else
    begin
      for I := 0 to UnknowFilesFM.CheckListBox1.Items.Count - 1 do
        begin
          if items[i] = 'true' then
            begin
              UnknowFilesFM.CheckListBox1.Checked[i]:= true;
            end
          else
            begin
              UnknowFilesFM.CheckListBox1.Checked[i]:= false;            
            end;          
        end;
    end;
end;

procedure TUnknowFilesFM.ResetItems;
begin
  if (items <> nil) then
    begin
      items.Destroy;
      items:= nil;
    end;
end;

end.
