unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, System.IOUtils,
  Math, Source, Miscellaneous, SourcesForm, Debug, FMX.Styles.Objects,
  Base, Splash, Map, Direction, Log, Payloads, SSDVForm, Navigate, Uplink,
{$IFDEF ANDROID}
  Androidapi.JNIBridge, AndroidApi.JNI.Media,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, Androidapi.JNI.Net,
  FMX.Helpers.Android, FMX.Platform.Android, AndroidApi.Jni.App,
  AndroidAPI.jni.OS, FMX.TMSCustomEdit, FMX.TMSEdit, FMX.TMSBaseGroup,
  System.Permissions,
{$ENDIF}
{$IFDEF IOS}
  iOSapi.Foundation, FMX.Helpers.iOS, Macapi.Helpers,
{$ENDIF}
  Settings, Tawhiri, FMX.TMSBitmapContainer, FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCMapsCommonTypes, FMX.TMSFNCCustomControl, FMX.TMSFNCWebBrowser,
  FMX.TMSFNCMaps, FMX.TMSFNCGoogleMaps;

type
  TPayload = record
      Previous:         THABPosition;
      Position:         THABPosition;
      Button:           TButton;
      Colour:           TAlphaColor;
      ColourName:       String;
      GoodPosition:     Boolean;
      LoggedLoss:       Boolean;
      SourceMask:       Integer;
      SSDVCount:        Integer;
      PredictionIndex:  Integer;
  end;

type
  TSource = record
    Button:         TButton;
    LastPositionAt: TDateTime;
    Circle:         TCircle;
end;

