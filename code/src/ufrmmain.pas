unit ufrmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Buttons, uspbaseform;

type

  { TfrmMain }

  TfrmMain = class(TSPBaseForm)
    btnYes : TBitBtn;
    btnNo : TBitBtn;
    Label1 : TLabel;
    lblShareInfo : TLabel;
    lblSeeSharedInfo : TLabel;
    lblProductName : TLabel;
    mmValues : TMemo;
    pnlShareInfo : TPanel;
    StatusBar1 : TStatusBar;
    procedure btnNoClick(Sender : TObject);
    procedure btnYesClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure lblSeeSharedInfoClick(Sender : TObject);
  private
    FFullOSString : string;
    FPlatformTestInfo : string;
    procedure AddValue(const aName,aValue : string);
    procedure AddResourceStrings;
    procedure AddSeperator(const aName : string);
    procedure AddSeperator;
    procedure AddOSDetails;
    procedure RegisterPlatformTest;
  public
    { public declarations }
  end;

var
  frmMain : TfrmMain;

const
  STR_SERVER_TESTS_URL = 'http://soft-practice.com/lazarus-platform-tests';

implementation

uses uSettings, HTTPDefs, LCLIntf, ufrmLog, uVersionInfo, uOSDetails;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender : TObject);

begin
  lblProductName.Caption := Settings.ProductName;

  AddSeperator('Build Details');
  AddValue('Version',Settings.ProductVersion);
  AddValue('Build date', GetCompiledDate);
  AddValue('Compiler version',GetCompilerInfo);
  AddValue('Source OS',GetSourceOS);
  AddValue('LCL version',GetLCLVersion);
  AddValue('Widgetset',GetWidgetSet);
  AddValue('Compile Target',GetTargetInfo);

  AddSeperator;
  AddSeperator('Runtime Details');
  AddValue('Operating System',GetOS);
  AddOSDetails;
  AddValue('User dir',GetUserDir);
  AddValue('Config dir (global)',GetAppConfigDir(true));
  AddValue('Config dir (user)',GetAppConfigDir(false));

  AddSeperator;
  AddSeperator('Resource Strings');
  AddResourceStrings;

  lblShareInfo.Caption := format('Lazarus apps compiled with %s %s on %s using %s run on %s',[GetLCLVersion, GetCompilerInfo,GetSourceOS,GetWidgetSet,FFullOSString]);
  FPlatformTestInfo := format('lcl=%s&fpc=%s&srcos=%s&widget=%s&runos=%s',[HTTPEncode(GetLCLVersion), HTTPEncode(GetCompilerInfo),HTTPEncode(GetSourceOS),HTTPEncode(GetWidgetSet),HTTPEncode(FFullOSString)]);

end;

procedure TfrmMain.btnNoClick(Sender : TObject);
begin
  Debug('btnNo clicked - sad :(');
end;

procedure TfrmMain.btnYesClick(Sender : TObject);
begin
  Debug('btnYes clicked - yay :)');
  RegisterPlatformTest;
end;

procedure TfrmMain.lblSeeSharedInfoClick(Sender : TObject);
begin
  OpenURL(STR_SERVER_TESTS_URL);
end;

procedure TfrmMain.AddValue(const aName, aValue : string);
var
  valueStr : String;
begin
  valueStr := Format('%s: %s',[aName,aValue]);
  mmValues.Lines.Add(valueStr);
  Debug(valueStr);
end;

procedure TfrmMain.AddResourceStrings;
var
  resStrings : TStringList;
  n : Integer;
  aPos : SizeInt;
begin
  resStrings := TStringList.Create;
  try
    if GetResourceStrings(resStrings) then
    begin
      for n := 0 to resStrings.Count-1 do
      begin
        aPos := Pos('=',resStrings[n]);
        AddValue(LeftStr(resStrings[n],aPos-1),RightStr(resStrings[n],Length(resStrings[n])-aPos));
      end;
    end;
  finally
    resStrings.Free;
  end;
end;

procedure TfrmMain.AddSeperator(const aName : string);
begin
  mmValues.Lines.Add(Format('-- %s --',[aName]));
end;

procedure TfrmMain.AddSeperator;
begin
  mmValues.Lines.Add('');
end;

procedure TfrmMain.AddOSDetails;
begin
  {$IFDEF MSWINDOWS}
  FFullOSString := GetWindowsVer;
  AddValue('Windows version',FFullOSString);
  {$ENDIF}
  {$IFDEF LINUX}
  FFullOSString := GetDistroDetails;
  AddValue('Linux distro',FFullOSString);
  AddValue('Kernel details',GetKernelDetails);
  {$ENDIF}
  {$IFDEF DARWIN}
  FFullOSString := GetDistroDetails;
  AddValue('Linux distro',FFullOSString);
  AddValue('Kernel details',GetKernelDetails);
  {$ENDIF}

end;

procedure TfrmMain.RegisterPlatformTest;
var
  testURL : String;
begin
  testURL := format('%s?%s',[STR_SERVER_TESTS_URL,FPlatformTestInfo]);
  Debug('Registering platform test: %s',[testURL]);
  OpenURL(testURL);
end;

end.

