unit SourcesForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Math, SSDV, Miscellaneous,
  GPSSource, Source, Base, GatewaySource, UDPSource, SerialSource, BluetoothSource,
  System.DateUtils, System.TimeSpan, System.Sensors, System.Sensors.Components, BLESource,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, MQTTUplink, Sondehub, MQTTSource,
  WSMQTTSource, SourceForm, Uploaders;

type
  TSourcePanel = record
      Source:       TSource;
      Form:         TfrmSource;
      CurrentFreq:  String;
      CurrentRSSI:  String;
      PacketRSSI:   String;
      FreqError:    String;
      PacketCount:  Integer;
      FrequencyError:   Double;
      HadAPosition:     Boolean;
      PacketStatus:     String;
      Version:          String;
      ConnectInfo:      String;
      Device:           String;
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
    rectGW1: TRectangle;
    rectGPS: TRectangle;
    rectSH: TRectangle;
    rectBT: TRectangle;
    rectUSB: TRectangle;
    rectUDP: TRectangle;
    rectGW2: TRectangle;
    OrientationSensor1: TOrientationSensor;
    MotionSensor1: TMotionSensor;
    UDPClient: TIdUDPClient;
    rectHL: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure tmrGPSTimer(Sender: TObject);
    procedure OrientationSensor1SensorChoosing(Sender: TObject;
      const Sensors: TSensorArray; var ChoseSensorIndex: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
    SondehubUploader: TSondehubThread;
    MQTTUploader, HabLinkUploader: TMQTTThread;
    SSDVUploader: TSSDVThread;
    Sources: Array[0..8] of TSourcePanel;
    CompassPresent: Boolean;
    MagneticHeading, Declination: Double;
//    GPSPositions: Array[1..5] of TGPSPosition;
//    GPSCount: Integer;
{$IFDEF MSWINDOWS}
    GPSSource: TGPSSource;
    procedure GPSCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
{$ENDIF}
    function GetMagneticHeading: Double;

    // Callbacks
    procedure HabLinkStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
    procedure MQTTStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
    procedure SSDVStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
    procedure SondehubStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);

    procedure NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
    procedure HABCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
//    function SavePosition(Latitude, Longitude: Double): TGPSPosition;
    procedure CloseThread(Thread: TThread);
    procedure WaitForThread(Thread: TThread);
  public
    { Public declarations }
    procedure UpdatePayloadList(PayloadList: String);
    procedure SendParameterToSource(SourceIndex: Integer; ValueName, Value: String);
    procedure EnableGPS;
    procedure EnableCompass;
    function GetPacketCount(SourceIndex: Integer): Integer;
    procedure ResetPacketCount(SourceIndex: Integer);
    function FrequencyError(SourceIndex: Integer): Double;
    procedure SendUplink(SourceIndex: Integer; When: TUplinkWhen; WhenValue, Channel: Integer; Prefix, Msg, Password: String);
    function WaitingToSend(SourceIndex: Integer): Boolean;
    procedure UpdateCarUploadSettings;
    procedure UpdateMQTTUploads;
    procedure SetGPSStatus(Status: String);
end;

var
  frmSources: TfrmSources;

implementation

