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

unit UnknowFilesBL;

interface

uses Classes, Config, Forms, Hlavni, StrUtils, SysUtils, Dialogs, UnknowItem;

type TUnknowFilesBL = class
  private
    knowFiles: TList;
    
    procedure loadUnknowFiles();
  protected
  public
    constructor Create();
    function getKnowFiles():TList;
    function isKnowFile (filename: String; directory: boolean):boolean;
    function getUnknowFiles(directoryPath:String):TList;
end;

implementation

constructor TUnknowFilesBL.Create;
begin
  loadUnknowFiles();
end;

procedure TUnknowFilesBL.loadUnknowFiles();
var F: TextFile;
    S: String;    
begin
  knowFiles:= TList.Create;

  AssignFile (F, ExtractFilePath(Application.ExeName) + '\' + Config.KNOW_FILES_FILENAME);
  Reset (F);
  Repeat
    Readln (F, S);
    if Pos('*.*', S) > 0 then
      begin
        Delete (S, Length (Trim(S)) - 3, 4);
        knowFiles.Add(TUnknowItem.Create(s, true));
      end
    else
      begin
        knowFiles.Add(TUnknowItem.Create(s, false));
      end;
  Until Eof (F);
  CloseFile (F);
end;

function TUnknowFilesBL.getKnowFiles():TList;
begin
  Result:= knowFiles;
end;

{
  Return info, if file/directory which was found is know file/directory or not.

  filename  - file/directory which was found
  directory - info, if it is directory or not
}
function TUnknowFilesBL.isKnowFile (filename: String; directory: boolean):boolean;
var I: integer;
    knowFile: TUnknowItem;
    S: String;
begin
  Result:= false;

  if directory then
    begin
      filename:= filename + '\*.*';
    end;

  for I := 0 to knowFiles.Count - 1 do
    begin
      knowFile:= TUnknowItem(knowFiles[i]);
      S:= knowFile.getFilename;

      if knowFile.isDirectory then
        begin
          S:= S + '\*.*';
        end;

      if (Pos (filename, S) > 0) and
          (Length (S) = Length (filename)) then
        begin
          Result:= true;
        end;

        // contains char "*"
      if (Pos ('*', S) = 1) then
        begin
          Delete (S, 1, 1);
          if AnsiEndsStr (S, filename)  then
            begin
              Result:= true;
            end;
          
        end;
    end;    
end;

function TUnknowFilesBL.getUnknowFiles(directoryPath:String):TList;
var SearchRec: TSearchRec;
    list: TList;
begin
  list:= TList.Create;

  if FindFirst (directoryPath + '*.*', faAnyFile, SearchRec) = 0 then
    begin
      Repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          begin
            if DirectoryExists (directoryPath + SearchRec.Name) = true then
              begin
                if not isKnowFile (SearchRec.Name, true) then
                  begin
                    list.Add(TUnknowItem.Create (SearchRec.Name, true));
                  end;
              end
            else if FileExists (directoryPath + SearchRec.Name) = true then
              begin
                if not isKnowFile (SearchRec.Name, false) then
                  begin
                    list.Add(TUnknowItem.Create (SearchRec.Name, false));
                  end;
              end;
          end;
      Until FindNext (SearchRec) <> 0;
    end;
  SysUtils.FindClose (SearchRec);

  Result:= list;
end;

end.
