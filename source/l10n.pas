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

unit l10n;

interface

uses IniFiles;

const LANG_SECTION_MOZBACKUP14 = 'MozBackup14';
const LANG_SECTION_MOZBACKUP15 = 'MozBackup15';

type Tl10n = class
  private
    iniL10n: TIniFile;

    function getDefaultL10nString (key: String):String;
  protected
  public
    constructor Create;
    destructor Destroy;

    function getDefaultFont():String;
    function getDefaultCharset():integer;
    function getL10nString (section: String; key: String):String; overload;
    function getL10nString (section: String; key: String; param: String):String; overload;
    function getL10nString(section: String; key: String; param: String; param2: String):String; overload;    
end;

implementation

uses Config, Functions, SysUtils;

// *** Constructor / destructor

constructor Tl10n.Create;
begin
  iniL10n:= TIniFile.Create(GetApplicationDirectory + Config.L10N_FILE);
end;

destructor Tl10n.Destroy;
begin
  if iniL10n <> nil then
    begin
      iniL10n.Destroy;
      iniL10n:= nil;
    end;
end;

// *** Private methods

// Return default string for l10n key
function Tl10n.getDefaultL10nString(key: String):String;
begin
  if (key = 'DefaultCharset') then Result:= '1';
  if (key = 'Font') then Result:= '';
  if (key = 'LANG_OKNO_1') then Result:= ' - Welcome';
  if (key = 'LANG_APLIKACE_WELCOME') then Result:= 'Welcome to MozBackup';
  if (key = 'LANG_APLIKACE_VOLBA') then Result:= ' - Operation type';
  if (key = 'LANG_BUTTON_1') then Result:= 'Next >';
  if (key = 'LANG_BUTTON_2') then Result:= 'Cancel';
  if (key = 'LANG_BUTTON_3') then Result:= '< Back';
  if (key = 'LANG_BUTTON_OK') then Result:= 'OK';
  if (key = 'LANG_BUTTON_KONEC') then Result:= 'Finish';
  if (key = 'LANG_WARNING') then Result:= 'Warning';
  if (key = 'LANG_QUESTION') then Result:= 'Question';
  if (key = 'LANG_VOLBA') then Result:= 'Operation';
  if (key = 'LANG_NO_PROGRAM') then Result:= 'No program was found';
  if (key = 'LANG_CO_PROVEST') then Result:= 'Choose the operation you want to perform:';
  if (key = 'LANG_ZALOHA') then Result:= 'Backup a profile';
  if (key = 'LANG_OBNOVA') then Result:= 'Restore a profile';
  if (key = 'LANG_VOLBA_PROFILU') then Result:= ' - Profile selection';
  if (key = 'LANG_TEXT2_1') then Result:= 'Select the profile you want to backup:';
  if (key = 'LANG_TEXT4_1') then Result:= 'Then select the location of the backup file:';
  if (key = 'LANG_TEXT2_2') then Result:= 'Select the profile you want to restore.';
  if (key = 'LANG_TEXT4_2') then Result:= 'Then select the backup file to restore the profile from:';
  if (key = 'LANG_END_PROGRAM') then Result:= 'Exit the program';
  if (key = 'LANG_END_TEXT') then Result:= 'The operation is not finished. Do you really want to exit the program?';
  if (key = 'LANG_NEW_PROFIL') then Result:= 'New profile';
  if (key = 'LANG_RELOAD') then Result:= 'Refresh';
  if (key = 'LANG_CHOOSE_FILE') then Result:= 'Select file';
  if (key = 'LANG_CHOOSE') then Result:= 'Browse...';
  if (key = 'LANG_FILE') then Result:= 'C:\backup.pcv';
  if (key = 'LANG_NEW_PROFIL_NAME') then Result:= 'Enter the new profile name:';
  if (key = 'LANG_BAD_CREATE') then Result:= 'Creation of the new profile did not succeed.';
  if (key = 'LANG_PROFIL_EXIST') then Result:= 'A profile with this name already exists.';
  if (key = 'LANG_NO_NAME') then Result:= 'No profile name was entered.';
  if (key = 'LANG_NO_PROFIL') then Result:= 'No profile was found. The program will exit.';
  if (key = 'LANG_SOUCASTI') then Result:= ' - Components selection';
  if (key = 'LANG_CHOOSE_ZALOHA') then Result:= 'Select the details you want to backup:';
  if (key = 'LANG_CHOOSE_OBNOVA') then Result:= 'Select the details you want to restore:';
  if (key = 'LANG_CHECKBOX1') then Result:= 'General settings';
  if (key = 'LANG_CHECKBOX2') then Result:= 'Emails';
  if (key = 'LANG_CHECKBOX3') then Result:= 'Address books';
  if (key = 'LANG_CHECKBOX4') then Result:= 'Bookmarks';
  if (key = 'LANG_CHECKBOX5') then Result:= 'History';
  if (key = 'LANG_CHECKBOX6') then Result:= 'Sidebars';
  if (key = 'LANG_CHECKBOX7') then Result:= 'Accounts settings only';
  if (key = 'LANG_CHECKBOX8') then Result:= 'User styles';
  if (key = 'LANG_CHECKBOX9') then Result:= 'Saved passwords';
  if (key = 'LANG_CHECKBOX10') then Result:= 'Cookies';
  if (key = 'LANG_CHECKBOX11') then Result:= 'Saved form details';
  if (key = 'LANG_CHECKBOX12') then Result:= 'Downloaded file list';
  if (key = 'LANG_CHECKBOX13') then Result:= 'Certificates';
  if (key = 'LANG_CHECKBOX14') then Result:= 'Extensions';
  if (key = 'LANG_CHECKBOX14_HINT') then Result:= 'Firefox & Thunderbird only';
  if (key = 'LANG_CHECKBOX15') then Result:= 'Cache';
  if (key = 'LANG_GROUPBOX3') then Result:= 'Details';
  if (key = 'LANG_BAD_FILE2') then Result:= 'The selected file is not a valid backup file.';
  if (key = 'LANG_BAD_PROFIL') then Result:= 'The selected user profile is corrupted. The program will exit.';
  if (key = 'LANG_NOT_FOUND') then Result:= 'A critical error occurred while accessing the file. The program will exit.';
  if (key = 'LANG_NOT_FOUND2') then Result:= 'A critical error occurred while modifying the preferences file. The program will exit.';
  if (key = 'LANG_PROV_AKCE') then Result:= ' - Processing operation';
  if (key = 'LANG_STATICTEXT6') then Result:= 'Task:';
  if (key = 'LANG_ZAVER') then Result:= ' - Report';
  if (key = 'LANG_WRITE_ERROR') then Result:= 'The program can not write in the backup file. Either the disk is full or you do not have write permissions. The program will exit.';
  if (key = 'LANG_WRITE_ERROR2') then Result:= 'Some files can not be restored. Either the disk is full or you do not have write permissions. The program will exit.';
  if (key = 'LANG_END_FILE') then Result:= 'The backup file is corrupted.  The program will exit.';
  if (key = 'LANG_AKCE_OBECNE') then Result:= 'Task: Backing up general settings';
  if (key = 'LANG_AKCE_OBECNE_OK') then Result:= 'General settings backup... OK';
  if (key = 'LANG_AKCE_MAIL') then Result:= 'Task: Backing up emails';
  if (key = 'LANG_AKCE_MAIL_OK') then Result:= 'Emails backup... OK';
  if (key = 'LANG_AKCE_KONTAKTY') then Result:= 'Task: Backing up address books';
  if (key = 'LANG_AKCE_KONTAKTY_OK') then Result:= 'Address books backup... OK';
  if (key = 'LANG_AKCE_FAVORITES') then Result:= 'Task: Backing up bookmarks';
  if (key = 'LANG_AKCE_FAVORITES_OK') then Result:= 'Bookmarks backup... OK';
  if (key = 'LANG_AKCE_HISTORIE') then Result:= 'Task: Backing up history';
  if (key = 'LANG_AKCE_HISTORIE_OK') then Result:= 'History backup... OK';
  if (key = 'LANG_AKCE_PANELY') then Result:= 'Task: Backing up sidebars';
  if (key = 'LANG_AKCE_PANELY_OK') then Result:= 'Sidebars backup... OK';
  if (key = 'LANG_AKCE_STYLY') then Result:= 'Task: Backing up user styles';
  if (key = 'LANG_AKCE_STYLY_OK') then Result:= 'User styles backup... OK';
  if (key = 'LANG_AKCE_HESLA') then Result:= 'Task: Backing up passwords';
  if (key = 'LANG_AKCE_HESLA_OK') then Result:= 'Password Backup ... OK';
  if (key = 'LANG_AKCE_COOKIES') then Result:= 'Task: Backing up cookies';
  if (key = 'LANG_AKCE_COOKIES_OK') then Result:= 'Cookies backup... OK';
  if (key = 'LANG_AKCE_FORMULARE') then Result:= 'Task: Backing up saved form details';
  if (key = 'LANG_AKCE_FORMULARE_OK') then Result:= 'Saved form details backup... OK';
  if (key = 'LANG_AKCE_SOUBORY') then Result:= 'Task: Backing up downloaded file list';
  if (key = 'LANG_AKCE_SOUBORY_OK') then Result:= 'Downloaded file list backup... OK';
  if (key = 'LANG_AKCE_EXTENSIONS') then Result:= 'Task: Backing up extensions';
  if (key = 'LANG_AKCE_EXTENSIONS_OK') then Result:= 'Extensions backup... OK';
  if (key = 'LANG_AKCE_CACHE') then Result:= 'Task: Backing up cache';
  if (key = 'LANG_AKCE_CACHE_OK') then Result:= 'Cache backup... OK';
  if (key = 'LANG_KONEC') then Result:= 'An error occurred while backing up some files. Either the disk is full or you don''t have write permission. The program will exit.';
  if (key = 'LANG_DIR_ERROR') then Result:= 'Creation of the directory did not succeed. Either the disk is full or you don''t have write permission. The program will exit.';
  if (key = 'LANG_AKCE_OBECNE1') then Result:= 'Task: Restoring general settings';
  if (key = 'LANG_AKCE_MAIL1') then Result:= 'Task: Restoring emails';
  if (key = 'LANG_KONTATKY1') then Result:= 'Task: Restoring address books';
  if (key = 'LANG_FAVORITES1') then Result:= 'Task: Restoring bookmarks';
  if (key = 'LANG_HISTORIE1') then Result:= 'Task: Restoring history';
  if (key = 'LANG_PANELY1') then Result:= 'Task: Restoring sidebars';
  if (key = 'LANG_STYLY1') then Result:= 'Task: Restoring user styles';
  if (key = 'LANG_HESLA1') then Result:= 'Task: Restoring saved passwords';
  if (key = 'LANG_COOKIES1') then Result:= 'Task: Restoring cookies';
  if (key = 'LANG_FORMULAR1') then Result:= 'Task: Restoring saved form details';
  if (key = 'LANG_DOWNLOAD1') then Result:= 'Task: Restoring downloaded file list';
  if (key = 'LANG_EXTENSIONS1') then Result:= 'Task: Restoring extensions';
  if (key = 'LANG_CACHE1') then Result:= 'Task: Restoring cache';
  if (key = 'LANG_SOUBOR') then Result:= 'Restored file: ';
  if (key = 'LANG_NOT_FOUND_FILE') then Result:= 'The backup file does not exist. The program will exit.';
  if (key = 'LANG_SOUBOR_EXIST') then Result:= 'This file already exists. Overwrite it?';
  if (key = 'LANG_ONLYPROFIL') then Result:= '(profiles only)';
  if (key = 'LANG_CHOOSEPROFIL') then Result:= 'Find profile...';
  if (key = 'LANG_PROFILCAP') then Result:= 'Path to profile';
  if (key = 'LANG_TIP') then Result:= 'Choose path to your profile:';
  if (key = 'LANG_BAD_PROFIL2') then Result:= 'This directory does not contain a Mozilla profile.';
  if (key = 'LANG_PROFIL_NAME') then Result:= 'External profile';
  if (key = 'LANG_BAD_DIRECTORY') then Result:= 'Directory with profile not found. Backup failed.';
  if (key = 'LANG_NO_BACKUP_FILE') then Result:= 'The backup file was not found or corrupted.';
  if (key = 'LANG_BACKUP_RESTOR') then Result:= 'The backup was restored. You can read the report below:';
  if (key = 'LANG_MEMO1') then Result:= 'This wizard will help you to backup or restore your Mozilla user profile(s).';
  if (key = 'LANG_MEMO11') then Result:= 'It is strongly recommended that you exit all Windows programs that can manipulate any of your Mozilla user profiles before continuing.';
  if (key = 'LANG_MEMO12') then Result:= 'Click Cancel to quit the program, or click Next to continue.';
  if (key = 'LANG_MEMO2') then Result:= 'It is possible to backup or restore Mozilla user profile(s) for the following application(s):';
  if (key = 'LANG_MEMO3') then Result:= 'The backup was created. You can read the report below:';
  if (key = 'LANG_PROFILE_RESTORED') then Result:= 'Complete';
  if (key = 'LANG_CHECKBOX13') then Result:= 'Certificates';
  if (key = 'LANG_AKCE_CERTIF') then Result:= 'Task: Backing up certificates';
  if (key = 'LANG_CERTIF1') then Result:= 'Task: Restoring certificates';
  if (key = 'LANG_CERTIF_OK') then Result:= 'Certificates... OK';
  if (key = 'LANG_NO_FILES') then Result:= 'Some files not found. Please reinstall.';
  if (key = 'LANG_DIR_DEFAULT') then Result:= 'Default directory';
  if (key = 'LANG_LOCATION') then Result:= 'Location:';
  if (key = 'LANG_DIALOGS') then Result:= 'Mozilla backup (*.pcv) | *.pcv';
  if (key = 'LANG_NEW_BR') then Result:= '&New backup or restore';
  if (key = 'LANG_EXT_WARNING') then Result:= 'Some extensions have got problematic restoration. Author of MozBackup cannot detect all these extensions. Use this option on your risk.';

  if (key = 'LANG_ENCRYPT') then Result:= 'Do you want to password-protect the backup file?';
  if (key = 'LANG_CAPTION') then Result:= 'Set password';
  if (key = 'LANG_TEXT') then Result:= 'Enter the password:';
  if (key = 'LANG_HESLO') then Result:= 'Password:';
  if (key = 'LANG_HESLO2') then Result:= 'Confirm password:';
  if (key = 'LANG_NO_PASS') then Result:= 'Password should be at least three characters long.';
  if (key = 'LANG_NO_STEJ') then Result:=  'The passwords you typed do not match.';

  if (key = 'LANG_CAPTION') then Result:= 'Enter ZIP Password';
  if (key = 'LANG_LABEL1') then Result:= 'This file is encrypted. Please enter password:';

  if (key = 'LANG_BADINIREAD') then Result:= 'I cannot read file backup.ini';
  if (key = 'LANG_BADINIWRITE') then Result:= 'I cannot write to file backup.ini';
  if (key = 'LANG_NO_PROGRAM') then Result:= 'Mozilla application doesn''t found on your system.';
  if (key = 'LANG_NO_PROFILE') then Result:= 'Profile was not found.';
  if (key = 'LANG_BADFIRSTPARAM') then Result:= 'Bad first param. You can use "-m", "-f" or "-t" only. See documentation.';

  if (key = 'LANG_OVERWRITE_PROFILE') then Result:= 'Restoration can overwrite exist files in selected profile. Do you want to continue?';
  if (key = 'LANG_INVALID_OUTPUT') then Result:= 'Backup''s file isn''t valid. Backup has failed.';
  if (key = 'LANG_SELECT_PROFILE_FOLDER') then Result:= 'Select folder where you want to store a profile.';

  if (key = 'LANG_CANNOT_CREATE_PROFILE_DIR') then Result:= 'Cannot create MozBackup profile directory.';
  if (key = 'LANG_DIRECTORY') then Result:= 'directory';
  if (key = 'LANG_PREFS_JS_NOT_FOUND') then Result:= 'Config file prefs.js doesn''t found.';
  if (key = 'LANG_MAILBOX_BACKUP_PROBLEM') then Result:= 'Problem with backup email account! Account: ';
  if (key = 'LANG_AKCE_UNKNOW') then Result:= 'Task: Backing up unknow files';
  if (key = 'LANG_AKCE_UNKNOW_OK') then Result:= 'Unknow files backup... OK';
  if (key = 'LANG_UNKNOW') then Result:= 'Task: Restoring unknow files';
  if (key = 'LANG_UNKNOW_FILES') then Result:= 'Unknow files';
  if (key = 'LANG_UNKNOW_FILES_DESC') then Result:= 'Check unknow files in your profile which you want to backup/restore:';

  if (key = 'LANG_AKCE_OBECNE_R_OK') then Result:= 'General settings restore... OK';
  if (key = 'LANG_AKCE_MAIL_R_OK') then Result:= 'Emails restore... OK';
  if (key = 'LANG_AKCE_KONTAKTY_R_OK') then Result:= 'Address books restore... OK';
  if (key = 'LANG_AKCE_FAVORITES_R_OK') then Result:= 'Bookmarks restore... OK';
  if (key = 'LANG_AKCE_HISTORIE_R_OK') then Result:= 'History restore... OK';
  if (key = 'LANG_AKCE_PANELY_R_OK') then Result:= 'Sidebars restore... OK';
  if (key = 'LANG_AKCE_STYLY_R_OK') then Result:= 'User styles restore... OK';
  if (key = 'LANG_AKCE_HESLA_R_OK') then Result:= 'Password restore ... OK';
  if (key = 'LANG_AKCE_COOKIES_R_OK') then Result:= 'Cookies restore... OK';
  if (key = 'LANG_AKCE_FORMULARE_R_OK') then Result:= 'Saved form details restore... OK';
  if (key = 'LANG_AKCE_SOUBORY_R_OK') then Result:= 'Downloaded file list restore... OK';
  if (key = 'LANG_AKCE_EXTENSIONS_R_OK') then Result:= 'Extensions restore... OK';
  if (key = 'LANG_AKCE_CACHE_R_OK') then Result:= 'Cache restore... OK';
  if (key = 'LANG_CERTIF_R_OK') then Result:= 'Certificates restore... OK';
  if (key = 'LANG_AKCE_UNKNOW_R_OK') then Result:= 'Unknow files restore... OK';

  if (key = 'LANG_PORTABLE') then Result:= 'Portable';
  if (key = 'LANG_PORTABLE_PROFILE') then Result:= 'Portable profile';
  if (key = 'LANG_PORTABLE_SELECT_PROFILE') then Result:= 'Select profile of your portable Mozilla application.';
  if (key = 'LANG_NO_PROFIL2') then Result:= 'No profile was found.';
  if (key = 'LANG_ERROR') then Result:= 'Error';
  if (key = 'LANG_DETEKCE') then Result:= '%s is running. Exit it and click the Retry button.';
  if (key = 'LANG_DETEKCE2') then Result:= 'You must exit %s before backing up. The program will exit.';
  if (key = 'LANG_CHOOSE_FILE_BACKUP') then Result:= 'Save backup to directory';
  if (key = 'LANG_CHOOSE_FILE_RESTORE') then Result:= 'Restore backup from directory';
  if (key = 'LANG_SEL_DESEL_ALL') then Result:= 'Select/Deselect all';
  if (key = 'LANG_CANNOT_RESTORE_ORIG_EXT') then Result:= 'Cannot restore external mail account to original location!';
  if (key = 'LANG_TEST_VERSION_WARNING') then Result:= 'This is test version. Use on your own risk.';

  if (key = 'LANG_BACKUP_PARTS') then Result:= 'Backup contains:';
  if (key = 'LANG_DISK_SPACE_CALCULATE') then Result:= 'Calculating disk space. This takes some time.';
  if (key = 'LANG_FILE') then Result:= 'File';
  if (key = 'LANG_PORTABLE_APPS') then Result:= 'Portable applications';

  if (key = 'LANG_NO_PROFILE_SELECTION') then Result:= 'No profile was selected.';

  if (key = 'LANG_CMD_BAD_ACTION') then Result:= 'Bad action defined in config file.';
  if (key = 'LANG_CMD_BAD_APPLICATION') then Result:= 'Bad application defined in config file.';
  if (key = 'LANG_CMD_BAD_PROFILE') then Result:= 'Cannot find profile with this name.';
  if (key = 'LANG_CMD_BAD_OUTPUT_DIR') then Result:= 'Cannot create directory for output file.';
  if (key = 'LANG_CMD_CONFIG_NOT_FOUND') then Result:= 'Cannot find config file %s.';

  if (key = 'LANG_BACKUP_FAILED') then Result:= 'Backup wasn''t successfully created.';
  if (key = 'LANG_WRITE_ERROR3') then Result:= 'The program can not write in the backup file. Either the disk is full or you do not have write permissions.';
  if (key = 'LANG_BACKUP_NOT_FOUND') then Result:= 'Selected backup file was not found. Please select valid backup file.';
  if (key = 'LANG_INVALID_BACKUP_VERSION') then Result:= 'Selected backup file is not for selected application. Selected application: %s, backup file is from application: %s.';
  if (key = 'LANG_FAT32_WARNING') then Result:= 'You want to store backup on drive which has FAT32 file system. On such file system you cannot create files larger than 4 GB. If you think your backup will be larger choose drive with NTFS file system. Do you want to continue?';