type
  TfrmMain = class(TForm)
    pnlCentre: TRectangle;
    StyleBook1: TStyleBook;
    btnPayloads: TButton;
    btnMap: TButton;
    btnSSDV: TButton;
    btnDirection: TButton;
    btnNavigate: TButton;
    btnUplink: TButton;
    btnSettings: TButton;
    tmrUpdates: TTimer;
    tmrBleep: TTimer;
    tmrLoad: TTimer;
    rectMain: TRectangle;
    btnSources: TButton;
    rectTopBar: TRectangle;
    crcTopRight: TCircle;
    rctTopRight: TRectangle;
    crcTopLeft: TCircle;
    rectTopLeft: TRectangle;
    rectPayloadButtons: TRectangle;
    lblPayload: TLabel;
    btnPayload1: TButton;
    btnPayload2: TButton;
    btnPayload3: TButton;
    rectBottomBar: TRectangle;
    crcBottomRight: TCircle;
    rectBottomRight: TRectangle;
    crcBottomLeft: TCircle;
    rectBottomLeft: TRectangle;
    rectSources: TRectangle;
    lblGPS: TLabel;
    rectButtons: TRectangle;
    TMSFMXBitmapContainer1: TTMSFMXBitmapContainer;
    pnlMap: TRectangle;
    rectUploads: TRectangle;
    FNCMap: TTMSFNCGoogleMaps;
    Button1: TButton;
    btnGPS: TButton;
    crcGPS: TCircle;
    btnGateway1: TButton;
    btnGateway2: TButton;
    btnLoRaSerial: TButton;
    crcLoRaSerial: TCircle;
    btnLoRaBT: TButton;
    crcLoRaBluetooth: TCircle;
    btnSondehub: TButton;
    btnUDP: TButton;
    btnHABHUBUplink: TButton;
    btnHablinkUplink: TButton;
    btnSondehubUplink: TButton;
    btnMQTTUplink: TButton;
    btnSSDVUplink: TButton;
    btnHABHUB: TButton;
    btnHABLINK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnMapClick(Sender: TObject);
    procedure btnPayloadsClick(Sender: TObject);
    procedure btnSSDVClick(Sender: TObject);
    procedure btnDirectionClick(Sender: TObject);
    procedure btnNavigateClick(Sender: TObject);
    procedure btnUplinkClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure tmrUpdatesTimer(Sender: TObject);
    procedure btnSourcesClick(Sender: TObject);
    procedure btnPayload1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Circle1Click(Sender: TObject);
    procedure tmrBleepTimer(Sender: TObject);
    procedure tmrLoadTimer(Sender: TObject);
    procedure pnlCentreResized(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure rectTopBarResize(Sender: TObject);
    procedure rectBottomBarResize(Sender: TObject);
    procedure FNCMapMapInitialized(Sender: TObject);
    procedure FNCMapElementContainers0Actions0Execute(Sender: TObject;
      AEventData: TTMSFNCMapsEventData);
    procedure FNCMapElementContainers0Actions2Execute(Sender: TObject;
      AEventData: TTMSFNCMapsEventData);
    procedure FNCMapElementContainers0Actions1Execute(Sender: TObject;
      AEventData: TTMSFNCMapsEventData);
    procedure Button1Click(Sender: TObject);
    procedure rectUploadsResize(Sender: TObject);
  private
    { Private declarations }
    DesignHeight, DesignWidth: Single;
    HeightFactor, WidthFactor: Double;
    CurrentForm: TfrmBase;
    Payloads: Array[1..3] of TPayload;
    Sources: Array[0..8] of TSource;
    PayloadIndex: Array[0..8] of Integer;
    ChasePosition: THABPosition;
    SelectedPayload: Integer;
    Predictor: TTawhiri;
    procedure ShowSelectedButton(Button: TButton);
    function PlacePayloadInList(SourceID: Integer; var Position: THABPosition): Integer;
    procedure SelectPayload(Button: TButton);
    procedure ShowSelectedPayloadPosition;
    function FindOrAddPayload(Position: THABPosition): Integer;
    procedure DoPayloadCalcs(Previous: THabPosition; var Position: THABPosition);
    procedure UpdatePayloadList;
    procedure Navigate(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double; OffRoad: Boolean = False);
    procedure ShowRouteOnMap(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double);
    procedure ResizeFonts;
    procedure WhereIsBalloon(PayloadIndex: Integer);
    procedure ShowSelectedMapButton(ElementID: String);
    procedure WhereAreBalloons;
{$IF Defined(IOS) or Defined(ANDROID)}
    procedure PlaySound(Flag: Integer);
{$ENDIF}
  public
    { Public declarations }
    FontScaling: Single;
    function LoadForm(Button: TButton; NewForm: TfrmBase): Boolean;
    procedure UploadStatus(SourceID, UploadID: Integer; Active, OK: Boolean);
    procedure NewPosition(SourceID: Integer; Position: THABPosition);
    function BalloonColour(PayloadIndex: Integer): TAlphaColor;
    function BalloonIconName(PayloadIndex: Integer; Target: Boolean=False): String;
    procedure NavigateToPayload(PayloadIndex: Integer; UsePrediction: Boolean; OffRoad: Boolean = False);
    procedure ShowRouteToPayload(PayloadIndex: Integer; UsePrediction: Boolean);
    procedure ShowSourceStatus(SourceID: Integer; Active, Recent: Boolean);
    function GetSourceMask(PayloadIndex: Integer): Integer;
    procedure UpdateAllUploadStatus;
    procedure LoadSettingsPage(PageIndex: Integer);
    procedure UpdateCarUploadSettings;
  end;

const
    HABHUB_UPLINK = 1;
    HABLINK_UPLINK = 2;
    SONDEHUB_UPLINK = 3;
    MQTT_UPLINK = 4;
    SSDV_UPLINK = 5;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.btnDirectionClick(Sender: TObject);
begin
    LoadForm(TButton(Sender), frmDirection);
end;

procedure TfrmMain.btnUplinkClick(Sender: TObject);
begin
    if LoadForm(TButton(Sender), frmUplink) then begin
        frmUplink.NewSelection(SelectedPayload);
    end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
    LoadForm(TButton(Sender), frmLog);
end;

procedure TfrmMain.btnMapClick(Sender: TObject);
begin
    LoadForm(TButton(Sender), nil);
end;

procedure TfrmMain.btnPayload1Click(Sender: TObject);
begin
    SelectPayload(TButton(Sender));
end;

procedure TfrmMain.btnPayloadsClick(Sender: TObject);
begin
    LoadForm(TButton(Sender), frmPayloads);
end;

procedure TfrmMain.btnSettingsClick(Sender: TObject);
begin
    LoadSettingsPage(0);
end;

procedure TfrmMain.btnSSDVClick(Sender: TObject);
begin
    LoadForm(TButton(Sender), frmSSDV);
end;

procedure TfrmMain.btnNavigateClick(Sender: TObject);
begin
    LoadForm(TButton(Sender), frmNavigate);
end;

procedure TfrmMain.Circle1Click(Sender: TObject);
begin
    LoadForm(nil, frmSplash);
end;

procedure TfrmMain.btnSourcesClick(Sender: TObject);
begin
    LoadForm(btnSources, frmSources);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
const
    FirstTime: Boolean = True;
begin
    if FirstTime then begin
        FirstTime := False;

        // Splash form
        frmSplash := TfrmSplash.Create(nil);
        LoadForm(nil, frmSplash);

        tmrLoad.Enabled := True;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    INIFileName := TPath.Combine(DataFolder, 'HABPADD.ini');

    CurrentForm := nil;

    HeightFactor := rectTopBar.Height / Height;
    WidthFactor := rectButtons.Width / Width;

    DesignHeight := frmMain.Height;
    DesignWidth := frmMain.Width;

    // Debug form, but only if we're a debug build
{$IFDEF DEBUG}
    frmDebug := TfrmDebug.Create(nil);
{$ENDIF}

//{$IFDEF IOS}
//    rectMain.Margins.Top := 18;
//{$ENDIF}

    // Payload info
    Payloads[1].Button := btnPayload1;
    Payloads[2].Button := btnPayload2;
    Payloads[3].Button := btnPayload3;

    Payloads[1].Colour := TAlphaColorRec.Blue;
    Payloads[2].Colour := TAlphaColorRec.Red;
    Payloads[3].Colour := TAlphaColorRec.Lime;

    Payloads[1].ColourName := 'blue';
    Payloads[2].ColourName := 'red';
    Payloads[3].ColourName :='green';

    InitialiseSettings;

    SelectedPayload := 0;

    // Source info
    Sources[GPS_SOURCE].Button := btnGPS;
    Sources[GPS_SOURCE].Circle := crcGPS;

    Sources[GATEWAY_SOURCE_1].Button := btnGateway1;
    Sources[GATEWAY_SOURCE_1].Circle := nil;

    Sources[GATEWAY_SOURCE_2].Button := btnGateway2;
    Sources[GATEWAY_SOURCE_2].Circle := nil;

    Sources[SERIAL_SOURCE].Button := btnLoRaSerial;
    Sources[SERIAL_SOURCE].Circle := crcLoRaSerial;

    Sources[BLUETOOTH_SOURCE].Button := btnLoRaBT;
    Sources[BLUETOOTH_SOURCE].Circle := crcLoRaBluetooth;

    Sources[SONDEHUB_SOURCE].Button := btnSondehub;
    Sources[SONDEHUB_SOURCE].Circle := nil;

    Sources[UDP_SOURCE].Button := btnUDP;
    Sources[UDP_SOURCE].Circle := nil;

    Sources[HABLINK_SOURCE].Button := btnHABLINK;
    Sources[HABLINK_SOURCE].Circle := nil;

    Sources[HABHUB_SOURCE].Button := btnHABHUB;
    Sources[HABHUB_SOURCE].Circle := nil;
    (*
    // Screen size
    {$IFDEF ANDROID}
        BorderStyle := TFmxFormBorderStyle.None;
        WindowState := TWindowState.wsMaximized;

        FullScreen := True;
    {$ENDIF}

    *)

{$IFDEF MSWINDOWS}
    FullScreen := False;
{$ELSE}
    FullScreen := True;
{$ENDIF}


    Predictor := TTawhiri.Create;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
    rectTopBar.Height := Height * HeightFactor;
    rectBottomBar.Height := Height * HeightFactor;
    rectButtons.Width := Width * WidthFactor;

    rectPayloadButtons.Height := rectBottomBar.Height;
    rectPayloadButtons.Position.X := rectButtons.Width * 1.2;
    lblPayload.Height := rectTopBar.Height;

    rectSources.Position.X := rectButtons.Width;
    lblGPS.Height := rectBottomBar.Height;
    rectSources.Height := rectTopBar.Height;
    rectUploads.Height := rectSources.Height;
end;

procedure TfrmMain.Label1Click(Sender: TObject);
begin
    Application.Terminate;
end;

function TfrmMain.LoadForm(Button: TButton; NewForm: TfrmBase): Boolean;
begin
    if (frmSettings <> nil) and (NewForm <> frmSettings) then begin
        frmSettings.Free;
        frmSettings := nil;
    end;

    ShowSelectedButton(Button);

    pnlCentre.Visible := NewForm <> nil;
    pnlMap.Visible := NewForm = nil;

    if NewForm <> nil then begin
        if CurrentForm <> nil then begin
            CurrentForm.HideForm;
        end;

        CurrentForm := NewForm;

        NewForm.DoBeforeLoad;
        NewForm.pnlMain.Parent := pnlCentre;
        NewForm.LoadForm;

        Result := True;
    end else begin
        Result := False;
    end;
end;

procedure TfrmMain.ShowSelectedButton(Button: TButton);
begin
    btnPayloads.TextSettings.Font.Style := btnPayloads.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnMap.TextSettings.Font.Style := btnMap.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnSSDV.TextSettings.Font.Style := btnSSDV.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnDirection.TextSettings.Font.Style := btnDirection.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnNavigate.TextSettings.Font.Style := btnNavigate.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnUplink.TextSettings.Font.Style := btnUplink.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnSettings.TextSettings.Font.Style := btnSettings.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnSources.TextSettings.Font.Style := btnSources.TextSettings.Font.Style - [TFontStyle.fsUnderline];

    if Button <> nil then begin
        Button.TextSettings.Font.Style := Button.TextSettings.Font.Style + [TFontStyle.fsUnderline];
    end;
end;

{$IFDEF ANDROID}
procedure TfrmMain.PlaySound(Flag: Integer);
var
  Volume, ADuration: Integer;
  StreamType: Integer;
  ToneType: Integer;
  ToneGenerator: JToneGenerator;
begin

  Volume := TJToneGenerator.JavaClass.MAX_VOLUME;
  ADuration := 100 * Flag;

  StreamType := TJAudioManager.JavaClass.STREAM_ALARM;
  ToneType := TJToneGenerator.JavaClass.TONE_DTMF_0;

  ToneGenerator := TJToneGenerator.JavaClass.init(StreamType, Volume);
  ToneGenerator.startTone(ToneType, ADuration);
end;
{$ENDIF}

{$IFDEF IOS}
procedure TfrmMain.PlaySound(Flag: Integer);
begin
    Beep;
end;
{$ENDIF}

procedure TfrmMain.pnlCentreResized(Sender: TObject);
var
    TextObject: TActiveStyleTextObject;
begin
    inherited;

    ResizeFonts;

    TextObject := TActiveStyleTextObject(StyleBook1.FindComponent('ItemText'));

    if TextObject <> nil then begin
        TextObject.Font.Size := 45;
    end;
end;

procedure TfrmMain.rectBottomBarResize(Sender: TObject);
begin
    rectBottomBar.Margins.Left := rectBottomBar.Height / 2;
    rectBottomBar.Margins.Right := rectBottomBar.Height / 2;

    crcBottomLeft.Width := crcBottomLeft.Height;
    crcBottomLeft.Margins.Left := -crcBottomLeft.Height/2;
    crcBottomRight.Width := crcBottomRight.Height;
    crcBottomRight.Margins.Right := -crcBottomRight.Height/2;

    rectBottomLeft.Margins.Bottom := crcBottomLeft.Height / 2;
    rectBottomRight.Margins.Bottom := crcTopLeft.Height / 2;
end;

procedure TfrmMain.rectTopBarResize(Sender: TObject);
begin
    rectTopBar.Margins.Left := rectTopBar.Height / 2;
    rectTopBar.Margins.Right := rectTopBar.Height / 2;

    crcTopLeft.Width := crcTopLeft.Height;
    crcTopLeft.Margins.Left := -crcTopLeft.Height/2;
    crcTopRight.Width := crcTopRight.Height;
    crcTopRight.Margins.Right := -crcTopRight.Height/2;

    rectTopLeft.Margins.Top := crcTopRight.Height / 2;
    rctTopRight.Margins.Top := crcTopRight.Height / 2;
end;

procedure TfrmMain.rectUploadsResize(Sender: TObject);
begin
//    lblMQTT.Height := rectUploadMQTT.Height;
//    lblMQTT.Width := rectUploadMQTT.Width;
//
//    lblSondehub.Height := rectUploadMQTT.Height;
//    lblSondehub.Width := rectUploadMQTT.Width;
//
//    lblSSDV.Height := rectUploadMQTT.Height;
//    lblSSDV.Width := rectUploadMQTT.Width;
end;

procedure TfrmMain.WhereIsBalloon(PayloadIndex: Integer);
begin
    if (ChasePosition.Latitude <> 0) or (ChasePosition.Longitude <> 0) then begin
        Payloads[PayloadIndex].Position.DirectionValid := True;
        // Horizontal distance to payload
        Payloads[PayloadIndex].Position.Distance := CalculateDistance(ChasePosition.Latitude, ChasePosition.Longitude,
                                                                      Payloads[PayloadIndex].Position.Latitude,
                                                                      Payloads[PayloadIndex].Position.Longitude);
        // Direction to payload
        Payloads[PayloadIndex].Position.Direction := CalculateDirection(Payloads[PayloadIndex].Position.Latitude,
                                                                       Payloads[PayloadIndex].Position.Longitude,
                                                                       ChasePosition.Latitude, ChasePosition.Longitude) -
                                                                       ChasePosition.Direction;

        Payloads[PayloadIndex].Position.Elevation := CalculateElevation(ChasePosition.Latitude, ChasePosition.Longitude, ChasePosition.Altitude,
                                                                        Payloads[PayloadIndex].Position.Latitude, Payloads[PayloadIndex].Position.Longitude, Payloads[PayloadIndex].Position.Altitude);


        if Payloads[PayloadIndex].Position.PredictionType <> ptNone then begin
            // Horizontal distance to payload
            Payloads[PayloadIndex].Position.PredictionDistance := CalculateDistance(ChasePosition.Latitude, ChasePosition.Longitude,
                                                                                      Payloads[PayloadIndex].Position.PredictedLatitude,
                                                                                      Payloads[PayloadIndex].Position.PredictedLongitude);
            // Direction to payload
            Payloads[PayloadIndex].Position.PredictionDirection := CalculateDirection(Payloads[PayloadIndex].Position.PredictedLatitude,
                                                                                       Payloads[PayloadIndex].Position.PredictedLongitude,
                                                                                       ChasePosition.Latitude, ChasePosition.Longitude) -
                                                                                       ChasePosition.Direction;
        end;
    end else begin
        Payloads[PayloadIndex].Position.DirectionValid := False;
    end;
end;

procedure TfrmMain.WhereAreBalloons;
var
    PayloadIndex: Integer;
begin
    for PayloadIndex := Low(Payloads) to High(Payloads) do begin
        WhereIsBalloon(PayloadIndex);
    end;
end;

procedure TfrmMain.NewPosition(SourceID: Integer; Position: THABPosition);
var
    Index: Integer;
    PositionOK: Boolean;
begin
    if Position.InUse then begin
        ShowSourceStatus(SourceID, True, True);

        Index := PlacePayloadInList(SourceID, Position);

        if Position.IsChase or (Index > 0) then begin
            if Position.IsChase then begin
                // Chase car only
                ChasePosition := Position;
                WhereAreBalloons;
                if frmDirection <> nil then frmDirection.NewPosition(0, ChasePosition);
    //        end else begin
            end else begin
                // Payloads only
                if Payloads[Index].LoggedLoss then begin
                    Payloads[Index].LoggedLoss := False;
                    frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'Signal Regained', True);
                end;

                PositionOK := (Position.Latitude <> 0.0) or (Position.Longitude <> 0.0);

                if PositionOK <> Payloads[Index].GoodPosition then begin
                    Payloads[Index].GoodPosition := PositionOK;

                    if PositionOK then begin
                        frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Valid', True);
                    end else begin
                        frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'GPS Position Lost', True);
                    end;
                end;

                WhereIsBalloon(Index);

                if frmPayloads <> nil then frmPayloads.NewPosition(Index, Payloads[Index].Position);
                if frmSSDV <> nil then frmSSDV.NewPosition(Index, Position);

                // Selected payload only
                if Index = SelectedPayload then begin
                    if frmDirection <> nil then frmDirection.NewPosition(Index, Payloads[Index].Position);
                    ShowSelectedPayloadPosition;
                end;

                // Select payload if it's the only one
                if SelectedPayload < 1 then begin
                    SelectPayload(btnPayload1);
                end;

                if GetSettingBoolean('General', 'PositionBeeps', False) then begin
                    tmrBleep.Tag := 1;
                end;

                // Landing prediction needed ?
                if Position.PredictionType = ptNone then begin
                    if Payloads[Index].PredictionIndex <= 0 then begin
                        Payloads[Index].PredictionIndex := Predictor.AddPayload(Position.PayloadID);
                    end;

                    if Payloads[Index].PredictionIndex > 0 then begin
                        Predictor.UpdatePayload(Payloads[Index].PredictionIndex,
                                                Position.Latitude,
                                                Position.Longitude,
                                                Position.Altitude,
                                                30000,      // Burst
                                                Position.AscentRate,
                                                5);
                    end;
                end;
            end;

            // Payloads and Chase Car
            if frmMap <> nil then begin
                if (Position.Latitude <> 0) or (Position.Longitude <> 0) then begin
                    frmMap.NewPosition(Index, Position);
                end;
            end;
        end;
    end else begin
        Index := PayloadIndex[SourceID];

        if (Index >= Low(Payloads)) and (Index <= High(Payloads)) then begin
            if Position.IsSSDV then begin
                Inc(Payloads[Index].SSDVCount);
                Position.SSDVCount := Payloads[Index].SSDVCount;
            end;

            // Update RSSI etc
            if frmPayloads <> nil then begin
                try
                    Position.FlightMode := Payloads[Index].Position.FlightMode;
                    frmPayloads.NewPosition(Index, Position);
                except
                    //
                end;
            end;
        end;
    end;
    // Show active on status bar
