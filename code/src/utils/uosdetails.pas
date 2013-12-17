unit uOSDetails;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process;

function GetSourceOS : string;
function GetKernelDetails : string;
function GetDistroDetails : string;

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
  Result := '<unknown>';
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
  Result := '<unknown>';
  {$IFDEF LINUX}
  Result := RunCommand('uname -srpv');
  {$ENDIF}
end;

function GetDistroDetails : string;
var
  response : TStringList;
  n : Integer;
  posColon : SizeInt;
  aLine : String;
begin
  Result := '<unknown>';
  {$IFDEF LINUX}
  response := TStringList.Create;
  try
    RunCommand('lsb_release -a',response);
    for n := 0 to response.Count-1 do
    begin
      aLine := response[n];
      if Pos('Description:',aLine)>0 then
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
end;





end.

