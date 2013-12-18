unit uOSDetails;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process;

function GetSourceOS : string;
function GetKernelDetails : string;
function GetDistroDetails : string;
function GetWindowsVer : string;

const STR_UNKNOWN = 'unknown';

implementation

function RunCommand(const cmd : string; const resultStr : TStringList) : integer;
var
  proc : TProcess;
begin
  proc := TProcess.Create(nil);
  try
    proc.Options := proc.Options + [poUsePipes,poStderrToOutPut];

    {$IFDEF MSWINDOWS}
    proc.ShowWindow := swoHIDE;
    proc.StartupOptions := [suoUseShowWindow];
    {$ENDIF}

    proc.CommandLine := cmd;

    try
      proc.Execute;
      while proc.Running do
       Sleep(10);

      //Execution finished one way or another
      if assigned(proc.Output) then
        resultStr.LoadFromStream(proc.Output);

    except on e:exception do
      resultStr.Text := e.Message;
    end;

    Result := proc.ExitStatus;
    //return result

  finally
    proc.Free;
  end;
end;

function RunCommand(const cmd : string) : string;
var
  response : TStringList;
begin
  response := TStringList.Create;
  try
    RunCommand(cmd,response);
    Result := Trim(response.Text);
  finally
    response.Free;
  end;
end;

function GetSourceOS : string;
begin
  Result := STR_UNKNOWN;
  {$IFDEF LINUX}
  Result := 'Linux';
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  Result := 'Windows';
  {$ENDIF}
  {$IFDEF DARWIN}
  Result := 'MacOS';
  {$ENDIF}
end;

function GetKernelDetails : string;
begin
  Result := STR_UNKNOWN;
  {$IFDEF LINUX}
  Result := RunCommand('uname -srpv');
  {$ENDIF}
  {$IFDEF DARWIN}
  Result := RunCommand('uname -srpv');
  {$ENDIF}
end;

function GetDistroDetails : string;
{$IFDEF LINUX or IFDEF DARWIN}
var
  response : TStringList;
  n : Integer;
  posColon : SizeInt;
  aLine : String;
{$ENDIF}
begin
  Result := STR_UNKNOWN;
  {$IFDEF LINUX}
  response := TStringList.Create;
  try
    RunCommand('lsb_release -a',response);
    for n := 0 to response.Count-1 do
    begin
      aLine := response[n];
      if Pos('Description:',aLine)=1 then
      begin
        posColon := Pos(':',aLine);
        Delete(aLine,1,posColon+1);
        Result := Trim(aLine);
        Exit;
      end;
    end;
  finally
    response.Free;
  end;
  {$ENDIF}
  {$IFDEF DARWIN}
  response := TStringList.Create;
  try
    RunCommand('sw_vers',response);
    for n := 0 to response.Count-1 do
    begin
      aLine := response[n];
      if Pos('ProductVersion:',aLine)=1 then
      begin
        posColon := Pos(':',aLine);
        Delete(aLine,1,posColon+1);
        Result := Format('Mac OS X %s',[Trim(aLine)]);;
        Exit;
      end;
    end;
  finally
    response.Free;
  end;
  {$ENDIF}

end;

function GetWindowsVer: string;
{$IFDEF MSWINDOWS}
var
  winVerString: String;
{$ENDIF}
begin
  Result := STR_UNKNOWN;
  {$IFDEF MSWINDOWS}
  winVerString := Format('%d.%d',[Win32MajorVersion,Win32MinorVersion]);
  case winVerString of
    '5.0' : Result := 'Windows 2000';
    '5.1' : Result := 'Windows XP';
    '5.2' : Result := 'Windows Server 2003';
    '6.0' : Result := 'Windows Vista';
    '6.1' : Result := 'Windows 7';
    '6.2' : Result := 'Windows 8';
    '6.3' : Result := 'Windows 8.1';
  else
    Result := Format('Windows (%d.%d)',[Win32MajorVersion,Win32MinorVersion]);
  {$ENDIF}
  end;
end;





end.

