unit ufrmLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, Buttons, uspbaseform;
type

  { TfrmLog }

  TfrmLog = class(TSPBaseForm)
    actClearLog : TAction;
    actLog : TActionList;
    actSaveLog : TAction;
    imgsLog : TImageList;
    mmLog : TMemo;
    dlgSaveLog : TSaveDialog;
    SpeedButton1 : TSpeedButton;
    SpeedButton2 : TSpeedButton;
    tlbPendingChanges : TToolBar;
    procedure actClearLogExecute(Sender : TObject);
    procedure actSaveLogExecute(Sender : TObject);
    procedure FormCreate(Sender : TObject);
  private
    procedure ClearLog;
    procedure SaveLog;
    procedure DoSaveLogFile;
  public
    procedure AddLine(const str : string);
    destructor Destroy; override;
  end;

  { TLogger }

  TLogger = class(TObject)
  private
    _Instance : TLogger; static;
    _InstanceDestroyed : boolean; static;
    _LoggerEnabled : boolean; static;
    tempLog : TStringList;
    {%H-}constructor Create;
  public
    procedure AddLine(const str : string);
    destructor Destroy; override;
  end;


  TLogType = (ltDebug, ltWarning,ltError);

//wow, these global variables suck! -MMD
var
  frmLog : TfrmLog;
  _lastMsg : String;

procedure Debug(const str : String; const aLogType : TLogType = ltDebug); overload;
procedure Debug(Const Fmt : String; const Args : Array of const; const aLogType : TLogType = ltDebug); overload;

implementation

uses uSettings, LCLProc;

{$R *.lfm}

function Logger : TLogger;
begin
  if not assigned(TLogger._Instance) then
    TLogger._Instance := TLogger.Create;
  Result := TLogger._Instance;
end;

procedure Logger_AddLine(const str : string);
begin
  if (not TLogger._LoggerEnabled) or TLogger._InstanceDestroyed then
    Exit;
  Logger.AddLine(str);
end;

procedure OutputDebugLn(const str : string);
begin
  Logger_AddLine(str);
  DebugLn(str);
end;

procedure OutputDebugLn(const Fmt : String; const Args : array of const);
begin
  OutputDebugLn(Format(Fmt,Args));
end;

procedure Debug(const str: String; const aLogType: TLogType);
begin
  if (str = '') and (_lastMsg <> str) then
  begin
    OutputDebugLn('');
    _lastMsg := '';
  end
  else
  begin
    if (str <> _lastMsg) and (aLogType = ltDebug) then
    begin
      _lastMsg := str;
      OutputDebugLn(Format('Log: %s - %s', [DateTimeToStr(Now), str]));
    end
    else if (aLogType = ltWarning) then
      OutputDebugLn(Format('Warning: %s - %s', [DateTimeToStr(Now), str]))
    else if (aLogType = ltError) then
      OutputDebugLn(Format('Error: %s - %s', [DateTimeToStr(Now), str]))
  end;
end;

procedure Debug(const Fmt: String; const Args: array of const;
  const aLogType: TLogType);
begin
  try
    Debug(Format(Fmt,Args),aLogType);
  except on e:exception do
    Debug('Badly formatted debug message: %s::%s "%s"',[e.ClassName,e.message, Fmt],ltError);
  end;
end;


constructor TLogger.Create;
begin
  tempLog := TStringList.Create;
end;

procedure TLogger.AddLine(const str : string);
begin
  if not assigned(frmLog) then
    tempLog.Append(str)
  else
  begin
    if tempLog.Text <> '' then
    begin
      frmLog.AddLine(tempLog.Text);
      tempLog.Clear;
    end;
    frmLog.AddLine(str);
  end;
end;

destructor TLogger.Destroy;
begin
  tempLog.Free;
  inherited Destroy;
end;



{ TfrmLog }

procedure TfrmLog.FormCreate(Sender : TObject);
begin
  {$IFDEF DARWIN}
    mmLog.Font.Bold := false;
  {$ENDIF}
  if Logger.tempLog.Text <> '' then
  begin
    AddLine(Logger.tempLog.Text);
    Logger.tempLog.Clear;
  end;
end;


procedure TfrmLog.ClearLog;
begin
  mmLog.Clear;
end;

procedure TfrmLog.SaveLog;
begin
  if dlgSaveLog.Execute then
    mmLog.Lines.SaveToFile(dlgSaveLog.FileName);
end;

procedure TfrmLog.DoSaveLogFile;
begin
  if assigned(mmLog) then
    mmLog.Lines.SaveToFile(Settings.LogFileName);
end;

procedure TfrmLog.AddLine(const str : string);
begin
  mmLog.Append(str);
  mmLog.VertScrollBar.Position := mmLog.VertScrollBar.Range;

  //Automatically save log on every change
  DoSaveLogFile;
  //mmLog.Invalidate;
  //mmLog.Update;
  //mmLog.Refresh;
end;

destructor TfrmLog.Destroy;
begin
  Debug('Saving log to "%s"',[Settings.LogFileName]);
  Debug('Internal Logging Window Closing...');
  Debug('=== Shutting down %s - Thanks for using it ===',[Settings.ProductName]);

  DoSaveLogFile;
  inherited Destroy;
  TLogger._InstanceDestroyed := true;
end;


procedure TfrmLog.actClearLogExecute(Sender : TObject);
begin
  ClearLog;
end;

procedure TfrmLog.actSaveLogExecute(Sender : TObject);
begin
  SaveLog;
end;


initialization
  frmLog := nil;
  TLogger._LoggerEnabled := true;
  TLogger._InstanceDestroyed := false;

finalization
  if assigned(TLogger._Instance) then
  begin
    FreeAndNil(TLogger._Instance);
    TLogger._InstanceDestroyed := true;
  end;
end.