uses Main, Debug, Settings, Misc;

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

    // Sondehub uploader
    SondehubUploader := TSondehubThread.Create(SondehubStatusCallback);
    UpdateCarUploadSettings;

    // SSDV Uploader
    SSDVUploader := TSSDVThread.Create(SSDVStatusCallback);

    // MQTT Uploader
    MQTTUploader := TMQTTThread.Create(MQTTStatusCallback);

    // HabLink uploader
    HabLinkUploader := TMQTTThread.Create(HablinkStatusCallback);

    UpdateMQTTUploads;

    // GPS Source
    Sources[GPS_SOURCE].Form := TfrmSource.Create(Self);
    Sources[GPS_SOURCE].Form.pnlMain.Parent := rectGPS;
    Sources[GPS_SOURCE].Form.lblInfo.Visible := True;
    Sources[GPS_SOURCE].Form.lblCaption.Text := 'GPS';
    Sources[GPS_SOURCE].Form.frmSourceLog.lblCaption.Text := 'GPS Log';
{$IFDEF MSWINDOWS}
    GPSSource := TGPSSource.Create(GPS_SOURCE, 'GPS', GPSCallback);
{$ELSE}
    if not LocationSensor.Active then begin
        LocationSensor.Active := True;
        tmrGPS.Enabled := True;
    end;
{$ENDIF}

    // Radio sources
    Sources[GATEWAY_SOURCE_1].Source := TGatewaySource.Create(GATEWAY_SOURCE_1, 'LoRaGateway1', HABCallback);
    Sources[GATEWAY_SOURCE_1].Form := TfrmSource.Create(Self);
    Sources[GATEWAY_SOURCE_1].Form.pnlMain.Parent := rectGW1;
    Sources[GATEWAY_SOURCE_1].Form.lblInfo.Visible := True;
    Sources[GATEWAY_SOURCE_1].Form.lblCaption.Text := 'GW1';
    Sources[GATEWAY_SOURCE_1].Form.frmSourceLog.lblCaption.Text := 'Gateway 1 Telemetry Log';

    Sources[GATEWAY_SOURCE_2].Source := TGatewaySource.Create(GATEWAY_SOURCE_2, 'LoRaGateway2', HABCallback);
    Sources[GATEWAY_SOURCE_2].Form := TfrmSource.Create(Self);
    Sources[GATEWAY_SOURCE_2].Form.pnlMain.Parent := rectGW2;
    Sources[GATEWAY_SOURCE_2].Form.lblInfo.Visible := True;
    Sources[GATEWAY_SOURCE_2].Form.lblCaption.Text := 'GW2';
    Sources[GATEWAY_SOURCE_2].Form.frmSourceLog.lblCaption.Text := 'Gateway 2 Telemetry Log';

    // USB / Serial source
    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        Sources[SERIAL_SOURCE].Source := TSerialSource.Create(SERIAL_SOURCE, 'LoRaSerial', HABCallback);
        Sources[SERIAL_SOURCE].Form := TfrmSource.Create(Self);
        Sources[SERIAL_SOURCE].Form.pnlMain.Parent := rectUSB;
        Sources[SERIAL_SOURCE].Form.lblInfo.Visible := True;
        Sources[SERIAL_SOURCE].Form.lblCaption.Text := 'USB';
        Sources[SERIAL_SOURCE].Form.frmSourceLog.lblCaption.Text := 'LoRa USB Telemetry Log';
    {$ENDIF}

    // Bluetooth source
    Sources[BLUETOOTH_SOURCE].Form := TfrmSource.Create(Self);
    Sources[BLUETOOTH_SOURCE].Form.pnlMain.Parent := rectBT;
    Sources[BLUETOOTH_SOURCE].Form.lblInfo.Visible := True;
    Sources[BLUETOOTH_SOURCE].Form.frmSourceLog.lblCaption.Text := 'LoRa Bluetooth Telemetry Log';
    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        Sources[BLUETOOTH_SOURCE].Source := TBluetoothSource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
        Sources[BLUETOOTH_SOURCE].Form.lblCaption.Text := 'BT';
    {$ELSE}
        Sources[BLUETOOTH_SOURCE].Source := TBLESource.Create(BLUETOOTH_SOURCE, 'LoRaBluetooth', HABCallback);
        Sources[BLUETOOTH_SOURCE].Form.lblCaption.Text := 'BLE';
    {$ENDIF}

    Sources[UDP_SOURCE].Source := TUDPSource.Create(UDP_SOURCE, 'UDP', HABCallback);
    Sources[UDP_SOURCE].Form := TfrmSource.Create(Self);
    Sources[UDP_SOURCE].Form.pnlMain.Parent := rectUDP;
    Sources[UDP_SOURCE].Form.lblInfo.Visible := False;
    Sources[UDP_SOURCE].Form.lblCaption.Text := 'UDP';
    Sources[UDP_SOURCE].Form.frmSourceLog.lblCaption.Text := 'UDP Telemetry Log';

    SetSettingString('Sondehub', 'Host', 'ws-reader.v2.sondehub.org');
    SetSettingString('Sondehub', 'Port', '443');
    SetSettingString('Sondehub', 'Topic', 'amateur/');
    SetSettingString('Sondehub', 'ExtraPayloads', '');
    SetSettingBoolean('Sondehub', 'Filtered', True);
    Sources[SONDEHUB_SOURCE].Source := TWSMQTTSource.Create(SONDEHUB_SOURCE, 'Sondehub', HABCallback);
    Sources[SONDEHUB_SOURCE].Form := TfrmSource.Create(Self);
    Sources[SONDEHUB_SOURCE].Form.pnlMain.Parent := rectSH;
    Sources[SONDEHUB_SOURCE].Form.lblInfo.Visible := False;
    Sources[SONDEHUB_SOURCE].Form.lblCaption.Text := 'SH';
    Sources[SONDEHUB_SOURCE].Form.frmSourceLog.lblCaption.Text := 'Sondehub Telemetry Log';

    SetSettingString('HabLink', 'Host', 'hab.link');
    SetSettingString('HabLink', 'Port', '1883');
    SetSettingString('HabLink', 'Topic', 'incoming/payloads/');
    SetSettingString('HabLink', 'ExtraPayloads', '');
    SetSettingBoolean('HabLink', 'Filtered', True);
    Sources[HABLINK_SOURCE].Source := TMQTTSource.Create(HABLINK_SOURCE, 'HabLink', HABCallback);
    Sources[HABLINK_SOURCE].Form := TfrmSource.Create(Self);
    Sources[HABLINK_SOURCE].Form.pnlMain.Parent := rectHL;
    Sources[HABLINK_SOURCE].Form.lblInfo.Visible := False;
    Sources[HABLINK_SOURCE].Form.lblCaption.Text := 'HL';
    Sources[HABLINK_SOURCE].Form.frmSourceLog.lblCaption.Text := 'HABLink Telemetry Log';
