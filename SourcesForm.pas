unit SourcesForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, Habitat,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, HabitatSource,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Math, SSDV, Miscellaneous, CarUpload,
  GPSSource, Source, Base, GatewaySource, UDPSource, SerialSource, BluetoothSource,
  System.DateUtils, System.TimeSpan, System.Sensors, System.Sensors.Components, BLESource,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, MQTTUplink, Sondehub, MQTTSource,
  WSMQTTSource;

type
  TSourcePanel = record
      Source:       TSource;
      ValueLabel:   TLabel;
      RSSILabel:    TLabel;
      CurrentFreq:  String;
      CurrentRSSI:  String;
      PacketRSSI:   String;
      FreqError:    String;
      PacketCount:  Integer;
      FrequencyError:   Double;
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
    lblGateway1: TLabel;
    Label2: TLabel;
    rectGPS: TRectangle;
    lblGPS: TLabel;
    Label3: TLabel;
    rectSH: TRectangle;
    lblSondehub: TLabel;
    Label5: TLabel;
    rectBT: TRectangle;
    Label9: TLabel;
    rectUSB: TRectangle;
    Label11: TLabel;
    rectUDP: TRectangle;
    Label4: TLabel;
    Label7: TLabel;
    lblSerial: TLabel;
    lblUDP: TLabel;
    Label1: TLabel;
    lblBT: TLabel;
    lblBluetoothRSSI: TLabel;
    rectGW2: TRectangle;
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
    rectHH: TRectangle;
    lblHabitat: TLabel;
    Label14: TLabel;
    rectHL: TRectangle;
    lblHabLink: TLabel;
    Label16: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure tmrGPSTimer(Sender: TObject);
    procedure OrientationSensor1SensorChoosing(Sender: TObject;
      const Sensors: TSensorArray; var ChoseSensorIndex: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure rectGW1Resize(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
    CarUploader: TCarUpload;
    HabitatUploader: THabitatThread;
    SondehubUploader: TSondehubThread;
    MQTTUploader, HabLinkUploader: TMQTTThread;
    SSDVUploader: TSSDVThread;
    Sources: Array[1..8] of TSourcePanel;
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
    procedure HabitatStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
    procedure CarStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
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

    // Car uploader
    CarUploader := TCarUpload.Create(CarStatusCallback);

    // Habitat uploader
    HabitatUploader := THabitatThread.Create(HabitatStatusCallback);

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
    Sources[UDP_SOURCE].RSSILabel := nil;
    Sources[UDP_SOURCE].Source := TUDPSource.Create(UDP_SOURCE, 'UDP', HABCallback);

    Sources[SONDEHUB_SOURCE].ValueLabel := lblSondehub;
    Sources[SONDEHUB_SOURCE].RSSILabel := nil;
    SetSettingString('Sondehub', 'Host', 'ws-reader.v2.sondehub.org');
    SetSettingString('Sondehub', 'Port', '443');
    SetSettingString('Sondehub', 'Topic', 'amateur/');
    SetSettingString('Sondehub', 'ExtraPayloads', '');
    SetSettingBoolean('Sondehub', 'Filtered', True);
    Sources[SONDEHUB_SOURCE].Source := TWSMQTTSource.Create(SONDEHUB_SOURCE, 'Sondehub', HABCallback);

    Sources[HABLINK_SOURCE].ValueLabel := lblHabLink;
    Sources[HABLINK_SOURCE].RSSILabel := nil;
    SetSettingString('HabLink', 'Host', 'hab.link');
    SetSettingString('HabLink', 'Port', '1883');
    SetSettingString('HabLink', 'Topic', 'incoming/payloads/');
    SetSettingString('HabLink', 'ExtraPayloads', '');
    SetSettingBoolean('HabLink', 'Filtered', True);
    Sources[HABLINK_SOURCE].Source := TMQTTSource.Create(HABLINK_SOURCE, 'HabLink', HABCallback);

    Sources[HABHUB_SOURCE].ValueLabel := lblHabitat;
    Sources[HABHUB_SOURCE].Source := THabitatSource.Create(HABHUB_SOURCE, 'Habitat', HABCallback);
    Sources[HABHUB_SOURCE].RSSILabel := nil;
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

    CloseThread(CarUploader);
    CloseThread(HabitatUploader);
    CloseThread(MQTTUploader);
    CloseThread(HabLinkUploader);
    CloseThread(SSDVUploader);
    CloseThread(SondehubUploader);

{$IFDEF MSWINDOWS}
    CloseThread(GPSSource);
    WaitForThread(GPSSource);
{$ENDIF}

    WaitForThread(CarUploader);
    WaitForThread(HabitatUploader);
    WaitForThread(MQTTUploader);
    WaitForThread(HabLinkUploader);
    WaitForThread(SSDVUploader);
    WaitForThread(SondehubUploader);

    for Index := Low(Sources) to High(Sources) do begin
        WaitForThread(Sources[Index].Source);
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
            lblGPS.Text := Line;
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
    CarPosition: TCarPosition;
begin
    if IsNan(Latitude) then begin
        Temp := 'Waiting for GPS ...';
        frmMain.lblGPS.Text := Temp;
        lblGPS.Text := Temp;
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
                // HABHUB
                if GetSettingBoolean('Upload', 'Habitat', False) then begin
                    CarPosition.InUse := True;
                    CarPosition.TimeStamp := TTimeZone.Local.ToUniversalTime(Now);
                    CarPosition.Latitude := Position.Latitude;
                    CarPosition.Longitude := Position.Longitude;
                    CarPosition.Altitude := Position.Altitude;

                    CarUploader.SetPosition(CarPosition);
                end;

                if GetSettingBoolean('Upload', 'MQTT', False) then begin
                    if Now >= (LastMQTTLinkUpload + GetSettingInteger('CHASE', 'Period', 30) / 86400) then begin
                        MQTTUploader.SendChase(ChaseCallsign + '_Chase',
                                               FormatDateTime('hh:nn:ss', TimeStamp) + ',' +
                                               Format('%2.5f', [Latitude]) + ',' +
                                               Format('%2.5f', [Longitude]) + ', ' +
                                               Format('%.0f', [Altitude]));

                        LastMQTTLinkUpload := Now;
                    end;
                end;

                if GetSettingBoolean('Upload', 'HABLINK', False) then begin
                    if Now >= (LastHABLinkUpload + 5/ 86400) then begin
                        HablinkUploader.SendChase(ChaseCallsign + '_Chase',
                                                  FormatDateTime('hh:nn:ss', TimeStamp) + ',' +
                                                  Format('%2.5f', [Latitude]) + ',' +
                                                  Format('%2.5f', [Longitude]) + ', ' +
                                                  Format('%.0f', [Altitude]));

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

procedure TfrmSources.rectGW1Resize(Sender: TObject);
var
    i, FontSize: Integer;
begin
    FontSize := Round(lblSerialRSSI.Width / 64);

    for i := Low(Sources) to High(Sources) do begin
        if Sources[i].ValueLabel <> nil then begin
            Sources[i].ValueLabel.TextSettings.Font.Size := FontSize;
        end;
        if Sources[i].RSSILabel <> nil then begin
            Sources[i].RSSILabel.TextSettings.Font.Size := FontSize;
        end;
    end;

    lblGPS.TextSettings.Font.Size := FontSize;
    lblDirection.TextSettings.Font.Size := FontSize;
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
end;

procedure TfrmSources.HABCallback(ID: Integer; Connected: Boolean; Line: String; Position: THABPosition);
var
    Temp, Callsign, Topic: String;
    Port: Integer;
    OK: Boolean;
begin
    frmMain.NewPosition(ID, Position);

    // New Position
    if Position.InUse then begin
        Inc(Sources[ID].PacketCount);

//        frmMain.NewPosition(ID, Position);

        // Upload enabled for this source ?
        case ID of
            SERIAL_SOURCE:  OK := GetSettingBoolean('LoRaSerial', 'Upload', False);
            BLUETOOTH_SOURCE:  OK := GetSettingBoolean('LoRaBluetooth', 'Upload', False);
            else OK := False;
        end;

        if OK then begin
            Callsign := GetSettingString('General', 'Callsign', '');

            // Callsign needed for HABHUB and Sondehub
            if Callsign <> '' then begin
                if GetSettingBoolean('Upload', 'Habitat', False) then begin
                    HabitatUploader.SaveTelemetryToHabitat(ID, Position.Line, Callsign);
                end;

                if GetSettingBoolean('Upload', 'Sondehub', False) and (SondehubUploader <> nil) then begin
                    Position.Longitude := Position.Longitude + 0.01;
                    SondehubUploader.SaveTelemetryToSondehub(ID, Position);
                end;
            end;

            if GetSettingBoolean('Upload', 'MQTT', False) then begin
                MQTTUploader.SendTelemetry(Position.PayloadID, Position.Line);
            end;

            if GetSettingBoolean('Upload', 'HABLINK', False) then begin
                HablinkUploader.SendTelemetry(Position.PayloadID, Position.Line);
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

    if Sources[ID].RSSILabel <> nil then begin
        Temp := Sources[ID].CurrentFreq + Sources[ID].CurrentRSSI + Sources[ID].PacketRSSI + Sources[ID].FreqError;

        if (Temp <> '') and (ID in [GATEWAY_SOURCE_1, GATEWAY_SOURCE_2]) then begin
            Sources[ID].RSSILabel.Text := 'Ch' + IntToStr(Position.Channel) + ': ' + Temp;
        end else begin
            Sources[ID].RSSILabel.Text := Temp;
        end;
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

procedure TfrmSources.CarStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, HABHUB_UPLINK, Active, OK);
end;

procedure TfrmSources.HabitatStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, HABHUB_UPLINK, Active, OK);
end;