//    if SourceID = 1 then lblGateway.FontColor := TAlphaColorRec.Black;
//    if SourceID = 2 then Label2.FontColor := TAlphaColorRec.Black;
//    if SourceID = 3 then Label3.FontColor := TAlphaColorRec.Black;
//    if SourceID = 4 then Label4.FontColor := TAlphaColorRec.Black;
//    if SourceID = 5 then Label5.FontColor := TAlphaColorRec.Black;
end;

function TfrmMain.PlacePayloadInList(SourceID: Integer; var Position: THABPosition): Integer;
var
    NewMask, Index: Integer;
    PayloadChanged: Boolean;
begin
    Result := 0;

    if Position.InUse and not Position.IsChase then begin
        Index := FindOrAddPayload(Position);

        PayloadIndex[SourceID] := Index;

        if Index > 0 then begin
            NewMask := Payloads[Index].SourceMask or ((1 shl (SourceID * 2)) shl Position.Channel);
            if NewMask <> Payloads[Index].SourceMask then begin
                Payloads[Index].SourceMask := NewMask;
                if frmUplink <> nil then frmUplink.NewSelection(SelectedPayload);
            end;

            // Update forms with payload list, if it has changed
            if (not Payloads[Index].Position.InUse) or (Position.PayloadID <> Payloads[Index].Position.PayloadID) then begin
                frmLog.AddMessage(Position.PayloadID, 'Online', True);
                PayloadChanged := True;
            end else begin
                PayloadChanged := False;
            end;

            // if (Position.TimeStamp - Payloads[Index].Previous.TimeStamp) >= 1/86400 then begin
            if (Position.TimeStamp > Payloads[Index].Position.TimeStamp) or (Position.PayloadID <> Payloads[Index].Position.PayloadID) then begin
                // Retrieve previous flight mode
                Position.FlightMode := Payloads[Index].Previous.FlightMode;

                // Calculate ascent rate etc
                DoPayloadCalcs(Payloads[Index].Previous, Position);

                // Update buttons
                Payloads[Index].Button.Text := Position.PayloadID;
                Payloads[Index].Button.Opacity := 1;

                // Store new position
                Payloads[Index].Previous := Payloads[Index].Position;

                Position.TelemetryCount := Payloads[Index].Previous.TelemetryCount + 1;

                Payloads[Index].Position := Position;
                Payloads[Index].Previous.FlightMode := Position.FlightMode;

                (*
                // Select payload if it's the only one
                if SelectedPayload < 1 then begin
                    SelectPayload(btnPayload1);
                end;
                *)

                if PayloadChanged  and (SourceID <> SONDEHUB_SOURCE) then begin
                    UpdatePayloadList;
                end;

                Result := Index;
            end;
        end;
    end;
