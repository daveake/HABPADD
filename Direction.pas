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
    chkPrediction: TLabel;
    crcCompass: TCircle;
    crcDot: TCircle;
    Label1: TLabel;
    lblDistance: TLabel;
    lblRelativeAltitude: TLabel;
    lblAscentRate: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    lblLatitude: TLabel;
    Label6: TLabel;
    lblLongitude: TLabel;
    Label5: TLabel;
    lblElevation: TLabel;
    Label9: TLabel;
    lblTTL: TLabel;
    procedure chkPredictionClick(Sender: TObject);
    procedure pnlMainResized(Sender: TObject);
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
    Distance, Direction, Elevation, Radius, Seconds: Double;
begin
    inherited;

    if LCARSLabelIsChecked(chkPrediction) and Positions[SelectedIndex].Position.ContainsPrediction then begin
        Distance := Positions[SelectedIndex].Position.PredictionDistance;
        Direction := Positions[SelectedIndex].Position.PredictionDirection;
    end else begin
        Distance := Positions[SelectedIndex].Position.Distance;
        Direction := Positions[SelectedIndex].Position.Direction;
    end;

    Elevation := Positions[SelectedIndex].Position.Elevation;

    if Distance < 2000 then begin
        lblDistance.Text := FormatFloat('0', Distance) + 'm';
    end else begin
        lblDistance.Text := FormatFloat('0.0', Distance/1000) + 'km';
    end;

    Radius := Min(crcCompass.Width, crcCompass.Height) / 2;
    Radius := Radius * (1 - crcCompass.Stroke.Thickness * 0.5 / Radius);

    crcDot.Position.X := ((crcCompass.Width / 2) - crcDot.Width / 2) + Radius * sin(Direction);
    crcDot.Position.Y := ((crcCompass.Height / 2) - crcDot.Height / 2) - Radius * cos(Direction);

    if Positions[0].Position.DirectionValid then begin
        crcDot.Fill.Color := TAlphaColorRec.Lime;
    end else begin
        crcDot.Fill.Color := TAlphaColorRec.Red;
    end;

    // Altitude, or vertical distance to payload, as appropriate
    if not IsNan(Positions[0].Position.Altitude) then begin
        if Positions[SelectedIndex].Position.Altitude >= (Positions[0].Position.Altitude + 2000) then begin
            lblRelativeAltitude.Text := '';
        end else if Positions[SelectedIndex].Position.Altitude >= Positions[0].Position.Altitude then begin
            lblRelativeAltitude.Text := '+' + IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
        end else begin
            lblRelativeAltitude.Text := IntToStr(Round(Positions[SelectedIndex].Position.Altitude - Positions[0].Position.Altitude)) + 'm';
        end;
    end;

    if Positions[SelectedIndex].Position.FlightMode = fmDescending then begin
        Seconds := CalculateDescentTime(Positions[SelectedIndex].Position.Altitude, -Positions[SelectedIndex].Position.AscentRate, Positions[0].Position.Altitude);

        if Seconds >= 60 then begin
            lblTTL.Text := FormatFloat('0', Seconds / 60) + ' min';
        end else begin
            lblTTL.Text := FormatFloat('0', Seconds) + ' s';
        end;
    end else begin
        lblTTL.Text := '';
    end;

    lblElevation.Text := FormatFloat('0', Elevation) + ' °';
end;

function TfrmDirection.ProcessNewPosition(Index: Integer): Boolean;
begin
    if (SelectedIndex > 0) and (Index = SelectedIndex) then begin
        with Positions[SelectedIndex].Position do begin
            lblLatitude.Text := FormatFloat('0.00000', Latitude);
            lblLongitude.Text := FormatFloat('0.00000', Longitude);
            lblAltitude.Text := FormatFloat('0', Altitude) + 'm';
            lblAscentRate.Text := FormatFloat('0.0', AscentRate) + 'm/s';
        end;
    end;

    Result := inherited;
end;

end.