end;

procedure TfrmSources.CloseThread(Thread: TThread);
begin
    if Thread <> nil then begin
        Thread.Terminate;
    end;
end;


procedure TfrmSources.WaitForThread(Thread: TThread);
begin
    if Thread <> nil then begin
        Thread.WaitFor;
    end;
end;
procedure TfrmSources.FormDestroy(Sender: TObject);
var
    Index: Integer;
begin
    // Close and wait for threads

    for Index := Low(Sources) to High(Sources) do begin
        CloseThread(Sources[Index].Source);
    end;

    CloseThread(MQTTUploader);
    CloseThread(HabLinkUploader);
    CloseThread(SSDVUploader);
    CloseThread(SondehubUploader);

{$IFDEF MSWINDOWS}
    CloseThread(GPSSource);
    WaitForThread(GPSSource);
{$ENDIF}

    WaitForThread(MQTTUploader);
    WaitForThread(HabLinkUploader);
    WaitForThread(SSDVUploader);
    WaitForThread(SondehubUploader);

    for Index := Low(Sources) to High(Sources) do begin
        WaitForThread(Sources[Index].Source);
    end;

    MQTTUploader.Free;
    HabLinkUploader.Free;
    SSDVUploader.Free;
    SondehubUploader.Free;

{$IFDEF MSWINDOWS}
    GPSSource.Free;
{$ENDIF}

    for Index := Low(Sources) to High(Sources) do begin
        if Sources[Index].Source <> nil then Sources[Index].Source.Free;
    end;

    Caption := '';
