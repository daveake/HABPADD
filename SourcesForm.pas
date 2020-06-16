unit SourcesForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Math, Habitat, Miscellaneous,
  GPSSource, Source, Base, CarUpload, GatewaySource, HabitatSource, UDPSource, SerialSource, BluetoothSource,
  System.DateUtils, System.TimeSpan, System.Sensors, System.Sensors.Components, BLESource,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient;

type
  TSourcePanel = record
      Source:       TSource;
      ValueLabel:   TLabel;
      RSSILabel:    TLabel;
      CurrentRSSI:  String;
      PacketRSSI:   String;
      FreqError:    String;
  end;

//type
//    TGPSPosition = record
//        Latitude, Longitude:  Double;
//        Score:  Integer;
//    end;

type
  TfrmSources = class(TfrmBase)
    LocationSensor: TLocationSensor;
    tmrGPS: TTimer;
    Rectangle1: TRectangle;
    lblGateway1: TLabel;
    Label2: TLabel;
    Rectangle2: TRectangle;
    lblGPS: TLabel;
    Label3: TLabel;
    Rectangle3: TRectangle;
    lblHabitat: TLabel;
    Label5: TLabel;
    Rectangle5: TRectangle;
    Label9: TLabel;
    Rectangle6: TRectangle;
    Label11: TLabel;
    Rectangle4: TRectangle;
    Label4: TLabel;
    Label7: TLabel;
    lblSerial: TLabel;
    lblUDP: TLabel;
    Label1: TLabel;
    lblBT: TLabel;
    lblBluetoothRSSI: TLabel;
    Rectangle7: TRectangle;
    lblGateway2: TLabel;
    Label8: TLabel;
    OrientationSensor1: TOrientationSensor;
    MotionSensor1: TMotionSensor;
    Label6: TLabel;
    lblDirection: TLabel;
    Label10: TLabel;
    lblGateway1RSSI: TLabel;
    Label12: TLabel;
    lblGateway2RSSI: TLabel;
    lblSerialRSSI: TLabel;
    UDPClient: TIdUDPClient;
    procedure FormCreate(Sender: TObject);
    procedure tmrGPSTimer(Sender: TObject);
    procedure OrientationSensor1SensorChoosing(Sender: TObject;
      const Sensors: TSensorArray; var ChoseSensorIndex: Integer);
    procedure pnlMainResized(Sender: TObject);
  private
    { Private declarations }
    CarUploader: TCarUpload;
    HabitatUploader: THabitatThread;
    Sources: Array[1..6] of TSourcePanel;
    CompassPresent: Boolean;
    MagneticHeading, Declination: Double;
//    GPSPositions: Array[1..5] of TGPSPosition;
//    GPSCount: Integer;
{$IFDEF MSWINDOWS}
    GPSSource: TGPSSource;
    procedure GPSCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
{$ENDIF}
    function GetMagneticHeading: Double;
    procedure HabitatStatusCallback(SourceID: Integer; Active, OK: Boolean);
    procedure CarStatusCallback(SourceID: Integer; Active, OK: Boolean);
    procedure NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
    procedure HABCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
//    function SavePosition(Latitude, Longitude: Double): TGPSPosition;
  public
    { Public declarations }
    procedure UpdatePayloadList(PayloadList: String);
    procedure SendParameterToSource(SourceIndex: Integer; ValueName, Value: String);
    procedure EnableGPS;
    procedure EnableCompass;
end;

var
  frmSources: TfrmSources;

implementation

uses Main, Debug;

{$R *.fmx}

procedure TfrmSources.EnableGPS;
begin
    if not LocationSensor.Active then begin
        LocationSensor.Active := True;
        tmrGPS.Enabled := True;
    end;
end;

