program LazarusPlatformTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, ufrmMain, ufrmLog, uSPBaseSettings, usettings, uVersionInfo, 
uOSDetails, uwebutils;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;

  Settings.Startup;

  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLog, frmLog);

  frmLog.Show;

  Application.Run;
end.