end;

{$IFDEF MSWINDOWS}
procedure TfrmSources.GPSCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
begin
    if not Application.Terminated then begin
        if Position.InUse then begin
            NewGPSPosition(Position.TimeStamp, Position.Latitude, Position.Longitude, Position.Altitude, Position.Direction, False);
        end else if Line <> '' then begin
            Sources[GPS_SOURCE].Form.lblValue.Text := Line;
        end;
    end;
end;
{$ENDIF}

procedure TfrmSources.NewGPSPosition(Timestamp: TDateTime; Latitude, Longitude, Altitude, Direction: Double; UsingCompass: Boolean);
const
    LastHABLinkUpload: TDateTime = 0;
    LastMQTTLinkUpload: TDateTime = 0;
var
    Position: THABPosition;
    ChaseCallsign, Temp: String;
begin
    if IsNan(Latitude) then begin
        Temp := 'Waiting for GPS ...';
        frmMain.lblGPS.Text := Temp;
        Sources[GPS_SOURCE].Form.lblValue.Text := Temp;
    end else begin
        Position := default(THABPosition);

        Temp := Format('%f', [Altitude]);
        if IsNan(Altitude) then begin
            Temp := FormatDateTime('hh:nn:ss', Timestamp) + '  ' +
                                   Format('%2.5f', [Latitude]) + ',' +
                                   Format('%2.5f', [Longitude]);
            frmMain.lblGPS.Text := Temp;
            Altitude := 0;
        end else begin
            Temp := FormatDateTime('hh:nn:ss', Timestamp) + '  ' +
                                   Format('%2.5f', [Latitude]) + ',' +
                                   Format('%2.5f', [Longitude]) + ', ' +
                                   Format('%.0f', [Altitude]) + 'm ';
            frmMain.lblGPS.Text := Temp;
        end;

        Sources[GPS_SOURCE].Form.lblValue.Text := Temp;
        Sources[GPS_SOURCE].Form.WriteToLog(Temp);

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
                Sources[GPS_SOURCE].Form.lblInfo.Text := 'Compass Direction = ' + MyFormatFloat('0.0', Direction);
            end else begin
                Sources[GPS_SOURCE].Form.lblInfo.Text := 'GPS Direction = ' + MyFormatFloat('0.0', Direction);
            end;
            Position.Direction := Direction;
            Position.UsingCompass := UsingCompass;
        end;

        Position.InUse := True;
        Position.IsChase := True;
        Position.PayloadID := 'Chase';

        frmMain.NewPosition(0, Position);

        // Upload chase position
        if GetSettingBoolean('CHASE', 'Upload', False) then begin
            // Send chase position to Sondehub
            if SondehubUploader <> nil then begin
                SondehubUploader.SetListenerPosition(Position.Latitude, Position.Longitude, Position.Altitude);
            end;

            ChaseCallsign := GetSettingString('CHASE', 'Callsign', '');

            if ChaseCallsign <> '' then begin
                if GetSettingBoolean('Upload', 'MQTT', False) and (MQTTUploader <> nil) then begin
                    if Now >= (LastMQTTLinkUpload + GetSettingInteger('CHASE', 'Period', 30) / 86400) then begin
                        MQTTUploader.SendChase(ChaseCallsign,
                                               '{"time":"' + FormatDateTime('hh:nn:ss', TimeStamp) + '",' +
                                               '"lat":' + Format('%2.5f', [Latitude]) + ',' +
                                               '"lon":' + Format('%2.5f', [Longitude]) + ',' +
                                               '"alt":' + Format('%.0f', [Altitude]) + '}');

                        LastMQTTLinkUpload := Now;
                    end;
                end;

                if GetSettingBoolean('Upload', 'HABLINK', False) and (HablinkUploader <> nil) then begin
                    if Now >= (LastHABLinkUpload + 5/ 86400) then begin
                        HablinkUploader.SendChase(ChaseCallsign,
                                                   '{"time":"' + FormatDateTime('hh:nn:ss', TimeStamp) + '",' +
                                                   '"lat":' + Format('%2.5f', [Latitude]) + ',' +
                                                   '"lon":' + Format('%2.5f', [Longitude]) + ',' +
                                                   '"alt":' + Format('%.0f', [Altitude]) + '}');

                        LastHABLinkUpload := Now;
                    end;
                end;
            end;
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