procedure TfrmSources.FormCreate(Sender: TObject);
begin
    inherited;

    // Car uploader
    CarUploader := TCarUpload.Create(CarStatusCallback);

    // Habitat uploader
    HabitatUploader := THabitatThread.Create(HabitatStatusCallback);

    // GPS Source
{$IFDEF MSWINDOWS}
    GPSSource := TGPSSource.Create(GPS_SOURCE, 'GPS', GPSCallback);
{$ELSE}
    if not LocationSensor.Active then begin
        LocationSensor.Active := True;
        tmrGPS.Enabled := True;
    end;
{$ENDIF}

    // Radio sources
    Sources[GATEWAY_SOURCE_1].ValueLabel := lblGateway1;
    Sources[GATEWAY_SOURCE_1].Source := TGatewaySource.Create(GATEWAY_SOURCE_1, 'LoRaGateway1', HABCallback);
    Sources[GATEWAY_SOURCE_1].RSSILabel := lblGateway1RSSI;

    Sources[GATEWAY_SOURCE_2].ValueLabel := lblGateway2;
    Sources[GATEWAY_SOURCE_2].Source := TGatewaySource.Create(GATEWAY_SOURCE_2, 'LoRaGateway2', HABCallback);
    Sources[GATEWAY_SOURCE_2].RSSILabel := lblGateway2RSSI;

    // USB / Serial source
    Sources[SERIAL_SOURCE].ValueLabel := lblSerial;
    Sources[SERIAL_SOURCE].RSSILabel := lblSerialRSSI;
    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        Sources[SERIAL_SOURCE].Source := TSerialSource.Create(SERIAL_SOURCE, 'LoRaSerial', HABCallback);
    {$ELSE}
        Label1.Text := '';
        lblSerial.Text := '';
    {$ENDIF}

    // Bluetooth source
    Sources[BLUETOOTH_SOURCE].ValueLabel := lblBT;
    Sources[BLUETOOTH_SOURCE].RSSILabel := lblBluetoothRSSI;
    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        Sources[BLUETOOTH_SOURCE].Source := TBluetoothSource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
    {$ELSE}
        Sources[BLUETOOTH_SOURCE].Source := TBLESource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
        Label9.Text := 'BLE';
    {$ENDIF}

    Sources[UDP_SOURCE].ValueLabel := lblUDP;
    Sources[UDP_SOURCE].Source := TUDPSource.Create(UDP_SOURCE, 'UDP', HABCallback);
    Sources[UDP_SOURCE].RSSILabel := nil;

    Sources[HABITAT_SOURCE].ValueLabel := lblHabitat;
    Sources[HABITAT_SOURCE].Source := THabitatSource.Create(HABITAT_SOURCE, 'Habitat', HABCallback);
    Sources[HABITAT_SOURCE].RSSILabel := nil;
end;

{$IFDEF MSWINDOWS}
procedure TfrmSources.GPSCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
begin
    if Position.InUse and not Application.Terminated then begin
        NewGPSPosition(Position.TimeStamp, Position.Latitude, Position.Longitude, Position.Altitude, Position.Direction, False);
    end;
end;
{$ENDIF}

procedure TfrmSources.NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
var
    Position: THABPosition;
    Temp: String;
    CarPosition: TCarPosition;
//    GPSPosition: TGPSPosition;
begin
    if IsNan(Latitude) then begin
        Temp := 'Waiting for GPS ...';
        frmMain.lblGPS.Text := Temp;
        lblGPS.Text := Temp;
    end else begin
//        GPSPosition := SavePosition(Latitude, Longitude);

        FillChar(Position, SizeOf(Position), 0);

        Temp := Format('%f', [Altitude]);
        if IsNan(Altitude) then begin
            Temp := FormatDateTime('hh:nn:ss', Timestamp) + '  ' +
                                   Format('%2.6f', [Latitude]) + ',' +
                                   Format('%2.6f', [Longitude]);
            frmMain.lblGPS.Text := Temp;
        end else begin
            Temp := FormatDateTime('hh:nn:ss', Timestamp) + '  ' +
                                   Format('%2.6f', [Latitude]) + ',' +
                                   Format('%2.6f', [Longitude]) + ', ' +
                                   Format('%.0f', [Altitude]) + 'm ';
            frmMain.lblGPS.Text := Temp;
        end;

        lblGPS.Text := Temp;

        // if Position.TimeStamp <> Timestamp then begin
            Position.ReceivedAt := Now;
        // end;

        Position.TimeStamp := Timestamp;
        Position.Latitude := Latitude;
        Position.Longitude := Longitude;
//        Position.Latitude := GPSPosition.Latitude;
//        Position.Longitude := GPSPosition.Longitude;
        if not IsNan(Altitude) then begin
            Position.Altitude := Altitude;
        end;

        if IsNan(Direction) then begin
            Position.DirectionValid := False;
        end else begin
            Position.DirectionValid := True;
            if UsingCompass then begin
                lblDirection.Text := 'Compass Direction = ' + FormatFloat('0.0', Direction);
            end else begin
                lblDirection.Text := 'GPS Direction = ' + FormatFloat('0.0', Direction);
            end;
            Position.Direction := Direction;
        end;

        Position.InUse := True;
        Position.IsChase := True;
        Position.PayloadID := 'Chase';

        frmMain.NewPosition(0, Position);

        if CarUploader <> nil then begin
            CarPosition.InUse := True;
            CarPosition.TimeStamp := TTimeZone.Local.ToUniversalTime(Now);
            CarPosition.Latitude := Position.Latitude;
            CarPosition.Longitude := Position.Longitude;
            CarPosition.Altitude := Position.Altitude;

            CarUploader.SetPosition(CarPosition);
        end;
    end;