end;

procedure TfrmMain.ShowSelectedPayloadPosition;
begin
    with Payloads[SelectedPayload].Position do begin
        frmMain.lblPayload.Text := FormatDateTime('hh:nn:ss', TimeStamp) + '  ' +
                           Format('%2.6f', [Latitude]) + ',' +
                           Format('%2.6f', [Longitude]) + ' at ' +
                           Format('%.0f', [Altitude]) + 'm';
    end;
end;

procedure TfrmMain.tmrBleepTimer(Sender: TObject);
begin
    if tmrBleep.Tag > 0 then begin
        if tmrBleep.Tag = 1 then begin
            {$IFDEF WINDOWS}
            MessageBeep(MB_OK);
            {$ENDIF}
            {$IF Defined(IOS) or Defined(ANDROID)}
            PlaySound(1);
            {$ENDIF}
        end else if tmrBleep.Tag = 2 then begin
            {$IFDEF WINDOWS}
            MessageBeep(MB_ICONERROR);
            {$ENDIF}
            {$IF Defined(IOS) or Defined(ANDROID)}
            PlaySound(2);
            {$ENDIF}
        end else begin
            {$IFDEF WINDOWS}
            MessageBeep(MB_ICONWARNING);
            {$ENDIF}
            {$IF Defined(IOS) or Defined(ANDROID)}
            PlaySound(3);
            {$ENDIF}
        end;
    end;

    tmrBleep.Tag := 0;