procedure TfrmSources.SondehubStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, SONDEHUB_UPLINK, Active, OK);
    frmUploaders.WriteSondehubStatus(Status);
end;

procedure TfrmSources.HABCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
var
    Temp, Callsign, Topic: String;
    Port: Integer;
    OK: Boolean;
begin
    frmMain.NewPosition(ID, Position);

    // New position
    try
        if Position.InUse then begin
            Inc(Sources[ID].PacketCount);

            // Upload enabled for this source ?
            case ID of
                SERIAL_SOURCE:  OK := GetSettingBoolean('LoRaSerial', 'Upload', False);
                BLUETOOTH_SOURCE:  OK := GetSettingBoolean('LoRaBluetooth', 'Upload', False);
                else OK := False;
            end;

            if OK then begin
                Callsign := GetSettingString('General', 'Callsign', '');

                // Callsign needed for HABHUB, Sondehub and MQTT
                if Callsign <> '' then begin
                    if GetSettingBoolean('Upload', 'Sondehub', False) and (SondehubUploader <> nil) then begin
                        SondehubUploader.SaveTelemetryToSondehub(ID, Position);
                    end;
                end;

                if GetSettingBoolean('Upload', 'MQTT', False) and (MQTTUploader <> nil) then begin
                    MQTTUploader.SendTelemetry(Position.PayloadID, Callsign, Position.Line);
                end;

                if GetSettingBoolean('Upload', 'HABLINK', False) and (HablinkUploader <> nil) then begin
                    HablinkUploader.SendTelemetry(Position.PayloadID, Callsign, Position.Line);
                end;
            end;

            if ID in [SERIAL_SOURCE, BLUETOOTH_SOURCE] then begin
                Port := GetSettingInteger('General', 'UDPTxPort', 0);
                if Port > 0 then begin
                    UDPClient.Broadcast(Position.Line, Port);
                end;
            end;

            Sources[ID].Form.lblValue.Text := Position.Line;


            if Length(Position.Line) > 40 then begin
                Sources[ID].HadAPosition := True;
                Sources[ID].PacketStatus := 'Telemetry Packet';
                Sources[ID].Form.WriteToLog('Telemetry: ' + Position.Line);
            end else begin
