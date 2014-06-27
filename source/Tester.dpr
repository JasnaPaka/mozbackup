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

program Tester;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  AppProfile in 'AppProfile.pas',
  CmdLine in 'CmdLine.pas',
  Config in 'Config.pas',
  Configuration in 'Configuration.pas',
  errorlog in 'errorlog.pas',
  Functions in 'Functions.pas',
  funkce in 'funkce.pas',
  heslo in 'heslo.pas' {Form4},
  heslo2 in 'heslo2.pas' {Form5},
  hlavni in 'hlavni.pas' {Form1},
  chyby in 'chyby.pas',
  input_dialog in 'input_dialog.pas' {Form2},
  JP_Registry in 'JP_Registry.pas',
  JPDialogs in 'JPDialogs.pas',
  l10n in 'l10n.pas',
  MozManager in 'MozManager.pas',
  MozProfile in 'MozProfile.pas',
  MozUtils in 'MozUtils.pas',
  okna in 'okna.pas',
  PrefsParser in 'PrefsParser.pas',
  PrefsParserAccount in 'PrefsParserAccount.pas',
  UnknowFiles in 'UnknowFiles.pas' {UnknowFilesFM},
  UnknowFilesBL in 'UnknowFilesBL.pas',
  UnknowItem in 'UnknowItem.pas',
  Utils in 'Utils.pas',
  WinUtils in 'WinUtils.pas',
  zaloha in 'zaloha.pas',
  ZipFactory in 'ZipFactory.pas',
  FirefoxApp in 'apps\FirefoxApp.pas',
  FlockApp in 'apps\FlockApp.pas',
  MessengerApp in 'apps\MessengerApp.pas',
  MozApp in 'apps\MozApp.pas',
  NetscapeApp in 'apps\NetscapeApp.pas',
  SeaMonkeyApp in 'apps\SeaMonkeyApp.pas',
  SpiceBirdApp in 'apps\SpiceBirdApp.pas',
  SunbirdApp in 'apps\SunbirdApp.pas',
  ThunderbirdApp in 'apps\ThunderbirdApp.pas',
  TesterHelper in 'TesterHelper.pas';

begin
  initTests();

  testConfiguration;

  writeResults();
end.
