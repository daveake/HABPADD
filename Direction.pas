unit Direction;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TargetForm, FMX.Controls.Presentation, FMX.TMSBaseControl, FMX.TMSGauge,
  Source, Math, Miscellaneous, FMX.Objects;

type
  TfrmDirection = class(TfrmTarget)
    lblAltitude: TLabel;
    lblAscentRate: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    lblLatitude: TLabel;
    lblDistance: TLabel;
    Label5: TLabel;
    lblElevation: TLabel;
    Label9: TLabel;
    lblTTL: TLabel;
    chkPrediction: TLabel;
    StyleBook1: TStyleBook;
    TMSFMXCompass1: TTMSFMXCompass;
    Label6: TLabel;
    lblCompass: TLabel;
    procedure chkPredictionClick(Sender: TObject);
    procedure pnlMainResized(Sender: TObject);
    procedure tmrUpdatesTimer(Sender: TObject);
  private
    { Private declarations }
  protected
  protected
    function ProcessNewPosition(Index: Integer): Boolean; override;
    procedure ProcessNewDirection(Index: Integer); override;
  public
    { Public declarations }
    procedure LoadForm; override;
    procedure HideForm; override;
  end;

var
  frmDirection: TfrmDirection;

implementation

uses Debug;

{$R *.fmx}

function CalculateDistance(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
begin
    // Return distance in metres

    HABLatitude := HABLatitude * Pi / 180;
    HabLongitude := HABLongitude * Pi / 180;
    CarLatitude := CarLatitude * Pi / 180;
    CarLongitude := CarLongitude * Pi / 180;

    Result := 6371000 * arccos(sin(CarLatitude) * sin(HABLatitude) +
                               cos(CarLatitude) * cos(HABLatitude) * cos(HABLongitude-CarLongitude));
end;

function CalculateDirection(HABLatitude, HabLongitude, CarLatitude, CarLongitude: Double): Double;
var
    x, y: Double;
begin
    HABLatitude := HABLatitude * Pi / 180;
    HabLongitude := HABLongitude * Pi / 180;
    CarLatitude := CarLatitude * Pi / 180;
    CarLongitude := CarLongitude * Pi / 180;

    y := sin(HABLongitude - CarLongitude) * cos(HABLatitude);
    x := cos(CarLatitude) * sin(HABLatitude) - sin(CarLatitude) * cos(HABLatitude) * cos(HABLongitude - CarLongitude);

    Result := ArcTan2(y, x);    // * 180 / Pi;
end;

procedure TfrmDirection.LoadForm;
begin
    inherited;

end;

procedure TfrmDirection.pnlMainResized(Sender: TObject);
begin
    inherited;

    if Positions[0].Position.Inuse and Positions[SelectedIndex].Position.InUse then begin
        ProcessNewDirection(SelectedIndex);
    end;

//    TMSFMXCompass1.Width := min(Label3.Position.X, pnlMain.Height * 0.95);
//    TMSFMXCompass1.Height := TMSFMXCompass1.Width;
//
//    TMSFMXCompass1.Position.X := (Label3.Position.X - TMSFMXCompass1.Width) / 0 + 202;
//    TMSFMXCompass1.Position.Y := (pnlMain.Height - TMSFMXCompass1.Height) / 2;
end;

procedure TfrmDirection.chkPredictionClick(Sender: TObject);
begin
    LCARSLabelClick(Sender);
    if Positions[0].Position.Inuse and Positions[SelectedIndex].Position.InUse then begin
        ProcessNewDirection(SelectedIndex);
    end;
end;

procedure TfrmDirection.HideForm;
begin
    inherited;
end;

procedure TfrmDirection.ProcessNewDirection(Index: Integer);
var
    Distance, Direction, Elevation: Double;
begin
    inherited;

    if LCARSLabelIsChecked(chkPrediction) and (Positions[SelectedIndex].Position.PredictionType <> ptNone) then begin
        Distance := Positions[SelectedIndex].Position.PredictionDistance;
        Direction := Positions[SelectedIndex].Position.PredictionDirection;
    end else begin
        Distance := Positions[SelectedIndex].Position.Distance;
        Direction := Positions[SelectedIndex].Position.Direction;
    end;

    TMSFMXCompass1.NeedStyleLookup;
    TMSFMXCompass1.ApplyStyleLookup;
    if TMSFMXCompass1.GetNeedle <> nil then begin
        TMSFMXCompass1.GetNeedle.RotationAngle := Direction * 180 / Pi;
    end;

    if Distance >= 1000 then begin
        lblDistance.Text := MyFormatFloat('0.0', Distance/1000) + ' km';
        // TMSFMXCompass1.GetDisplayText.Text := MyFormatFloat('0.0', Distance/1000) + ' km';
    end else begin
        lblDistance.Text := MyFormatFloat('0', Distance) + ' m';
    end;

    Elevation := Positions[SelectedIndex].Position.Elevation;

    // Altitude, or vertical distance to payload, as appropriate
//    if not IsNan(Positions[0].Position.Altitude) then begin
//        if Positions[SelectedIndex].Position.Altitude >= (Positions[0].Position.Altitude + 2000) then begin
//            lblRelativeAltitude.Text := '';
//        end else if Positions[SelectedIndex].Position.Altitude >= Positions[0].Position.Altitude then begin
//            lblRelativeAltitude.Text := '+' + IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
//        end else begin
//            lblRelativeAltitude.Text := IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
//        end;
//    end;

    if Positions[SelectedIndex].Position.FlightMode = fmDescending then begin
//        Seconds := CalculateDescentTime(Positions[SelectedIndex].Position.Altitude, -Positions[SelectedIndex].Position.AscentRate, Positions[0].Position.Altitude);

//        if Seconds >= 60 then begin
//            lblTTL.Text := FormatFloat('0', Seconds / 60) + ' min';
//        end else begin
//            lblTTL.Text := FormatFloat('0', Seconds) + ' s';
//        end;
        lblTTL.Text := FormatDateTime('nn:ss', Positions[SelectedIndex].Position.DescentTime);
    end else begin
        lblTTL.Text := '';
    end;

    lblElevation.Text := FormatFloat('0', Elevation) + ' °';
end;

function TfrmDirection.ProcessNewPosition(Index: Integer): Boolean;
begin
    if (SelectedIndex > 0) and (Index = SelectedIndex) then begin
        with Positions[SelectedIndex].Position do begin
            lblLatitude.Text := FormatFloat('0.00000', Latitude) + ',' + FormatFloat('0.00000', Longitude);
            // lblLongitude.Text := FormatFloat('0.00000', Longitude);
            lblAltitude.Text := FormatFloat('0', Altitude) + 'm';
            lblAscentRate.Text := FormatFloat('0.0', AscentRate) + 'm/s';
        end;
    end else if Index = 0 then begin
        if Positions[0].Position.UsingCompass then begin
            lblCompass.Text := 'MAG';
        end else begin
            lblCompass.Text := 'GPS';
        end;
    end;

    Result := inherited;
end;

procedure TfrmDirection.tmrUpdatesTimer(Sender: TObject);
begin
    if TMSFMXCompass1.RotationAngle <> -Positions[0].Position.Direction then begin
        TMSFMXCompass1.RotationAngle := - Positions[0].Position.Direction;          // minus because we need to orientate the screen compass so it correctly shows North
    end;
end;

end.
