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

unit Configuration;

interface

// System
uses IniFiles, SysUtils,
// My
Config, Functions, TesterHelper;

function getStringConfiguration(Section: String; Key: String; Default:String):String; overload;
function getStringConfiguration(Section: String; Key: String):String; overload;
function getIntConfiguration(Section: String; Key: String; Default:integer):integer; overload;
function getIntConfiguration(Section: String; Key: String):integer; overload;
function getBooleanConfiguration(Section: String; Key: String; Default:boolean):boolean; overload;
function getBooleanConfiguration(Section: String; Key: String):boolean; overload;

procedure testConfiguration;

const SECTION_GENERAL =    'General';
const FILE_FORMAT =       'fileformat';
const DIR_BACKUP =        'backupdir';

const DIR_FIREFOX =       'firefoxdir';
const DIR_THUNDERBIRD =   'thunderbirddir';
const DIR_SUITE =         'suitedir';
const DIR_SUNBIRD =       'sunbirddir';
const DIR_FLOCK =         'flockdir';
const DIR_NETSCAPE =      'netscapedir';
const DIR_NETSCAPE_MESS = 'netscapemessdir';
const DIR_SPICEBIRD =     'spicebirddir';
const DIR_SONGBIRD =      'songbirddir';
const DIR_POSTBOX =       'postboxdir';
const DIR_WYZO =          'wyzodir';

const MONITOR = 'monitor';
const ASK_FOR_PASSWORD =  'askForPassword';
const COMPRESSION_LEVEL = 'compressionLevel';

implementation

// ************************* Private methods **********************************

function getIniFile():TIniFile;
begin
  if FileExists (GetApplicationDirectory + Config.CONFIG_FILE) = false then
    begin
      raise Exception.Create('Cannot find file ' + Config.CONFIG_FILE + ' with configuration.'); // NO L10N
    end;

  Result:= TIniFile.Create(GetApplicationDirectory + Config.CONFIG_FILE);
end;

procedure closeIniFile(IniFile: TIniFile);
begin
  if (iniFile <> nil) then
    begin
      iniFile.Destroy;
    end;
end;

// ************************* Public methods ***********************************

function getStringConfiguration(Section: String; Key: String; Default:String):String; overload;
var IniFile: TIniFile;
    S: String;
begin
  S:= '';

  IniFile:= getIniFile ();
  S:= Trim (IniFile.ReadString(Section, Key, Default));
  closeIniFile(IniFile);

  Result:= S;
end;


function getStringConfiguration(Section: String; Key: String):String; overload;
begin
  Result:= getStringConfiguration(Section, Key, '');
end;


function getIntConfiguration(Section: String; Key: String; Default:integer):integer; overload;
var IniFile: TIniFile;
    S: String;
begin
  IniFile:= getIniFile ();
  S:= Trim (IniFile.ReadString(Section, Key, ''));
  try
    Result:= StrToInt (S);
  except
    Result:= Default;
  end;

  closeIniFile(IniFile);
end;


function getIntConfiguration(Section: String; Key: String):integer; overload;
begin
  Result:= getIntConfiguration(Section, Key, 0);
end;


function getBooleanConfiguration(Section: String; Key: String; Default:boolean):boolean; overload;
var IniFile: TIniFile;
    S: String;
begin
  IniFile:= getIniFile ();

  S:= IniFile.ReadString(Section, Key, BoolToStr(Default));
  try
    Result:= StrToBool(S);
  except
    Result:= Default;
  end;

  closeIniFile(IniFile);
end;


function getBooleanConfiguration(Section: String; Key: String):boolean; overload;
begin
  Result:= getBooleanConfiguration(Section, Key, false);
end;

//****************************** Tests *****************************************

procedure testConfiguration;
begin
  assertString ('Configuration1', getStringConfiguration (SECTION_GENERAL, DIR_BACKUP), '');
  assertString ('Configuration2', getStringConfiguration (SECTION_GENERAL, DIR_BACKUP, ''), '');
  assertString ('Configuration3', getStringConfiguration (SECTION_GENERAL, DIR_BACKUP, 'default'), '');
  assertString ('Configuration4', getStringConfiguration (SECTION_GENERAL, 'non exists', 'default'), 'default');
  assertString ('Configuration5', getStringConfiguration ('non exists', 'non exists', 'default'), 'default');

  assertInt ('Configuration6', getIntConfiguration (SECTION_GENERAL, DIR_BACKUP), 0);
  assertInt ('Configuration7', getIntConfiguration (SECTION_GENERAL, MONITOR), 1);
  assertInt ('Configuration8', getIntConfiguration (SECTION_GENERAL, 'non exists'), 0);
  assertInt ('Configuration9', getIntConfiguration (SECTION_GENERAL, 'non exists', 5), 5);

  assertBoolean('Configuration10', getBooleanConfiguration (SECTION_GENERAL, ASK_FOR_PASSWORD), true);
  assertBoolean('Configuration11', getBooleanConfiguration (SECTION_GENERAL, 'aaaa'), false);
  assertBoolean('Configuration12', getBooleanConfiguration (SECTION_GENERAL, 'aaaa', true), true);
end;

end.