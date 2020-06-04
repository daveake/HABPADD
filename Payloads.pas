unit Payloads;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TargetForm, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, Miscellaneous, Source,
  FMX.Colors, FMX.Objects, Math;

type
  TfrmPayloads = class(TfrmTarget)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    procedure pnlMainResized(Sender: TObject);
  private
    { Private declarations }
    Rectangles: Array[1..3] of TRectangle;
    Labels: Array[1..3, 0..8] of TLabel;
  public
    { Public declarations }
    procedure NewPosition(Index: Integer; HABPosition: THABPosition); override;
    procedure ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
  end;

var
  frmPayloads: TfrmPayloads;

implementation

{$R *.fmx}

uses Main;

function RepeatString(Repeated: Boolean): String;
begin
    if Repeated then begin
        Result := ' (R)';
    end else begin
        Result := '';
    end;
end;

procedure TfrmPayloads.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        Labels[Index,0].Text := HABPosition.PayloadID;
        Labels[Index,1].Text := '00:00' + RepeatString(HABPosition.Repeated);
        Labels[Index,2].Text := HABPosition.Counter.ToString;
        Labels[Index,3].Text := FormatDateTime('hh:mm:ss', HABPosition.TimeStamp);
        Labels[Index,4].Text := FormatFloat('0.00000', HABPosition.Latitude) + ',' + FormatFloat('0.00000', HABPosition.Longitude);
        if HABPosition.MaxAltitude > HABPosition.Altitude then begin
            Labels[Index,5].Text := HABPosition.Altitude.ToString + 'm (' + HABPosition.MaxAltitude.ToString + 'm)';
        end else begin
            Labels[Index,5].Text := HABPosition.Altitude.ToString + 'm';
        end;
        Labels[Index,6].Text := FormatFloat('0.0', HABPosition.AscentRate) + ' m/s';

        Labels[Index,7].Text := FormatFloat('0.0', HABPosition.Distance / 1000) + ' km, ' + FormatFloat('0.0', HABPosition.Elevation) + '°';

        if HABPosition.ContainsPrediction then begin
            Labels[Index,8].Text := FormatFloat('0.00000', HABPosition.PredictedLatitude) + ',' + FormatFloat('0.00000', HABPosition.PredictedLongitude);
        end;
    end;
end;

procedure TfrmPayloads.pnlMainResized(Sender: TObject);
var
    i, j: Integer;
    LabelHeight: Double;
begin
    LabelHeight := (Rectangle1.Height - 16) / 9;

    if Rectangles[1] = nil then begin
        Rectangles[1] := Rectangle1;
        Rectangles[2] := Rectangle2;
        Rectangles[3] := Rectangle3;

        // Create labels
        for i := 1 to 3 do begin
            for j := 0 to 8 do begin
                Labels[i,j] := TLabel.Create(nil);
                Labels[i,j].Parent := Rectangles[i];
                Labels[i,j].Position.X := 0;
                Labels[i,j].Height := LabelHeight;
                Labels[i,j].Width := Rectangles[i].Width;
                Labels[i,j].Position.Y := Round(8 + LabelHeight * j);
                Labels[i,j].TextSettings.Font.Family := 'Arial';    // Swiss911 XCm BT';
                Labels[i,j].TextSettings.FontColor := TAlphaColorRec.Yellow;
                Labels[i,j].TextSettings.HorzAlign := TTextAlign.Center;
                Labels[i,j].Align := TAlignLayout.Scale;
                Labels[i,j].StyledSettings := [];
                Labels[i,j].Visible := True;
            end;
        end;
    end;

    // Resize labels
    for i := 1 to 3 do begin
        for j := 0 to 8 do begin
            // Labels[i,j].TextSettings.Font.Size := min(LabelHeight * 0.95, Labels[i,j].Width / 6.5);
            Labels[i,j].TextSettings.Font.Size := LabelHeight * 0.5;
        end;
    end;
end;

procedure TfrmPayloads.ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; Repeated: Boolean);
begin
    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        Labels[Index,1].Text := FormatDateTime('nn:ss', TimeSinceUpdate) + RepeatString(Repeated);
    end;
end;


end.