end;
// *** Public methods

// Return L10n string for section and key in this section
function Tl10n.getL10nString(section: String; key: String):String;
var msg: String;
begin
  msg:= iniL10n.ReadString(section, key, '');
  if Length (msg) = 0 then
    begin
      msg:= getDefaultL10nString(key);
    end
  else
    begin
    if (Config.TEST_MODE) then
      begin
        msg:= '!' + msg;
      end;
    end;

  Result:= msg;
end;

// Return L10n string for section, key in this section and param
function Tl10n.getL10nString(section: String; key: String; param: String):String;
var msg: String;
begin
  msg:= getL10nString (section, key);
  msg:= StringReplace (msg, '%s', param, []);

  Result:= msg;
end;

function Tl10n.getL10nString(section: String; key: String; param: String; param2: String):String;
var msg: String;
begin
  msg:= getL10nString (section, key);
  msg:= StringReplace (msg, '%s', param, []);
  msg:= StringReplace (msg, '%s', param2, []);

  Result:= msg;
end;

// Return default font
function Tl10n.getDefaultFont():String;
begin
  Result:= getL10nString('Common', 'Font');
end;

// Return default charset for locale
function Tl10n.getDefaultCharset():integer;
begin
  Result:= StrToInt (getL10nString('Common', 'DefaultCharset'));
end;

end.
