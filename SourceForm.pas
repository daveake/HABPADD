unit SourceForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Controls.Presentation, FMX.Objects, SourceLog;

type
  TfrmSource = class(TfrmBase)
    rectLeft: TRectangle;
    lblCaption: TLabel;
    rectInfo: TRectangle;
    lblInfo: TLabel;
    lblValue: TLabel;
    rectMain: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    frmSourceLog: TfrmSourceLog;
    procedure WriteToLog(Msg: String);
  end;

implementation

uses Main;

{$R *.fmx}

procedure TfrmSource.FormCreate(Sender: TObject);
begin
    inherited;
    frmSourceLog := TfrmSourceLog.Create(Self);
end;

procedure TfrmSource.Label2Click(Sender: TObject);
begin
    frmMain.LoadForm(nil, frmSourceLog);
end;

procedure TfrmSource.WriteToLog(Msg: String);
begin
    frmSourceLog.WriteToLog(Msg);
end;

//procedure TfrmSources.rectGW1Resize(Sender: TObject);
//var
//    i, FontSize: Integer;
//begin
//    FontSize := Round(lblSerialRSSI.Width / 64);
//
//    for i := Low(Sources) to High(Sources) do begin
//        if Sources[i].ValueLabel <> nil then begin
//            Sources[i].ValueLabel.TextSettings.Font.Size := FontSize;
//        end;
//        if Sources[i].RSSILabel <> nil then begin
//            Sources[i].RSSILabel.TextSettings.Font.Size := FontSize;
//        end;
//    end;
//
//    lblGPS.TextSettings.Font.Size := FontSize;
//    lblDirection.TextSettings.Font.Size := FontSize;
//end;
//

end.
