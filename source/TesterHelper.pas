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

unit TesterHelper;

interface

uses SysUtils;

procedure initTests();
procedure resetTestCount();
procedure writeResults();

function assertInt(TestName: String; Value1: integer; Value2: integer):boolean;
function assertBoolean(TestName: String; Value1: boolean; Value2: boolean):boolean;
function assertString(TestName: String; Value1: String; Value2: String):boolean;

implementation

var RunnedTests: integer;
    FailedTests: integer;

//***************************** Control rutines ******************************    

procedure initTests();
begin
  RunnedTests:= 0;
  FailedTests:= 0;
end;

procedure resetTestCount();
begin
  initTests();
end;

procedure writeResults();
begin
  Writeln ('Runned tests count: ' + IntToStr (RunnedTests));
  Writeln ('Failed tests count: ' + IntToStr (FailedTests));
  Writeln (' ');
  if (FailedTests = 0) then
    begin
      Writeln ('All tests are OK.');
    end
  else
    begin
      Writeln ('Some tests failed!!!!!!!!');
    end;

end;

//****************************************************************************

function assertInt(TestName: String; Value1: integer; Value2: integer):boolean;
begin
  Result:= true;

  if (Value1 <> Value2) then
    begin
      Writeln ('Test ' + TestName + ' failed. Get: "' + IntToStr (Value1) +
      '", but requested: "' + IntToStr (Value2) + '".'); // NO L10N
      FailedTests:= FailedTests + 1;
      Result:= false;
    end;
  RunnedTests:= RunnedTests + 1;
end;

function assertBoolean(TestName: String; Value1: boolean; Value2: boolean):boolean;
begin
  Result:= true;

  if (Value1 <> Value2) then
    begin
      Writeln ('Test ' + TestName + ' failed. Get: "' + BoolToStr (Value1) +
      '", but requested: "' + BoolToStr (Value2) + '".'); // NO L10N
      FailedTests:= FailedTests + 1;
      Result:= false;
    end;
  RunnedTests:= RunnedTests + 1;
end;

function assertString(TestName: String; Value1: String; Value2: String):boolean;
begin
  Result:= true;

  if (Value1 <> Value2) then
    begin
      Writeln ('Test ' + TestName + ' failed. Get: "' + Value1 +
      '", but requested: "' + Value2 + '".'); // NO L10N
      FailedTests:= FailedTests + 1;
      Result:= false;
    end;
  RunnedTests:= RunnedTests + 1;
end;

end.
