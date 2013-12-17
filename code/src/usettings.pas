unit uSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uSPBaseSettings;

type

  { TSettings }

  TSettings = class(TSPBaseSettings)
    constructor Create;
    procedure DebugSettingsStartup; override;
  end;

function Settings : TSettings;

implementation

uses ufrmLog;

function Settings : TSettings;
begin
  if not assigned(TSettings._Instance) then
    TSettings._Instance := TSettings.Create;
  Result := TSettings._Instance as TSettings;
end;

constructor TSettings.Create;
begin
  ProductVersionID := 001;
  ProductVersion := 'v0.0.1 - alpha';
  InternalName := 'lazarus_platform_test';
  ProductName := 'Lazarus Platform Test';
  ProductDescription := 'Test application that tests executables on different platforms';
end;

procedure TSettings.DebugSettingsStartup;
begin
  Debug('Settings Loaded');
end;

{ TSettings }


end.