end;

procedure TfrmSources.OrientationSensor1SensorChoosing(Sender: TObject;
  const Sensors: TSensorArray; var ChoseSensorIndex: Integer);
var
    i: Integer;
    Found: Integer;
begin
    Found := -1;
    for i := 0 to High(Sensors) do begin
        if (TCustomOrientationSensor.TProperty.HeadingX in TCustomOrientationSensor(Sensors[I]).AvailableProperties) then begin
            Found := i;
            Break;
        end;
    end;

    if Found >= 0 then begin
        ChoseSensorIndex := Found;
        CompassPresent := True;
    end;
end;

procedure TfrmSources.pnlMainResized(Sender: TObject);
begin
  inherited;

end;

// this function x,y,z axis for the phone in vertical orientation (portrait)
function calcTiltCompensatedMagneticHeading(const {acel}aGx,aGy,aGz,{mag} aMx,aMy,aMz:double ):double; //return heading in degrees
var Phi,Theta,cosPhi,sinPhi,Gz2,By2,Bz2,Bx3:Double;
begin
  Result := NaN;   //=invalid
  // https://www.st.com/content/ccc/resource/technical/document/design_tip/group0/56/9a/e4/04/4b/6c/44/ef/DM00269987/files/DM00269987.pdf/jcr:content/translations/en.DM00269987.pdf
  Phi := ArcTan2(aGy,aGz);    //calc Roll (Phi)
  cosPhi := Cos(Phi);         //memoise phi trigs
  sinPhi := Sin(Phi);

  Gz2 := aGy*sinPhi+aGz*cosPhi;
  if (Gz2<>0) then
    begin
      Theta := Arctan(-aGx/Gz2);                 // Theta = Pitch
      By2 := aMz * sinPhi - aMy * cosPhi;
      Bz2 := aMy * sinPhi + aMz * cosPhi;
      Bx3 := aMx * Cos(Theta) + Bz2 * Sin(Theta);
      Result := ArcTan2(By2,Bx3)*180/Pi-90;      //convert to degrees and then add   90 for North based heading  (Psi)
    end;
end;

function TfrmSources.GetMagneticHeading: Double;
var
    mx, my, mz, aGx, aGy, aGz: Double;
begin
    mx := OrientationSensor1.Sensor.HeadingX;  //in mTeslas
    my := OrientationSensor1.Sensor.HeadingY;
    mz := OrientationSensor1.Sensor.HeadingZ;

    aGx := MotionSensor1.Sensor.AccelerationX;  //get acceleration sensor
    aGy := MotionSensor1.Sensor.AccelerationY;
    aGz := MotionSensor1.Sensor.AccelerationZ;

//    if IsLandscapeMode then  //landscape phone orientation
//    begin
    Result := calcTiltCompensatedMagneticHeading({acel}aGy,-aGx,aGz,{mag} my,-mx,mz); //rotated 90 in z axis
//    end
//    else begin  //portrait orientation
//    Result := calcTiltCompensatedMagneticHeading({acel}aGx,aGy,aGz,{mag} mx,my,mz);  // normal portrait orientation
end;

procedure TfrmSources.tmrGPSTimer(Sender: TObject);
var
    UTC: TDateTime;
begin
    // Compass
    if CompassPresent then begin
        MagneticHeading := GetMagneticHeading;
    end;

    // GPS
    if LocationSensor.Accuracy < 50 then begin
        UTC := TTimeZone.Local.ToUniversalTime(Now);

        if CompassPresent then begin
            NewGPSPosition(UTC, LocationSensor.Sensor.Latitude, LocationSensor.Sensor.Longitude, LocationSensor.Sensor.Altitude, MagneticHeading - Declination, True);
        end else begin
            NewGPSPosition(UTC, LocationSensor.Sensor.Latitude, LocationSensor.Sensor.Longitude, LocationSensor.Sensor.Altitude, LocationSensor.Sensor.TrueHeading, False);
        end;
    end;
end;

procedure TfrmSources.CarStatusCallback(SourceID: Integer; Active, OK: Boolean);
begin
    frmMain.UploadStatus(SourceID, Active, OK);
end;

procedure TfrmSources.HabitatStatusCallback(SourceID: Integer; Active, OK: Boolean);
begin
    frmMain.UploadStatus(SourceID, Active, OK);
end;

procedure TfrmSources.HABCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
var
    Temp, Callsign: String;
    Port: Integer;
