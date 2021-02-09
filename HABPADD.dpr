program HABPADD;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {frmMain},
  Base in 'Base.pas' {frmBase},
  Splash in 'Splash.pas' {frmSplash},
  Map in 'Map.pas' {frmMap},
  Direction in 'Direction.pas',
  TargetForm in 'TargetForm.pas' {frmTarget},
  Log in 'Log.pas' {frmLog},
  Payloads in 'Payloads.pas' {frmPayloads},
  SSDVForm in 'SSDVForm.pas' {frmSSDV},
  UDPSettings in 'UDPSettings.pas' {frmUDPSettings},
  Settings in 'Settings.pas' {frmSettings},
  SettingsBase in 'SettingsBase.pas' {frmSettingsBase},
  GeneralSettings in 'GeneralSettings.pas' {frmGeneralSettings},
  GPSSettings in 'GPSSettings.pas' {frmGPSSettings},
  LoRaGatewaySettings in 'LoRaGatewaySettings.pas' {frmLoRaGatewaySettings},
  LoRaSerialSettings in 'LoRaSerialSettings.pas' {frmLoRaSerialSettings},
  HabitatSettings in 'HabitatSettings.pas' {frmHabitatSettings},
  LoRaBluetoothSettings in 'LoRaBluetoothSettings.pas' {frmBluetoothSettings},
  SourcesForm in 'SourcesForm.pas' {frmSources},
  Navigate in 'Navigate.pas' {frmNavigate},
  Habitat in '..\HABRx\Habitat.pas',
  Androidapi.JNI.WiFiManager in '..\HABRx\Androidapi.JNI.WiFiManager.pas',
  CarUpload in '..\HABRx\CarUpload.pas',
  GatewaySource in '..\HABRx\GatewaySource.pas',
  GPSSource in '..\HABRx\GPSSource.pas',
  HabitatSource in '..\HABRx\HabitatSource.pas',
  Miscellaneous in '..\HABRx\Miscellaneous.pas',
  SerialSource in '..\HABRx\SerialSource.pas',
  SocketSource in '..\HABRx\SocketSource.pas',
  Source in '..\HABRx\Source.pas',
  UDPSource in '..\HABRx\UDPSource.pas',
  BluetoothSource in '..\HABRx\BluetoothSource.pas',
  Debug in 'Debug.pas' {frmDebug},
  LoRaGatewaySettings2 in 'LoRaGatewaySettings2.pas' {frmLoRaGatewaySettings2},
  Androidapi.JNI.Interfaces.JGeomagneticField in '..\HABRx\Androidapi.JNI.Interfaces.JGeomagneticField.pas',
  HABLink in '..\HABRx\HABLink.pas',
  BLESource in '..\HABRx\BLESource.pas',
  SSDV in '..\HABRx\SSDV.pas',
  Uplink in 'Uplink.pas' {frmUplink};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmUplink, frmUplink);
  Application.Run;
end.
