unit uspbaseform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

const
  INT_FORM_POSITON_OFFSET = 20; // we use 20 because various os's behave differently as regards their toolbars

type

  { TSPBaseForm }

  TSPBaseForm = class(TForm)
  private
    procedure EnsureFormIsVisibleOnScreen;
  public
    procedure AfterConstruction; override;
  end;

implementation


procedure TSPBaseForm.EnsureFormIsVisibleOnScreen;
var
  currentMonitor: TMonitor;
begin
  currentMonitor := Screen.MonitorFromPoint(Point(Self.Left,Self.Top),TMonitorDefaultTo.mdNull);

  //if on a valid monitor
  if assigned(currentMonitor) then
    Exit;

  //if not on a valid monitor
  Self.Left := Screen.PrimaryMonitor.WorkareaRect.Left+INT_FORM_POSITON_OFFSET;
  Self.Top := Screen.PrimaryMonitor.WorkareaRect.Top+INT_FORM_POSITON_OFFSET;
end;

procedure TSPBaseForm.AfterConstruction;
begin
  EnsureFormIsVisibleOnScreen;
  inherited AfterConstruction;
end;

{$R *.lfm}

end.

