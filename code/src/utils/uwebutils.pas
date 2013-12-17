unit uwebutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function HTTPEncode(const AStr: String): String;

implementation

function HTTPEncode(const AStr: String): String;
const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-'];
var
  Sp, Rp: PChar;
begin
  SetLength(Result, Length(AStr) * 3);
  Sp := PChar(AStr);
  Rp := PChar(Result);
  while Sp^ <> #0 do
  begin
    if Sp^ in NoConversion then
      Rp^ := Sp^
    else
      if Sp^ = ' ' then
        Rp^ := '+'
      else
      begin
        FormatBuf(Rp^, 3, '%%%.2x', 6, [Ord(Sp^)]);
        Inc(Rp,2);
      end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PChar(Result));
end;

end.

