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
    Labels: Array[1..3, 0..12] of TLabel;
  public
    { Public declarations }
    procedure NewPosition(Index: Integer; HABPosition: THABPosition); override;
    procedure ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; PayloadID: String; Repeated: Boolean);
  end;

var
  frmPayloads: TfrmPayloads;

implementation

{$R *.fmx}

uses Main;

function RepeatString(Repeated: Boolean): String;
begin
    if Repeated then begin
        Result := '-R';
    end else begin
        Result := '';
    end;
end;

procedure TfrmPayloads.NewPosition(Index: Integer; HABPosition: THABPosition);
begin
    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        if HABPosition.InUse then begin
            Labels[Index,0].Text := HABPosition.PayloadID + ' (00:00)' + RepeatString(HABPosition.Repeated);
            Labels[Index,1].Text := '(' + HABPosition.Counter.ToString + ') ' + FormatDateTime('hh:mm:ss', HABPosition.TimeStamp);
            Labels[Index,2].Text := FormatFloat('0.00000', HABPosition.Latitude) + ', ' + FormatFloat('0.00000', HABPosition.Longitude);
            if HABPosition.MaxAltitude > HABPosition.Altitude then begin
                Labels[Index,3].Text := HABPosition.Altitude.ToString + 'm (' + HABPosition.MaxAltitude.ToString + 'm)';
            end else begin
                Labels[Index,3].Text := HABPosition.Altitude.ToString + 'm';
            end;
            Labels[Index,4].Text := FormatFloat('0.0', HABPosition.AscentRate) + ' m/s';

            Labels[Index,5].Text := FormatFloat('0.0', HABPosition.Distance / 1000) + ' km, ' + FormatFloat('0.0', HABPosition.Elevation) + '°';

            if HABPosition.PredictionType <> ptNone then begin
                Labels[Index,6].Text := FormatFloat('0.00000', HABPosition.PredictedLatitude) + ', ' + FormatFloat('0.00000', HABPosition.PredictedLongitude);
            end;
        end;

        if HABPosition.TelemetryCount > 0 then begin
            Labels[Index,7].Text := 'Telemetry Count: ' + HABPosition.TelemetryCount.ToString;
        end;

        if HABPosition.HasFrequency then begin
            Labels[Index,8].Text := 'Frequency Error: ' + MyFormatFloat('0', HABPosition.FrequencyError*1000) + ' Hz';
        end;

        if HABPosition.HasPacketRSSI then begin
            Labels[Index,9].Text := 'Packet RSSI: ' + HABPosition.PacketRSSI.ToString + ' dB';
        end;

        if HABPosition.SSDVCount > 0 then begin
            Labels[Index,10].Text := 'SSDV Count: ' + HABPosition.SSDVCount.ToString;
        end;

        if HABPosition.IsSSDV then begin
            Labels[Index,11].Text :=  'Image: ' + HABPosition.SSDVFileNumber.ToString + ' Packet: ' + HABPosition.SSDVPacketNumber.ToString;
        end;

        if HABPosition.FlightMode = fmLanded then begin
            Labels[Index,12].Text := 'Landed';
        end else if HABPosition.FlightMode = fmDescending then begin
            if HABPosition.DescentTime > 0 then begin
                Labels[Index,12].Text := 'Desc: ' + FormatDateTime('nn:ss', HABPosition.DescentTime);
            end;
        end else if HABPosition.FlightMode = fmLaunched then begin
            Labels[Index,12].Text := 'Ascending';
        end else begin
            Labels[Index,12].Text := '';
        end;
    end;
end;

procedure TfrmPayloads.pnlMainResized(Sender: TObject);
var
    i, j: Integer;
    MainLabelHeight, MetaLabelHeight, Top: Double;
begin
    inherited;

    MainLabelHeight := (Rectangle1.Height - 16) / 11;
    MetaLabelHeight := (Rectangle1.Height - 16) / 16;

    if Rectangles[1] = nil then begin
        Rectangles[1] := Rectangle1;
        Rectangles[2] := Rectangle2;
        Rectangles[3] := Rectangle3;

        // Create labels
        for i := 1 to 3 do begin
            Top := 0;
            for j := 0 to 12 do begin
                Labels[i,j] := TLabel.Create(nil);
                Labels[i,j].Parent := Rectangles[i];
                Labels[i,j].Position.X := 0;
                if j <= 6 then begin
                    Labels[i,j].Height := MainLabelHeight;
                end else begin
                    Labels[i,j].Height := MetaLabelHeight;
                end;
                Labels[i,j].Width := Rectangles[i].Width;
                Labels[i,j].Position.Y := Round(Top);
                Labels[i,j].TextSettings.Font.Family := 'Arial';    // Swiss911 XCm BT';
                Labels[i,j].TextSettings.FontColor := TAlphaColorRec.Yellow;
                Labels[i,j].TextSettings.HorzAlign := TTextAlign.Center;
                Labels[i,j].Align := TAlignLayout.Scale;
                Labels[i,j].StyledSettings := [];
                Labels[i,j].Visible := True;
                Top := Top + Labels[i,j].Height;
            end;
        end;
    end;

    // Resize labels
    for i := 1 to 3 do begin
        for j := 0 to 12 do begin
            // Labels[i,j].TextSettings.Font.Size := min(LabelHeight * 0.95, Labels[i,j].Width / 6.5);
            Labels[i,j].TextSettings.Font.Size := Labels[i,j].Height * 0.5;
        end;
    end;
end;

procedure TfrmPayloads.ShowTimeSinceUpdate(Index: Integer; TimeSinceUpdate: TDateTime; PayloadID: String; Repeated: Boolean);
begin
    if (Index >= Low(Rectangles)) and (Index <= High(Rectangles)) then begin
        Labels[Index,0].Text := PayloadID + ' (' + FormatDateTime('nn:ss', TimeSinceUpdate) + ')' + RepeatString(Repeated);
    end;
end;


end.