//                Sources[ID].Form.lblValue.Text := Position.Line;
                Sources[ID].Form.WriteToLog(Position.Line);
            end;
        end else if Position.IsSSDV then begin
            Sources[ID].PacketStatus := 'SSDV Packet';
            Sources[ID].Form.WriteToLog('Received SSDV Packet');
        end else if Position.FailedCRC then begin
            Sources[ID].PacketStatus := 'CRC Error';
            Sources[ID].Form.WriteToLog('CRC Error');
        end else if Line <> '' then begin
            Sources[ID].Form.lblValue.Text := Line;
            Sources[ID].ConnectInfo := Line;
            Sources[ID].Form.WriteToLog(Line);
        end;

        // SSDV Packet
        if Position.IsSSDV then begin
            if GetSettingBoolean('Upload', 'SSDV', False) then begin
                Callsign := GetSettingString('General', 'Callsign', '');
                if Callsign <> '' then begin
                    if ID = SERIAL_SOURCE then begin
                        if GetSettingBoolean('LoRaSerial', 'SSDV', False) then begin
                            SSDVUploader.SaveSSDVToHabitat(Position.Line, Callsign);
                        end;
                    end else if ID = BLUETOOTH_SOURCE then begin
                        if GetSettingBoolean('LoRaBluetooth', 'SSDV', False) then begin
                            SSDVUploader.SaveSSDVToHabitat( Position.Line, Callsign);
                        end;
                    end;
                end;
            end;
        end;

        if Position.CurrentFrequency > 0 then begin
            Sources[ID].CurrentFreq := 'Curr Freq ' + FormatFloat('0.000#', Position.CurrentFrequency) + ' MHz';
        end;

        if Position.HasCurrentRSSI then begin
            Sources[ID].CurrentRSSI := '  Curr RSSI ' + IntToStr(Position.CurrentRSSI)
        end;

        if Position.HasPacketRSSI then begin
            Sources[ID].PacketRSSI := '  Pkt RSSI ' + IntToStr(Position.PacketRSSI);
            Sources[ID].Form.WriteToLog('Packet RSSI = ' + IntToStr(Position.PacketRSSI));
        end;

        if Position.HasFrequency then begin
            Sources[ID].FrequencyError := Position.FrequencyError;
            Sources[ID].FreqError := '  Freq Err = ' + FormatFloat('0', Position.FrequencyError*1000) + ' Hz';

            // AFC
            if (Position.CurrentFrequency > 0) and (abs(Position.FrequencyError) > 1) then begin
                if ID = SERIAL_SOURCE then begin
                    if GetSettingBoolean('LoRaSerial', 'AFC', False) then begin
                        Sources[ID].Source.SendSetting('F', FormatFloat('0.0000', Position.CurrentFrequency + Position.FrequencyError / 1000));
                    end;
                end else if ID = BLUETOOTH_SOURCE then begin
                    if GetSettingBoolean('LoRaBluetooth', 'AFC', False) then begin
                        Sources[ID].Source.SendSetting('F', FormatFloat('0.0000', Position.CurrentFrequency + Position.FrequencyError / 1000));
                    end;
                end;
            end;
        end;

        Temp := Sources[ID].CurrentFreq + Sources[ID].CurrentRSSI + Sources[ID].PacketRSSI + Sources[ID].FreqError;

        if (Temp <> '') and (ID in [GATEWAY_SOURCE_1, GATEWAY_SOURCE_2]) then begin
            Sources[ID].Form.lblInfo.Text := 'Ch' + IntToStr(Position.Channel) + ': ' + Temp;
        end else begin
            Sources[ID].Form.lblInfo.Text := Temp;
        end;

        if Position.Device <> '' then begin
            Sources[ID].Device := Position.Device;
            Sources[ID].Form.WriteToLog('Device: ' + Position.Device);
        end;

        if Position.Version <> '' then begin
            Sources[ID].Version := 'V' + Position.Version;
            Sources[ID].Form.WriteToLog('Version: ' + Position.Version);
        end;

        if (Sources[ID].ConnectInfo <> '') and (not Sources[ID].HadAPosition) then begin
            if (Sources[ID].Device<> '') and (Sources[ID].Version <> '') then begin
                Sources[ID].Form.lblValue.Text := Sources[ID].ConnectInfo + ': ' + Sources[ID].Device + ' ' + Sources[ID].Version;
            end else begin
                Sources[ID].Form.lblValue.Text := Sources[ID].ConnectInfo;
            end;
        end;
    except
        Sources[ID].Form.lblValue.Text := '** ERROR - **';
    end;
end;

function RemoveDuplicatePayloads(PayloadList, WhiteList: String): String;
var
    Payload: String;
begin
    WhiteList := ',' + WhiteList + ',';

    Result := '';

    repeat
        Payload := GetString(PayloadList, ',');
        if Payload <> '' then begin
            if Pos(',' + Payload + ',', WhiteList) = 0 then begin
                if Result = '' then begin
                    Result := Payload;
                end else begin
                    Result := Payload + ',' + Payload;
                end;

            end;

        end;

    until PayloadList = '';