procedure TfrmSources.SSDVStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, SSDV_UPLINK, Active, OK);
end;

procedure TfrmSources.HabLinkStatusCallback(SourceID: Integer; Active, OK: Boolean; Status: String);
begin
    frmMain.UploadStatus(SourceID, HABLINK_UPLINK, Active, OK);
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
end;

procedure TfrmSources.UpdateCarUploadSettings;
begin
    SondehubUploader.SetListener(ApplicationName, ApplicationVersion,
                                 GetSettingString('CHASE', 'Callsign', 'UNKNOWN'),
                                 True,
                                 GetSettingInteger('CHASE', 'Period', 30),
                                 GetSettingBoolean('Upload', 'Upload', False));
end;

procedure TfrmSources.UpdateMQTTUploads;
var
    Callsign, Topic, CarTopic: String;
begin
    Callsign := GetSettingString('General', 'Callsign', '');

    Topic := StringReplace(GetSettingString('Upload', 'MQTTTopic', ''), '$LISTENER$', Callsign, [rfReplaceAll, rfIgnoreCase]);

    CarTopic := GetSettingString('Upload', 'MQTTChaseTopic', '');

    MQTTUploader.SetMQTTDetails(GetSettingString('Upload', 'MQTTBroker', ''),
                                GetSettingString('Upload', 'MQTTUserName', ''),
                                GetSettingString('Upload', 'MQTTPassword', ''),
                                Topic, CarTopic);

    HablinkUploader.SetMQTTDetails('hab.link', 'daffyduck', 'HAB2022', 'incoming/payloads/$PAYLOAD$', 'incoming/chase/$CALLSIGN$');
end;

end.