end;

procedure TfrmMain.tmrLoadTimer(Sender: TObject);
begin
    tmrLoad.Enabled := False;

    // Main forms
    frmPayloads := TfrmPayloads.Create(nil);

    frmMap := TfrmMap.Create(nil);
    frmMap.LoadForm;

    frmSSDV := TfrmSSDV.Create(nil);
    frmDirection := TfrmDirection.Create(nil);
    frmNavigate := TfrmNavigate.Create(nil);
    frmUplink := TfrmUplink.Create(nil);
    frmLog := TfrmLog.Create(nil);

    // Sources Form
    frmSources := TfrmSources.Create(nil);

    // Ask for GPS permission
{$IFDEF ANDROID}
    frmSources.lblGPS.Text := 'GPS Permission Refused';

//    PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
//        procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>) begin
//            if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then begin
//                // activate or deactivate the location sensor }
//                frmSources.EnableGPS;
//            end else begin
//                frmSources.lblGPS.Text := 'GPS Permission Refused';
//            end;
//        end);

    PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
            if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then begin
                // activate or deactivate the location sensor }
                    frmSources.EnableGPS;
                end else begin
                    frmSources.lblGPS.Text := 'No GPS Permission';
                end;
            end);
{$ENDIF}

{$IFDEF IOS}
    btnLoRaBT.Text := 'BLE';
    btnLoRaSerial.Text := '';
    crcLoRaSerial.Visible := False;
    frmSources.EnableGPS;
{$ENDIF}

    frmSources.EnableCompass;

    frmSplash.UnveilSplash;

    tmrBleep.Enabled := True;
    tmrUpdates.Enabled := True;

    lblGPS.Text := '';
end;

procedure TfrmMain.tmrUpdatesTimer(Sender: TObject);
var
    SourceID, Index: Integer;
    PredictedAltitude: Double;
begin
    if frmPayloads <> nil then begin
        for Index := Low(Payloads) to High(Payloads) do begin
            if Payloads[Index].Position.InUse and (Payloads[Index].Position.ReceivedAt > 0) then begin
                frmPayloads.ShowTimeSinceUpdate(Index, Now - Payloads[Index].Position.ReceivedAt, Payloads[Index].Position.PayloadID, Payloads[Index].Position.Repeated);

                if (Now - Payloads[Index].Position.ReceivedAt) > 60/86400 then begin
                    if not Payloads[Index].LoggedLoss then begin
                        Payloads[Index].Button.TextSettings.FontColor := TAlphaColorRec.Red;
                        Payloads[Index].LoggedLoss := True;
                        frmLog.AddMessage(Payloads[Index].Position.PayloadID, 'Signal Lost', True);
                        if GetSettingBoolean('General', 'AlarmBeeps', False) then begin
                            tmrBleep.Tag := 2;
                        end;
                    end;
                end else begin
                    Payloads[Index].Button.TextSettings.FontColor := TAlphaColorRec.Green;
                end;

                // Prediction done ?
                if Payloads[Index].Position.PredictionType = ptNone then begin
                    if Payloads[Index].PredictionIndex > 0 then begin
                        if Predictor.PredictionUpdated(Payloads[Index].PredictionIndex) then begin
                            Predictor.GetPrediction(Index, Payloads[Index].Position.PredictedLatitude, Payloads[Index].Position.PredictedLongitude, PredictedAltitude);
                            Payloads[Index].Position.PredictionType := ptTawhiri;

                            // Get and draw path
