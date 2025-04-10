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


unit hlavni;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, ComCtrls, Config, l10n,
  heslo, heslo2, inifile, UnknowFiles, MozManager, AppEvnts, ActnList;

// information about application name and version
const Pocet_aplikaci   = 12;
      // checks if the application is running
      Testovat_procesy = 1;

// ** List of programs
type TProgram = record
        Nalezen:      boolean;          // was the application found?
        Verze:        string;           // version of the program
        Cesta:        string;           // path to the executable file
      end;

// ** List of detected profiles
     TProfily = ^profil;                // list of profiles
     Profil = record
       Jmeno: string;                   // name of the profile
       Cesta: string;                   // path to the profile
       Dalsi: TProfily;                 // next profile in the list
     end;

type
  TForm1 = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    Bevel2: TBevel;
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Button3: TButton;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ListBox1: TListBox;
    StaticText1: TStaticText;
    Panel3: TPanel;
    StaticText2: TStaticText;
    ListBox2: TListBox;
    GroupBox2: TGroupBox;
    StaticText3: TStaticText;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StaticText4: TStaticText;
    Button5: TButton;
    Panel4: TPanel;
    StaticText5: TStaticText;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    Panel5: TPanel;
    ListBox3: TListBox;
    StaticText6: TStaticText;
    ProgressBar1: TProgressBar;
    CheckBox9: TCheckBox;
    Panel6: TPanel;
    ListBox4: TListBox;
    Button6: TButton;
    Button7: TButton;
    CheckBox7: TCheckBox;
    CheckBox13: TCheckBox;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    UnknowFilesBT: TButton;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ZipMaster1PasswordError(Sender: TObject;
      IsZipAction: Boolean; var NewPassword: String; ForFile: String;
      var RepeatCount: Cardinal; var Action: TMsgDlgBtn);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox2DblClick(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure CheckBox14Click(Sender: TObject);
    procedure ZipMaster1Message(Sender: TObject; ErrCode: Integer;
      Message: String);
    procedure UnknowFilesBTClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ApplicationEvents1Activate(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
  private
    { Private declarations }
    ListBox2FucusSelection: integer;

    procedure ListBox2GetSelection;
    procedure ListBox2ReturnSelection;     
  public    
    Akce: byte;                         // 1 - backup, 2 - restore
    Okno: byte;                         // information about which window is currently active
    Cesta: string;                      // path to the Mozilla folder
    Slozka_data: string;                // folder with Mozilla profiles
    Verze: string;                      // detected Mozilla version
    Chyba: boolean;                     // an error occurred - the program will terminate
    Typ_programu: byte;                 // selected program
    ProgramName: string;                // name of the program
    Vyst_soubor: string;                // path to the output file
    Verze_souboru: byte;                // backup file version
    Password: string;                   // password
    Jazyk: integer;                     // language localization constant
    Extern_ucty: array [1..25] of string;       // addresses of external email accounts
    Pocet_extern: byte;                         // number of external accounts
    Prvni_profil: TProfily;             // pointer to the first profile
    VychoziCesty: array [1..10] of string;  // default paths for backup
    AktualniProfil: string;             // name of the currently active profile

    VystupniFormat: string;             // loaded format for the output file structure

    GeneralDir: string;                 // default directory for backups
    SuiteDir: string;                   // default directory for Suite backups
    FirefoxDir: string;                 // default directory for Firefox backups
    ThunderbirdDir: string;             // default directory for Thunderbird backups
    SunbirdDir: string;                 // default directory for Sunbird backups
    FlockDir: string;                   // default directory for Flock backups
    NetscapeDir: string;                // default directory for Netscape backups
    NetscapeMessengerDir: string;       // default directory for Netscape Messenger backups
    SpicebirdDir: string;               // default directory for Spicebird backups
    SongbirdDir: string;                // default directory for Songbird backups
    PostBoxDir: string;                 // default directory for PostBox backups
    WyzoDir: string;                    // default directory for Wyzo backups

    IsProfileInName: boolean;           // whether the profile name is included in the output file name
    Monitor: integer;                   // monitor on which the application will be displayed
    AskForPassword: boolean;            // whether the user will be asked for a password during backup
    UnknowFiles: TList;                 // unknown files listed in the backup
    PortableDirectory: String;          // directory containing the profile of Portable Firefox/Thunderbird etc.
    BackupFailed: boolean;              // did the backup fail?
    BackupAppVersion: Integer;          // backup application version

    MozManager: TMozManager;
  end;

var
  Form1: TForm1;
  Programy: array [1..Pocet_aplikaci] of TProgram;   // list of programs to be searched
  CommandLineStarted: boolean;

implementation

{$R *.dfm}

//******************************************************************************
// Declaration of used units
//******************************************************************************

uses funkce, okna, zaloha, JPDialogs, CmdLine, Functions;
// funkce - used functions
// okna - information about the wizard windows
// zaloha - performing backup or restore of the profile

//******************************************************************************
// Procedures and functions
//******************************************************************************

procedure TForm1.FormCreate(Sender: TObject);
begin
  // loading the ini file
  LoadIni;

  // is this a silent installation?
  //Form1.Ukoncit:= false;

  // ini l10n
  Config.l10n:= Tl10n.Create;

  // Backup via command line or standard GUI wizard?
  if not IsRunCommandLineVersion() then
    begin
      Okno1;
    end;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  // selection of the program to be backed up
  Over_vyber;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
begin
  // selection of the profile
  Over_vyber_profilu;
  if (Form1.Akce = 1) and (Form1.IsProfileInName = true) then NastavSoubor;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // exit the application or start a new backup/restore
  if Form1.CheckBox16.Checked = false then Form1.Close
  else
    begin
      Form1.CheckBox16.Checked := false;
      // It is necessary to clear ListBox3 and 4
      Form1.ListBox3.Clear;
      Form1.ListBox4.Clear;

      Form1.Okno := 1;
      Okno1;
      Form1.Button1.SetFocus;
    end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ListBox2GetSelection;
  Create_profil;
  ListBox2ReturnSelection;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ListBox2GetSelection;
  ChooseDialog;
  ListBox2ReturnSelection;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  ListBox2GetSelection;
  DetekceProfilu;
  ListBox2ReturnSelection;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ListBox2GetSelection;
  // Find portable profile
  selectPortableProfile();
  ListBox2ReturnSelection;
  NastavSoubor;
end;

procedure TForm1.ApplicationEvents1Activate(Sender: TObject);
begin
  if (IsRunCommandLineVersion()) and (CommandLineStarted = false) then
    begin
      CommandLineStarted:= true;
      BackupAction();
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // "Next" button in the dialog
  case Okno of
    1: begin
         Okno2;                 // switch to dialog 2 – operation selection
         Okno := Okno + 1;
       end;
    2: begin
         // determine the type and name of the program
         GetTypeProgram;

         // this is not the start of backup – just checking if the program is running
         if Zacatek_zalohovani = true then
           begin
             Okno3;
             Okno := Okno + 1;
           end;
       end;
    3: begin                    // detect components for backup (restore)
         Okno4;
         Okno := Okno + 1;
       end;
    4: begin                    // action
         if (Zacatek_zalohovani = true) and (Prepsat_profil = true) then  // Mozilla was not detected
           begin
             Okno5;

             if Akce = 1 then Zalohovani else Obnoveni;
             Okno := Okno + 1;
           end;
       end;

  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // "Back" button in the dialog
  case Okno of
    2: begin
         Okno := Okno - 1;
         Okno1;                 // switch to dialog 1 – welcome screen
       end;
    3: begin                    // switch to dialog 2 – operation selection
         Okno2;
         Okno := Okno - 1;
       end;
    4: begin                    // switch to dialog 3 – profile selection
         Okno3;
         Okno := Okno - 1;
       end;
    5: begin                    // switch to dialog 4 – component selection
         Okno4;
         Okno := Okno - 1;
       end;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Closing the form (possibly displaying a dialog)
  Ukonceni_programu (CanClose);
end;

procedure TForm1.FormShow(Sender: TObject);
var Left: integer;
    Top: integer;
begin
  //if Form1.Ukoncit = true then Application.Terminate;

  // Checking the existence of required files
  DetekceSouboru;

  // Display the application window in the center of the first monitor
  if (Screen.MonitorCount < Form1.Monitor) then Form1.Monitor:= 1;

  Left:= Screen.Monitors[Form1.Monitor - 1].Width;
  Left:= Left div 2;
  Left:= Screen.Monitors[Form1.Monitor - 1].Left + Left - Form1.Width div 2;

  Top:= Screen.Monitors[Form1.Monitor - 1].Height;
  Top:= Top div 2;
  Top:= Top - Form1.Height div 2;

  Form1.Left:= Left;
  Form1.Top:= Top;

  // Set l10n
  Form1.Font.Name:= Config.l10n.getDefaultFont();
  Form1.Font.Charset:=  Config.l10n.getDefaultCharset();

{ if IsRunCommandLineVersion() then
    begin
      BackupAction();
    end;}

  if Config.TEST_WARNING then
    begin
      showWarningDialog(Config.l10n.getL10nString ('TForm1', 'LANG_WARNING'),
                        Config.l10n.getL10nString ('MozBackup14', 'LANG_TEST_VERSION_WARNING'));
    end;
end;

// Method that is called if a password is required
procedure TForm1.ZipMaster1PasswordError(Sender: TObject;
  IsZipAction: Boolean; var NewPassword: String; ForFile: String;
  var RepeatCount: Cardinal; var Action: TMsgDlgBtn);
begin
  Form5.Edit1.Clear;
  Form5.Caption:= Config.l10n.getL10nString ('TForm5', 'LANG_CAPTION');
  Form5.Label1.Caption:= Config.l10n.getL10nString ('TForm5', 'LANG_LABEL1');
  Form5.Label2.Caption:= Config.l10n.getL10nString ('TForm4', 'LANG_HESLO');

  Form5.Button1.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_OK');
  Form5.Button2.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_2');

  Form5.ShowModal;

  if Form5.Potvrzeno = true then
    begin
      NewPassword:= Form5.Edit1.Text;
      Form1.Password:= Form5.Edit1.Text;
    end; 
end;

// Double-click on the listbox with application selection
procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  GetTypeProgram;            // Zjisteni vybraneho programu
  if (Length (Form1.ProgramName) > 0) and  (Zacatek_zalohovani = true) then
    begin
      Okno3;                 // nastaveni na dialog "volba operace"
      Okno:= Okno + 1;
    end;
end;

// Double-click on the listbox with profile selection
procedure TForm1.ListBox2DblClick(Sender: TObject);
begin
  Okno4;
  Okno:= Okno + 1;
end;

procedure TForm1.Panel4Click(Sender: TObject);
begin

end;

// Open dialog with unknow files which was found in profile or backup's file
procedure TForm1.UnknowFilesBTClick(Sender: TObject);
begin
  UnknowFilesFM.ShowModal;
end;

procedure TForm1.CheckBox16Click(Sender: TObject);
begin
  // switching
  if CheckBox16.Checked then Button2.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_1')
  else Button2.Caption:= Config.l10n.getL10nString ('TForm1', 'LANG_BUTTON_KONEC'); 
end;

procedure TForm1.CheckBox7Click(Sender: TObject);
begin
  // If someone choose "Only Account Settings", disable checkbox "Emails"
  if CheckBox7.Checked then
    begin
      CheckBox2.Checked:= false;
      CheckBox2.Enabled:= false;
    end
  else
    begin
      CheckBox2.Checked:= true;
      CheckBox2.Enabled:= true;
    end;
end;

procedure TForm1.CheckBox14Click(Sender: TObject);
begin

end;

{// If writing to the file is not possible, terminate the backup
}
procedure TForm1.ZipMaster1Message(Sender: TObject; ErrCode: Integer;
  Message: String);
begin
  if (ErrCode = 917774) or (Pos ('Error writing to a file', Message) > 0) then
    begin
      Form1.Chyba:= true;
      showWarningDialog(Config.l10n.getL10nString ('TForm1', 'LANG_WARNING'),
                        Config.l10n.getL10nString ('TForm1', 'LANG_KONEC'));
      if (FileExists (Form1.Vyst_soubor)) then SysUtils.DeleteFile (Form1.Vyst_soubor);
      Halt;
    end;
end;


procedure TForm1.ListBox2GetSelection;
var I: integer;
begin
  for I := 0 to Form1.ListBox2.Count - 1 do
    begin
      if Form1.ListBox2.Selected[I] then
        begin
          ListBox2FucusSelection:= I;
        end;
    end;
end;

procedure TForm1.ListBox2ReturnSelection;
var I: integer;
begin
  if (Form1.ListBox2.Count <> 0) then
    begin

      for I := 0 to Form1.ListBox2.Count - 1 do
        begin
          Form1.ListBox2.Selected[I]:= false;
        end;

      if (ListBox2FucusSelection > -1) then
        begin
          Form1.ListBox2.SetFocus;
          Form1.ListBox2.Selected[ListBox2FucusSelection]:= true;
          Form1.Button1.Enabled:= true;
          ListBox2FucusSelection:= - 1;
        end;
        
    end;
end;

end.
