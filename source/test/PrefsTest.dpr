program PrefsTest;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  PrefsParser in '..\PrefsParser.pas',
  PrefsParserAccount in '..\PrefsParserAccount.pas',
  Utils in '..\Utils.pas',
  Functions in 'Functions.pas';

var PrefsParser: TPrefsParser;
    F: TextFile;
    S: String;

begin
  Assign (F, 'prefs\index.txt');
  Reset (F);
  Repeat
    Readln (F, S);

  PrefsParser:= TPrefsParser.Create('prefs\' + s + '.js');
  testPrefsLoader (PrefsParser, 'prefs\' + s + '.txt');
  until eof (f);
  Close (F);
end.