//                            frmMap.ClearPredictionPath(PayloadIndex, HABPayloads[PayloadIndex].Colour);
//                            Index := 0;
//                            repeat
//                                Inc(Index);
//                                OK := Predictor.GetPayloadPath(PayloadIndex, Index, PredictedLatitude, PredictedLongitude, PredictedAltitude);
//                                if OK then begin
//                                    frmMap.AppendToPredictionPath(PayloadIndex, PredictedLatitude, PredictedLongitude, PredictedAltitude);
//                                end;
//                            until not OK;

                            // Move marker on map
                            // frmMap.SetLandingMarker(PayloadIndex, HABPayloads[PayloadIndex].Position, HABPayloads[PayloadIndex].ColourText);

                            // Updated in payload box
                            // HABPayloads[PayloadIndex].Form.UpdatePrediction(HABPayloads[PayloadIndex].Position);
                            if frmPayloads <> nil then frmPayloads.NewPosition(Index, Payloads[Index].Position);
                            if frmMap <> nil then frmMap.NewPosition(Index, Payloads[Index].Position);
                        end;
                    end;
                end;
            end;
        end;
    end;

    for SourceID := Low(Sources) to High(Sources) do begin
        if (Now - Sources[SourceID].LastPositionAt) > 60/86400 then begin
            ShowSourceStatus(SourceID, Sources[SourceID].LastPositionAt > 0, False);
        end;
    end;
end;

function TfrmMain.FindOrAddPayload(Position: THABPosition): Integer;
var
    i: Integer;
begin
    // Look for same payload
    for i := Low(Payloads) to High(Payloads) do begin
        if Payloads[i].Position.InUse then begin
            if Position.PayloadID = Payloads[i].Position.PayloadID then begin
                Result := i;
                Exit;
            end;
        end;
    end;

    // Look for empty slot
    for i := Low(Payloads) to High(Payloads) do begin
        if not Payloads[i].Position.InUse then begin
            Result := i;
            Exit;
        end;
    end;

    // Look for oldest payload
    Result := Low(Payloads);
    for i := Low(Payloads)+1 to High(Payloads) do begin
        if Payloads[i].Position.TimeStamp < Payloads[Result].Position.TimeStamp then begin
            // This one is older than oldest so far
            Result := i;
        end;
    end;
end;

procedure TfrmMain.ShowSelectedMapButton(ElementID: String);
begin
    FNCMap.ExecuteJavaScript('document.getElementById("btnCar").disabled = false');
    FNCMap.ExecuteJavaScript('document.getElementById("btnHAB").disabled = false');
    FNCMap.ExecuteJavaScript('document.getElementById("btnFree").disabled = false');

    FNCMap.ExecuteJavaScript('document.getElementById("' + ElementID + '").disabled = true');
end;

procedure TfrmMain.FNCMapElementContainers0Actions0Execute(Sender: TObject;
  AEventData: TTMSFNCMapsEventData);
begin
    ShowSelectedMapButton('btnCar');
    frmMap.btnCarClick(Sender);
end;

procedure TfrmMain.FNCMapElementContainers0Actions1Execute(Sender: TObject;
  AEventData: TTMSFNCMapsEventData);
begin
    ShowSelectedMapButton('btnHAB');
    frmMap.btnPayloadClick(Sender);
end;

procedure TfrmMain.FNCMapElementContainers0Actions2Execute(Sender: TObject;
  AEventData: TTMSFNCMapsEventData);
begin
    ShowSelectedMapButton('btnFree');
    frmMap.btnFreeClick(Sender);
end;

procedure TfrmMain.FNCMapMapInitialized(Sender: TObject);
begin
    frmMap.MapInitialized;
end;

procedure TfrmMain.DoPayloadCalcs(Previous: THabPosition; var Position: THABPosition);
const
    FlightModes: Array[0..8] of String = ('Idle', 'Launched', 'Descending', 'Homing', 'Direct To Target', 'Downwind', 'Upwind', 'Landing', 'Landed');
begin
    Position.AscentRate := (Position.Altitude - Previous.Altitude) / (86400 * (Position.TimeStamp - Previous.TimeStamp));
    Position.MaxAltitude := max(Position.Altitude, Previous.MaxAltitude);

    // Flight mode
    case Previous.FlightMode of
        fmIdle: begin
            if ((Position.AscentRate > 2.0) and (Position.Altitude > 100)) or
               (Position.Altitude > 5000) or
               (Abs(Position.AscentRate) > 20) or
               ((Position.AscentRate > 1.0) and (Position.Altitude > 300)) then begin
                Position.FlightMode := fmLaunched;
                frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True);
            end;
        end;

        fmLaunched: begin
            if Position.AscentRate < -4 then begin
                Position.FlightMode := fmDescending;
                frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True);
                if GetSettingBoolean('General', 'AlarmBeeps', False) then begin
                    tmrBleep.Tag := 3;
                end;
            end;
        end;

        fmDescending: begin
            if Position.AscentRate > -1 then begin
                Position.FlightMode := fmLanded;
                frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True);
            end;
        end;

        fmLanded: begin
            if ((Position.AscentRate > 3.0) and (Position.Altitude > 100)) or
               ((Position.AscentRate > 2.0) and (Position.Altitude > 500)) then begin
                Position.FlightMode := fmLaunched;
                frmLog.AddMessage(Position.PayloadID, FlightModes[Ord(Position.FlightMode)], True);
            end;
        end;
    end;

    if Position.FlightMode = fmDescending then begin
        Position.DescentTime := CalculateDescentTime(Position.Altitude, -Position.AscentRate, ChasePosition.Altitude) / 86400;
    end;
end;