end;

procedure TfrmSources.UpdatePayloadList(PayloadList: String);
begin
    PayloadList := RemoveDuplicatePayloads(PayloadList, GetSettingString('Habitat', 'WhiteList', ''));

    SetSettingString('Sondehub', 'ExtraPayloads', PayloadList);
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

function TfrmSources.GetPacketCount(SourceIndex: Integer): Integer;
begin
    Result := Sources[SourceIndex].PacketCount;
end;

procedure TfrmSources.ResetPacketCount(SourceIndex: Integer);
begin
    Sources[SourceIndex].PacketCount := 0;
end;

function TfrmSources.FrequencyError(SourceIndex: Integer): Double;
begin
    Result := Sources[SourceIndex].FrequencyError;
end;

procedure TfrmSources.SendUplink(SourceIndex: Integer; When: TUplinkWhen; WhenValue, Channel: Integer; Prefix, Msg, Password: String);
begin
    Sources[SourceIndex].Source.SendUplink(When, WhenValue, Channel, Prefix, Msg, Password);
end;

function TfrmSources.WaitingToSend(SourceIndex: Integer): Boolean;
begin
    Result := Sources[SourceIndex].Source.WaitingToSend;
end;

procedure TfrmSources.SSDVStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, SSDV_UPLINK, Active, OK);
    frmUploaders.WriteSSDVStatus(Status);
end;

procedure TfrmSources.HabLinkStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, HABLINK_UPLINK, Active, OK);
    frmUploaders.WriteHABLinkStatus(Status);
end;

procedure TfrmSources.Label11Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(4);
end;

procedure TfrmSources.Label2Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(2);
end;

procedure TfrmSources.Label3Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(0);
end;

procedure TfrmSources.Label4Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(6);
end;

procedure TfrmSources.Label5Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(7);
end;

procedure TfrmSources.Label8Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(3);
end;

procedure TfrmSources.Label9Click(Sender: TObject);
begin
    frmMain.LoadSettingsPage(5);
end;

procedure TfrmSources.MQTTStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, MQTT_UPLINK, Active, OK);
    frmUploaders.WriteMQTTStatus(Status);
end;

procedure TfrmSources.UpdateCarUploadSettings;
begin
    SondehubUploader.SetListener(ApplicationName, ApplicationVersion,
                                 GetSettingString('CHASE', 'Callsign', 'UNKNOWN'),
                                 True,
                                 GetSettingInteger('CHASE', 'Period', 30),
                                 GetSettingBoolean('CHASE', 'Upload', False));
end;

procedure TfrmSources.UpdateMQTTUploads;
var
    Callsign, Topic, CarTopic: String;
begin
    Callsign := GetSettingString('General', 'Callsign', '');

    Topic := StringReplace(GetSettingString('Upload', 'MQTTTopic', ''), '$LISTENER$', Callsign, [rfReplaceAll, rfIgnoreCase]);

    CarTopic := GetSettingString('Upload', 'MQTTChaseTopic', '');

    if MQTTUploader <> nil then begin
        MQTTUploader.SetMQTTDetails(GetSettingString('Upload', 'MQTTBroker', ''),
                                    GetSettingString('Upload', 'MQTTUserName', ''),
                                    GetSettingString('Upload', 'MQTTPassword', ''),
                                    Topic, CarTopic);
    end;

    if HablinkUploader <> nil then begin
        HablinkUploader.SetMQTTDetails('hab.link', 'daffyduck', 'HAB2022', 'incoming/payloads/$PAYLOAD$/$LISTENER$/sentence', 'incoming/chase/$CALLSIGN$');
    end;
end;

procedure TfrmSources.SetGPSStatus(Status: String);
begin
    Sources[GPS_SOURCE].Form.lblValue.Text := Status;
end;


end.


