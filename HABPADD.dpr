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
  Payloads in 'Payloads.pas' {frmPayloads},
  Settings in 'Settings.pas' {frmSettings},
  SettingsBase in 'SettingsBase.pas' {frmSettingsBase},
  GPSSettings in 'GPSSettings.pas' {frmGPSSettings},
  LoRaBluetoothSettings in 'LoRaBluetoothSettings.pas' {frmBluetoothSettings},
  SourcesForm in 'SourcesForm.pas' {frmSources},
  BluetoothSource in '..\HABRx\BluetoothSource.pas',
  Androidapi.JNI.WiFiManager in '..\HABRx\Androidapi.JNI.WiFiManager.pas',
  GatewaySource in '..\HABRx\GatewaySource.pas',
  GPSSource in '..\HABRx\GPSSource.pas',
  Miscellaneous in '..\HABRx\Miscellaneous.pas',
  SerialSource in '..\HABRx\SerialSource.pas',
  Source in '..\HABRx\Source.pas',
  UDPSource in '..\HABRx\UDPSource.pas',
  LoRaSerialSettings in 'LoRaSerialSettings.pas' {frmLoRaSerialSettings},
  Androidapi.JNI.Interfaces.JGeomagneticField in '..\HABRx\Androidapi.JNI.Interfaces.JGeomagneticField.pas',
  BLESource in '..\HABRx\BLESource.pas',
  SocketSource in '..\HABRx\SocketSource.pas',
  SSDV in '..\HABRx\SSDV.pas',
  Uplink in 'Uplink.pas' {frmUplink},
  Tawhiri in '..\HABRx\Tawhiri.pas',
  Sondehub in '..\HABRx\Sondehub.pas',
  Misc in 'Misc.pas',
  MQTTSource in '..\HABRx\MQTTSource.pas',
  MQTTUplink in '..\HABRx\MQTTUplink.pas',
  Debug in 'Debug.pas' {frmDebug},
  GeneralSettings in 'GeneralSettings.pas' {frmGeneralSettings},
  Log in 'Log.pas' {frmLog},
  LoRaGatewaySettings in 'LoRaGatewaySettings.pas' {frmLoRaGatewaySettings},
  LoRaGatewaySettings2 in 'LoRaGatewaySettings2.pas' {frmLoRaGatewaySettings2},
  Navigate in 'Navigate.pas' {frmNavigate},
  DownloadSettings in 'DownloadSettings.pas' {frmDownloadSettings},
  SSDVForm in 'SSDVForm.pas' {frmSSDV},
  UDPSettings in 'UDPSettings.pas' {frmUDPSettings},
  UploadSettings in 'UploadSettings.pas' {frmUploadSettings},
  WSMQTTSource in '..\HABRx\WSMQTTSource.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.