procedure TfrmMain.SelectPayload(Button: TButton);
begin
    if Button.Tag <> SelectedPayload then begin
        if Payloads[Button.Tag].Position.InUse then begin
            // Select payload
            SelectedPayload := Button.Tag;

            // Show selected payload on buttons
            btnPayload1.TextSettings.Font.Style := btnPayload1.TextSettings.Font.Style - [TFontStyle.fsUnderline];
            btnPayload2.TextSettings.Font.Style := btnPayload1.TextSettings.Font.Style - [TFontStyle.fsUnderline];
            btnPayload2.TextSettings.Font.Style := btnPayload1.TextSettings.Font.Style - [TFontStyle.fsUnderline];
            Button.TextSettings.Font.Style := btnPayload1.TextSettings.Font.Style + [TFontStyle.fsUnderline];

            // Tell forms that need to know
            if frmSSDV <> nil then frmSSDV.NewSelection(SelectedPayload);
            if frmDirection <> nil then frmDirection.NewSelection(SelectedPayload);
            if frmNavigate <> nil then frmNavigate.NewSelection(SelectedPayload);
            if frmUplink <> nil then frmUplink.NewSelection(SelectedPayload);
            if frmMap <> nil then frmMap.NewSelection(SelectedPayload);

            // Update main screen
            ShowSelectedPayloadPosition;
        end;
    end;
end;

function TfrmMain.BalloonColour(PayloadIndex: Integer): TAlphaColor;
begin
    if (PayloadIndex >= Low(Payloads)) and (PayloadIndex <= High(Payloads)) then begin
        Result := Payloads[PayloadIndex].Colour;
    end else begin
        Result := Payloads[Low(Payloads)].Colour;
    end;
end;

function TfrmMain.BalloonIconName(PayloadIndex: Integer; Target: Boolean=False): String;
begin
    Result := 'balloon-' + Payloads[PayloadIndex].ColourName;

    if Target then begin
        Result := 'x-' + Payloads[PayloadIndex].ColourName;
    end else begin
        case Payloads[PayloadIndex].Position.FlightMode of
            fmIdle:         Result := 'payload-' + Payloads[PayloadIndex].ColourName;
            fmLaunched:     Result := 'balloon-' + Payloads[PayloadIndex].ColourName;
            fmDescending:   Result := 'parachute-' + Payloads[PayloadIndex].ColourName;
            fmLanded:       Result := 'payload-' + Payloads[PayloadIndex].ColourName;
        end;
    end;
end;

{$IFDEF ANDROID}
(*
procedure OpenURL(const URL: string);
var
  LIntent: JIntent;
  Data: Jnet_Uri;
begin
  LIntent := TJIntent.Create;
  Data := TJnet_Uri.JavaClass.parse(StringToJString(URL));
  LIntent.setData(Data);
  LIntent.setAction(StringToJString('android.intent.action.VIEW'));
  TAndroidHelper.Activity.startActivity(LIntent);
end;
*)
procedure OpenURL(const URL: string);
var
    Intent: JIntent;
begin
  Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW, TJnet_Uri.JavaClass.parse(StringToJString(URL)));
  try
    SharedActivity.startActivity(Intent);
  except
  end;
end;
{$ENDIF ANDROID}

{$IFDEF IOS}
function OpenURL(const URL: string): Boolean;
var
  NSU: NSUrl;
begin
    Result := False;

    // iOS doesn't like spaces, so URL encode is important.
    // NSU := StrToNSUrl(TIdURI.URLEncode(URL));
    NSU := StrToNSUrl(URL);
    if SharedApplication.canOpenURL(NSU) then begin
        SharedApplication.openUrl(NSU);
        Result := True;
    end;
end;
{$ENDIF}


procedure TfrmMain.Navigate(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double; OffRoad: Boolean = False);
begin
{$IFDEF IOS}
    if not OpenURL('comgooglemaps://?daddr=' + TargetLatitude.ToString + ',' + TargetLongitude.ToString) then begin
        OpenURL('http://maps.apple.com/?daddr=' + TargetLatitude.ToString + ',' + TargetLongitude.ToString);
    end;
{$ELSEIF ANDROID}

    if OffRoad then begin
        // This offers us Backcountry Navigator etc.
        OpenURL('geo:' + TargetLatitude.ToString + ',' + TargetLongitude.ToString);
    end else begin
        // This offers us Sygic etc.
        OpenURL('google.navigation:q=' + TargetLatitude.ToString + ',' + TargetLongitude.ToString);
    end;

{$ELSE}

    ShowRouteOnMap(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude);

{$ENDIF ANDROID}
end;

procedure TfrmMain.ShowRouteOnMap(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double);
begin
    if frmMap <> nil then begin
        frmMap.ShowDirections(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude);
        LoadForm(btnMap, frmMap);
    end;
end;

procedure TfrmMain.NavigateToPayload(PayloadIndex: Integer; UsePrediction: Boolean; Offroad: Boolean = False);
begin
    if PayloadIndex > 0 then begin
        if UsePrediction then begin
            Navigate(Payloads[PayloadIndex].Position.PredictedLatitude,
                     Payloads[PayloadIndex].Position.PredictedLongitude,
                     ChasePosition.Latitude,
                     ChasePosition.Longitude,
                     OffRoad);
        end else begin
            Navigate(Payloads[PayloadIndex].Position.Latitude,
                     Payloads[PayloadIndex].Position.Longitude,
                     ChasePosition.Latitude,
                     ChasePosition.Longitude,
                     OffRoad);
        end;
    end;
end;

procedure TfrmMain.ShowRouteToPayload(PayloadIndex: Integer; UsePrediction: Boolean);
begin
    if PayloadIndex > 0 then begin
        if UsePrediction then begin
            ShowRouteOnMap(Payloads[PayloadIndex].Position.PredictedLatitude,
                           Payloads[PayloadIndex].Position.PredictedLongitude,
                           ChasePosition.Latitude,
                           ChasePosition.Longitude);
        end else begin
            ShowRouteOnMap(Payloads[PayloadIndex].Position.Latitude,
                           Payloads[PayloadIndex].Position.Longitude,
                           ChasePosition.Latitude,
                           ChasePosition.Longitude);
        end;
    end;
end;

procedure TfrmMain.UpdatePayloadList;
var
    PayloadList: String;
    i: Integer;
