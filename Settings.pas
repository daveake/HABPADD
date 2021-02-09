unit Settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.ListBox,
  FMX.TMSCustomEdit, FMX.TMSEdit, FMX.Objects, SettingsBase, GeneralSettings;

type
  TSettingType = (stString, stInteger, stBoolean, stSerialPort, stBluetooth);

type
  TfrmSettings = class(TfrmBase)
    Rectangle2: TRectangle;
    btnGPS: TButton;
    btnUDP: TButton;
    btnLoRaBT: TButton;
    btnLoRaSerial: TButton;
    btnGateway1: TButton;
    btnHabitat: TButton;
    btnGeneral: TButton;
    btnGateway2: TButton;
    procedure btnGPSClick(Sender: TObject);
    procedure btnGateway1Click(Sender: TObject);
    procedure btnLoRaSerialClick(Sender: TObject);
    procedure btnLoRaBTClick(Sender: TObject);
    procedure btnUDPClick(Sender: TObject);
    procedure btnHabitatClick(Sender: TObject);
    procedure btnGeneralClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGateway2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    CurrentForm: TfrmSettingsBase;
    procedure ShowSelectedButton(Button: TButton);
    procedure LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
  public
    { Public declarations }
    procedure LoadForm; override;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.fmx}

uses Main, GPSSettings, LoRaGatewaySettings, LoRaGatewaySettings2, HabitatSettings, LoRaSerialSettings, UDPSettings, LoRaBluetoothSettings;

procedure TfrmSettings.LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
begin
    ShowSelectedButton(Button);

    if CurrentForm <> nil then begin
        CurrentForm.pnlMain.Parent := CurrentForm;
        CurrentForm.HideForm;
    end;

    NewForm.pnlMain.Parent := pnlMain;
    CurrentForm := NewForm;
    NewForm.LoadForm;
end;

procedure TfrmSettings.btnGateway1Click(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmLoRaGatewaySettings);
end;

procedure TfrmSettings.btnGateway2Click(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmLoRaGatewaySettings2);
end;

procedure TfrmSettings.btnGeneralClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmGeneralSettings);
end;

procedure TfrmSettings.btnGPSClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmGPSSettings);
end;

procedure TfrmSettings.btnHabitatClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmHabitatSettings);
end;

procedure TfrmSettings.btnLoRaSerialClick(Sender: TObject);
begin
    if frmLoRaSerialSettings <> nil then begin
        LoadSettingsForm(TButton(Sender), frmLoRaSerialSettings);
    end;
end;

procedure TfrmSettings.btnUDPClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmUDPSettings);
end;

procedure TfrmSettings.btnLoRaBTClick(Sender: TObject);
begin
    LoadSettingsForm(TButton(Sender), frmBluetoothSettings);
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
    inherited;

    frmGPSSettings := TfrmGPSSettings.Create(nil);
    frmLoRaGatewaySettings := TfrmLoRaGatewaySettings.Create(nil);
    frmLoRaGatewaySettings2 := TfrmLoRaGatewaySettings2.Create(nil);
    frmHabitatSettings := TfrmHabitatSettings.Create(nil);

    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        frmLoRaSerialSettings := TfrmLoRaSerialSettings.Create(nil);
    {$ELSE}
        btnLoRaSerial.Text := '';
        btnLoRaBT.Text := 'BLE';
    {$ENDIF}

    frmBluetoothSettings := TfrmBluetoothSettings.Create(nil);
    frmUDPSettings := TfrmUDPSettings.Create(nil);
    frmGeneralSettings := TfrmGeneralSettings.Create(nil);
end;

procedure TfrmSettings.FormDestroy(Sender: TObject);
begin
    frmGPSSettings.Free;
    frmLoRaGatewaySettings.Free;
    frmLoRaGatewaySettings2.Free;
    frmHabitatSettings.Free;

    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        frmLoRaSerialSettings.Free;
    {$ENDIF}

    frmBluetoothSettings.Free;
    frmUDPSettings.Free;
    frmGeneralSettings.Free;
end;

procedure TfrmSettings.LoadForm;
begin
    inherited;

    LoadSettingsForm(btnGeneral, frmGeneralSettings);

    Application.ProcessMessages;

    btnGeneral.Font.Size := btnGeneral.Size.Height * 0.9;
    btnGPS.Font.Size := btnGeneral.Size.Height * 0.9;
    btnGateway1.Font.Size := btnGeneral.Size.Height * 0.9;
    btnGateway2.Font.Size := btnGeneral.Size.Height * 0.9;
    btnLoRaSerial.Font.Size := btnGeneral.Size.Height * 0.9;
    btnLoRaBT.Font.Size := btnGeneral.Size.Height * 0.9;
    btnUDP.Font.Size := btnGeneral.Size.Height * 0.9;
    btnHabitat.Font.Size := btnGeneral.Size.Height * 0.9;
end;

procedure TfrmSettings.ShowSelectedButton(Button: TButton);
begin
    btnGeneral.TextSettings.Font.Style := btnGeneral.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGPS.TextSettings.Font.Style := btnGPS.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnLoRaSerial.TextSettings.Font.Style := btnLoRaSerial.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnHabitat.TextSettings.Font.Style := btnHabitat.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnLoRaBT.TextSettings.Font.Style := btnLoRaBT.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnUDP.TextSettings.Font.Style := btnUDP.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGateway1.TextSettings.Font.Style := btnGateway1.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGateway2.TextSettings.Font.Style := btnGateway2.TextSettings.Font.Style - [TFontStyle.fsUnderline];

    Button.TextSettings.Font.Style := Button.TextSettings.Font.Style + [TFontStyle.fsUnderline];
end;

end.