begin
    // New Position
    if Position.InUse then begin
        frmMain.NewPosition(ID, Position);

        if ID = SERIAL_SOURCE then begin
            if GetSettingBoolean('LoRaSerial', 'Habitat', False) then begin
                Callsign := GetSettingString('General', 'Callsign', '');
                if Callsign <> '' then begin
                    HabitatUploader.SaveTelemetryToHabitat(ID, Position.Line, Callsign);
                end;
            end;
        end else if ID = BLUETOOTH_SOURCE then begin
            if GetSettingBoolean('LoRaBluetooth', 'Habitat', False) then begin
                Callsign := GetSettingString('General', 'Callsign', '');
                if Callsign <> '' then begin
                    HabitatUploader.SaveTelemetryToHabitat(ID, Position.Line, Callsign);
                end;
            end;
        end;

        if ID in [SERIAL_SOURCE, BLUETOOTH_SOURCE] then begin
            Port := GetSettingInteger('General', 'UDPTxPort', 0);
            if Port > 0 then begin
                UDPClient.Broadcast(Position.Line, Port);
            end;
        end;

        Sources[ID].ValueLabel.Text := Copy(Position.Line, 1, 100);
    end else if Line <> '' then begin
        Sources[ID].ValueLabel.Text := Line;
    end;

    // SSDV Packet
    if Position.IsSSDV then begin
        if GetSettingBoolean('LoRaSerial', 'SSDV', False) then begin
            Callsign := GetSettingString('LoRaSerial', 'Callsign', '');
            if Callsign <> '' then begin
                HabitatUploader.SaveSSDVToHabitat(Position.Line, Callsign);
            end;
        end;
    end;

    if Position.HasCurrentRSSI then begin
        Sources[ID].CurrentRSSI := 'Current RSSI ' + IntToStr(Position.CurrentRSSI)
    end;

    if Position.HasPacketRSSI then begin
        Sources[ID].PacketRSSI := ', Packet RSSI ' + IntToStr(Position.PacketRSSI);
    end;

    if Position.HasFrequency then begin
        Sources[ID].FreqError := ', Frequency Offset = ' + FormatFloat('0', Position.FrequencyError*1000) + ' Hz';
    end;

    if Sources[ID].RSSILabel <> nil then begin
        Temp := Sources[ID].CurrentRSSI + Sources[ID].PacketRSSI + Sources[ID].FreqError;
        if (Temp <> '') and (ID in [GATEWAY_SOURCE_1, GATEWAY_SOURCE_2]) then begin
            Sources[ID].RSSILabel.Text := 'Ch' + IntToStr(Position.Channel) + ': ' + Temp;
        end else begin
            Sources[ID].RSSILabel.Text := Temp;
        end;
    end;
end;

procedure TfrmSources.UpdatePayloadList(PayloadList: String);
begin
    if Sources[HABITAT_SOURCE].Source <> nil then begin
        THabitatSource(Sources[HABITAT_SOURCE].Source).PayloadList := PayloadList;
    end;
end;

procedure TfrmSources.SendParameterToSource(SourceIndex: Integer; ValueName, Value: String);
begin
    Sources[SourceIndex].Source.SendSetting(ValueName, Value);
end;

procedure TfrmSources.EnableCompass;
begin
    OrientationSensor1.Active := True;
    MotionSensor1.Active := True;
end;

(*
function TfrmSources.SavePosition(Latitude, Longitude: Double): TGPSPosition;
var
    i, j, Best: Integer;
    Distance: Double;
begin
    if GPSCount = 0 then begin
        GPSCount := High(GPSPositions);
        for i := 1 to GPSCount do begin
            GPSPositions[i].Latitude := Latitude;
            GPSPositions[i].Longitude := Longitude;
        end;
    end;

    for i := 1 to GPSCount-1 do begin
        GPSPositions[i] := GPSPositions[i+1];
    end;

    GPSPositions[GPSCount].Latitude := Latitude;
    GPSPositions[GPSCount].Longitude := Longitude;

    // Use or reject latest value

    for i := 1 to GPSCount do begin
        GPSPositions[i].Score := 0;
        for j := 1 to GPSCount do begin
            if j <> i then begin
                Distance := CalculateDistance(GPSPositions[i].Latitude, GPSPositions[i].Longitude, GPSPositions[j].Latitude, GPSPositions[j].Longitude);
                if Distance < (100 * abs(i-j)) then begin
                    Inc(GPSPositions[i].Score);
                end;
            end;
        end;
    end;

    if GPSPositions[GPSCount].Score >= 3 then begin
        Result := GPSPositions[GPSCount];
    end else begin
        Best := 1;
        for i := 2 to GPSCount do begin
            if GPSPositions[i].Score >= GPSPositions[Best].Score then begin
                Best := i;
            end;
        end;
        Result := GPSPositions[Best];
    end;
end;
*)

end.