begin
    PayloadList := '';

    for i := Low(Payloads) to High(Payloads) do begin
        if Payloads[i].Position.InUse then begin
            PayloadList := PayloadList + ';' + Payloads[i].Position.PayloadID;
        end;
    end;

    PayloadList := Copy(PayloadList, 2, 999);

    frmSources.UpdatePayloadList(PayloadList);

    for i := Low(Payloads) to High(Payloads) do begin
        if frmNavigate <> nil then frmNavigate.UpdatePayloadID(i, Payloads[i].Position.PayloadID);
        if frmUplink <> nil then frmUplink.UpdatePayloadID(i, Payloads[i].Position.PayloadID);
    end;
end;

procedure TfrmMain.ShowSourceStatus(SourceID: Integer; Active, Recent: Boolean);
begin
    if Sources[SourceID].Button <> nil then begin
        if Active then begin
            Sources[SourceID].Button.Opacity := 1.0;
            if Recent then begin
                Sources[SourceID].Button.TextSettings.FontColor := TAlphaColorRec.Green;
                Sources[SourceID].LastPositionAt := Now;
            end else begin
                Sources[SourceID].Button.TextSettings.FontColor := TAlphaColorRec.Red;
            end;
        end else begin
            Sources[SourceID].Button.Opacity := 0.7;
            Sources[SourceID].Button.TextSettings.FontColor := TAlphaColorRec.Black;
        end;
    end;
end;

procedure TfrmMain.UpdateAllUploadStatus;
begin
    UploadStatus(-1, 1, False, False);
    UploadStatus(-1, 2, False, False);
    UploadStatus(-1, 3, False, False);
    UploadStatus(-1, 4, False, False);
    UploadStatus(-1, 5, False, False);

    frmSources.UpdateMQTTUploads;
end;

procedure TfrmMain.UploadStatus(SourceID, UploadID: Integer; Active, OK: Boolean);
var
    Button: TButton;
    Enabled: Boolean;
begin
    // Show source upload status
    if (SourceID >= Low(Sources)) and (SourceID <= High(Sources)) then begin
        if Sources[SourceID].Circle <> nil then begin
            if Active then begin
                if OK then begin
                    Sources[SourceID].Circle.Fill.Color := TAlphaColorRec.Lime;
                end else begin
                    Sources[SourceID].Circle.Fill.Color := TAlphaColorRec.Red;
                end;
            end else begin
                Sources[SourceID].Circle.Fill.Color := TAlphaColorRec.Silver;
            end;
        end;
    end;

    // Show upload status
    case UploadID of
        HABHUB_UPLINK: begin
            Button := btnHABHUBUplink;
            Enabled := GetSettingBoolean('Upload', 'HABHUB', False);
        end;

        HABLINK_UPLINK: begin
            Button := btnHablinkUplink;
            Enabled := GetSettingBoolean('Upload', 'Hablink', False);
        end;

        SONDEHUB_UPLINK: begin
            Button := btnSondehubUplink;
            Enabled := GetSettingBoolean('Upload', 'Sondehub', False);
        end;

        MQTT_UPLINK:  begin
            Button := btnMQTTUplink;
            Enabled := GetSettingBoolean('Upload', 'MQTT', False);
        end;

        SSDV_UPLINK:  begin
            Button := btnSSDVUplink;
            Enabled := GetSettingBoolean('Upload', 'SSDV', False);
        end;
        else Button := nil;
    end;

    if Button <> nil then begin
        if Active then begin
            Button.Opacity := 1.0;
            if OK then begin
                Button.TextSettings.FontColor := TAlphaColorRec.Green;
            end else begin
                Button.TextSettings.FontColor := TAlphaColorRec.Red;
            end;
        end else begin
            Button.Opacity := 0.7;
            Button.TextSettings.FontColor := TAlphaColorRec.Black;
        end;


//        if Enabled then begin
//            if Active then begin
//                if OK then begin
//                    Button.Fill.Color := TAlphaColorRec.Lime;
//                end else begin
//                    Button.Fill.Color := TAlphaColorRec.Red;
//                end;
//            end else begin
//                Button.Fill.Color := $FFF1DF6F;
//            end;
//        end else begin
//            Button.Fill.Color := $FFA99C4E;
//        end;
    end;

    // Log errors in debug screen
    if Active and (not OK) and (frmDebug <> nil) then begin
        frmDebug.Debug(SourceName(SourceID) + ' failed to upload position');
    end;
end;

procedure TfrmMain.ResizeFonts;
const
    Resized: Boolean = False;
var
    i: Integer;
    Component: TComponent;
begin
    if (DesignHeight > 0) and not Resized then begin
        Resized := True;
        if frmDebug <> nil then begin
            frmDebug.Debug('Design Size = ' + FormatFloat('0.0', DesignWidth) +
                            ' x ' + FormatFloat('0.0', DesignHeight));
            frmDebug.Debug('Form Size = ' + Self.Width.ToString + ' x ' + Self.Height.ToString);
        end;

        FontScaling := Min(frmMain.Height / DesignHeight, frmMain.Width / DesignWidth);

//        {$IFDEF IOS}
//            FontScaling := FontScaling * 0.7;
//        {$ENDIF}

        for i := 0 to ComponentCount-1 do begin
            Component := Components[i];

            if Component is TLabel then begin
                TLabel(Component).TextSettings.Font.Size := TLabel(Component).TextSettings.Font.Size * FontScaling;
            end else if Component is TButton then begin
                TButton(Component).TextSettings.Font.Size := TButton(Component).TextSettings.Font.Size * FontScaling;
            end;
        end;
    end;
end;

function TfrmMain.GetSourceMask(PayloadIndex: Integer): Integer;
begin
    Result := Payloads[PayloadIndex].SourceMask;
end;

procedure TfrmMain.LoadSettingsPage(PageIndex: Integer);
begin
    if frmSettings = nil then begin
        frmSettings := TfrmSettings.Create(nil);
    end;

    LoadForm(btnSettings, frmSettings);

    frmSettings.LoadPage(PageIndex);
end;

procedure TfrmMain.UpdateCarUploadSettings;
begin
    frmSources.UpdateCarUploadSettings;
end;

end.
