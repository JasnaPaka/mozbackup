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

// informace o jmenu a verzi aplikace
const Pocet_aplikaci   = 12;
      // testuje, zda-li je aplikace spustena
      Testovat_procesy = 1;

// ** Seznam programù      
type TProgram = record
        Nalezen:      boolean;          // nalezena aplikace?
        Verze:        string;           // verze programu
        Cesta:        string;           // adresar se spustitelnym souborem
      end;

// ** Seznam nalezených profilù      
     TProfily = ^profil;                // seznam profilu
     Profil = record
       Jmeno: string;
       Cesta: string;
       Dalsi: TProfily;
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
    Akce: byte;                         // 1 - zalohovani, 2 - obnoveni
    Okno: byte;                         // informace o tom, ktere okno je momentalne
                                        // aktualni
    Cesta: string;                      // cesta ke slozce s Mozillou
    Slozka_data: string;                // slozka s profily Mozilly
    Verze: string;                      // zjistena verze Mozilly
    Chyba: boolean;                     // vyskytla se chyba - program bude ukoncen
    Typ_programu: byte;                 // program, který je vybrán
    ProgramName: string;                // jmeno programu 
    Vyst_soubor: string;                // cesta k vystupnimu souboru
    Verze_souboru: byte;                // verze zalozniho souboru
    Password: string;                   // heslo
    Jazyk: integer;                     // konstanta jazykove mutace
    Extern_ucty: array [1..25] of string;       // adresy externich emailovych uctu
    Pocet_extern: byte;
    Prvni_profil: TProfily;             // ukazatel na prvni profil
    VychoziCesty: array [1..10] of string;  // vychozi cesty pro zalohovani
    AktualniProfil: string;             // jmeno aktualniho profilu

    VystupniFormat: string;             // nacteny format, jak bude vypadat vystupni soubor

    GeneralDir: string;                 // vychozi adresar pro zalohy
    SuiteDir: string;                   // vychozi adresar pro zalohy Suite    
    FirefoxDir: string;                 // vychozi adresar pro zalohy Firefoxu
    ThunderbirdDir: string;             // vychozi adresar pro zalohy Thunderbirdu
    SunbirdDir: string;                 // vychozi adresar pro zalohy Sunbird
    FlockDir: string;                   // vychozi adresar pro zalohy Flock
    NetscapeDir: string;                // vychozi adresar pro zalohy Netscape
    NetscapeMessengerDir: string;       // vychozi adresar pro zalohy Netscape Messenger
    SpicebirdDir: string;               // vychozi adresar pro zalohy Spicebirdu
    SongbirdDir: string;                // vychozi adresar pro zalohy Songbirdu
    PostBoxDir: string;                 // vychozi adresar pro zalohy PostBoxu
    WyzoDir: string;                    // vychozi adresar pro zalohy Wyza

    IsProfileInName: boolean;           // informace, zda je ve jmene vystupniho souboru uvedeno jmeno profilu
    Monitor: integer;                   // monitor, na kterém se aplikace zobrazí
    AskForPassword: boolean;            // zda bude uživatel pøi zálohování dotazován na heslo
    UnknowFiles: TList;                 // nezname soubory uvedene v zaloze
    PortableDirectory: String;          // directory with profile of Portable Firefox/Thunderbird etc.
    BackupFailed: boolean;              // backup failed?
    BackupAppVersion: Integer;          // backup app version

    MozManager: TMozManager;
  end;

var
  Form1: TForm1;
  Programy: array [1..Pocet_aplikaci] of TProgram;    // seznam programu, ktere se budou vyhledavat
  CommandLineStarted: boolean;

implementation

{$R *.dfm}

//******************************************************************************
// Deklarace pouzitych unit
//******************************************************************************

uses funkce, okna, zaloha, JPDialogs, CmdLine, Functions;
// funkce - pouzite funkce
// okna - informace o oknech pruvodce
// zaloha - provedeni zalohy ci obnovy profilu

//******************************************************************************
// Procedury a funkce
//******************************************************************************

procedure TForm1.FormCreate(Sender: TObject);
begin
  // nacteni ini souboru
  LoadIni;

  // jedna se o tichou instalaci?
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
  // vyber programu, ktery se bude zalohovat
  Over_vyber;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
begin
  // volba profilu
  Over_vyber_profilu;
  if (Form1.Akce = 1) and (Form1.IsProfileInName = true) then NastavSoubor;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // ukonceni programu nebo zahajeni noveho zalohovani/obnovy
  if Form1.CheckBox16.Checked = false then Form1.Close
  else
    begin
      Form1.CheckBox16.Checked:= false;
      // Je potreba vymazat ListBox3 a 4
      Form1.ListBox3.Clear;
      Form1.ListBox4.Clear;

      Form1.Okno:= 1;
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
  // Tlacitko dalsi v dialogu
  case Okno of
    1: begin
         Okno2;                 // nastaveni na dialog 2 - volba operace
         Okno:= Okno + 1;
       end;
    2: begin
         // zjisteni typu programu a jeho jmena
         GetTypeProgram;

         // zde se nejedna o zacatek zalohovani - jen se overuje spusteny program
         if Zacatek_zalohovani = true then
           begin
             Okno3;
             Okno:= Okno + 1;
           end;
       end;
    3: begin                    // detekce komponent pro zalohovani (obnoveni)
         Okno4;
         Okno:= Okno + 1;
       end;
    4: begin                    // akce
         if (Zacatek_zalohovani = true) and (Prepsat_profil = true) then      // Mozilla nebyla detekovana
           begin
             Okno5;

             if Akce = 1 then Zalohovani else Obnoveni;
             Okno:= Okno + 1;
           end;
       end;

  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Tlacitko zpet v dialogu
  case Okno of
    2: begin
         Okno:= Okno - 1;
         Okno1;                 // nastaveni na dialog 1 - uvitani
       end;
    3: begin                    // nastaveni na dialog 2 - volba operace
         Okno2;
         Okno:= Okno - 1;
       end;
    4: begin                    // nastaveni na dialog 3 - volba profilu
         Okno3;
         Okno:= Okno - 1;
       end;
    5: begin                    // nastaveni na dialog 4 - volba soucasti
         Okno4;
         Okno:= Okno - 1;
       end;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // uzavreni formulare (eventualne zobrazeni dialogu)
  Ukonceni_programu (CanClose);
end;

procedure TForm1.FormShow(Sender: TObject);
var Left: integer;
    Top: integer;
begin
  //if Form1.Ukoncit = true then Application.Terminate;

  // overeni existence potrebnych souboru
  DetekceSouboru;

  // zobrazení okna aplikace na støedu prvního monitoru
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

// Metoda, ktera se zavola, pokud je vyzadovano heslo
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

// Dvojklepnuti na listboxu s vyberem aplikace
procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  GetTypeProgram;            // Zjisteni vybraneho programu
  if (Length (Form1.ProgramName) > 0) and  (Zacatek_zalohovani = true) then
    begin
      Okno3;                 // nastaveni na dialog "volba operace"
      Okno:= Okno + 1;
    end;
end;

// Dvojklepnuti na listboxu s volbou profilu
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
  // Prepinani
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

{ Pokud nejde zapisovat do souboru, ukonèi zálohování
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
