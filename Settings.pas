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
    btnDownloads: TButton;
    btnGeneral: TButton;
    btnGateway2: TButton;
    btnUploads: TButton;
    procedure btnGPSClick(Sender: TObject);
    procedure btnGateway1Click(Sender: TObject);
    procedure btnLoRaSerialClick(Sender: TObject);
    procedure btnLoRaBTClick(Sender: TObject);
    procedure btnUDPClick(Sender: TObject);
    procedure btnDownloadsClick(Sender: TObject);
    procedure btnGeneralClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGateway2Click(Sender: TObject);
    procedure btnUploadsClick(Sender: TObject);
  private
    { Private declarations }
    CurrentForm: TfrmSettingsBase;
    procedure ShowSelectedButton(Button: TButton);
    procedure LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
  public
    { Public declarations }
    procedure LoadForm; override;
    procedure LoadPage(PageIndex: Integer);
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.fmx}

uses Main, GPSSettings, LoRaGatewaySettings, LoRaGatewaySettings2, DownloadSettings, LoRaSerialSettings, UDPSettings, LoRaBluetoothSettings, UploadSettings;

procedure TfrmSettings.LoadSettingsForm(Button: TButton; NewForm: TfrmSettingsBase);
begin
    ShowSelectedButton(Button);

    if CurrentForm <> nil then begin
        CurrentForm.pnlMain.Parent := CurrentForm;
        CurrentForm.HideForm;
        CurrentForm.Free;
    end;

    NewForm.pnlMain.Parent := pnlMain;
    CurrentForm := NewForm;
    NewForm.LoadForm;
end;

procedure TfrmSettings.btnGateway1Click(Sender: TObject);
begin
    frmLoRaGatewaySettings := TfrmLoRaGatewaySettings.Create(Self);

    LoadSettingsForm(btnGateway1, frmLoRaGatewaySettings);
end;

procedure TfrmSettings.btnGateway2Click(Sender: TObject);
begin
    frmLoRaGatewaySettings2 := TfrmLoRaGatewaySettings2.Create(Self);

    LoadSettingsForm(btnGateway2, frmLoRaGatewaySettings2);
end;

procedure TfrmSettings.btnGeneralClick(Sender: TObject);
begin
    frmGeneralSettings := TfrmGeneralSettings.Create(Self);

    LoadSettingsForm(btnGeneral, frmGeneralSettings);
end;

procedure TfrmSettings.btnGPSClick(Sender: TObject);
begin
    frmGPSSettings := TfrmGPSSettings.Create(Self);

    LoadSettingsForm(btnGPS, frmGPSSettings);
end;

procedure TfrmSettings.btnDownloadsClick(Sender: TObject);
begin
    frmDownloadSettings := TfrmDownloadSettings.Create(Self);

    LoadSettingsForm(btnDownloads, frmDownloadSettings);
end;

procedure TfrmSettings.btnLoRaSerialClick(Sender: TObject);
begin
    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
        frmLoRaSerialSettings := TfrmLoRaSerialSettings.Create(Self);
        LoadSettingsForm(btnLoRaSerial, frmLoRaSerialSettings);
    {$ENDIF}
end;

procedure TfrmSettings.btnUDPClick(Sender: TObject);
begin
    frmUDPSettings := TfrmUDPSettings.Create(Self);

    LoadSettingsForm(btnUDP, frmUDPSettings);
end;

procedure TfrmSettings.btnUploadsClick(Sender: TObject);
begin
    frmUploadSettings := TfrmUploadSettings.Create(Self);

    LoadSettingsForm(btnUploads, frmUploadSettings);
end;

procedure TfrmSettings.btnLoRaBTClick(Sender: TObject);
begin
    frmBluetoothSettings := TfrmBluetoothSettings.Create(Self);

    LoadSettingsForm(btnLoRaBT, frmBluetoothSettings);
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
    inherited;

    {$IF Defined(MSWINDOWS) or Defined(ANDROID)}
    {$ELSE}
        btnLoRaSerial.Text := '';
        btnLoRaBT.Text := 'BLE';
    {$ENDIF}
end;

procedure TfrmSettings.LoadForm;
begin
    inherited;

//    frmGeneralSettings := TfrmGeneralSettings.Create(Self);
//
//    LoadSettingsForm(btnGeneral, frmGeneralSettings);
//
//    Application.ProcessMessages;

    btnGeneral.Font.Size := btnGeneral.Size.Height * 0.8;
    btnGPS.Font.Size := btnGeneral.Size.Height * 0.8;
    btnGateway1.Font.Size := btnGeneral.Size.Height * 0.8;
    btnGateway2.Font.Size := btnGeneral.Size.Height * 0.8;
    btnLoRaSerial.Font.Size := btnGeneral.Size.Height * 0.8;
    btnLoRaBT.Font.Size := btnGeneral.Size.Height * 0.8;
    btnUDP.Font.Size := btnGeneral.Size.Height * 0.8;
    btnDownloads.Font.Size := btnGeneral.Size.Height * 0.8;
    btnUploads.Font.Size := btnGeneral.Size.Height * 0.8;
end;

procedure TfrmSettings.ShowSelectedButton(Button: TButton);
begin
    btnGeneral.TextSettings.Font.Style := btnGeneral.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGPS.TextSettings.Font.Style := btnGPS.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnLoRaSerial.TextSettings.Font.Style := btnLoRaSerial.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnDownloads.TextSettings.Font.Style := btnDownloads.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnLoRaBT.TextSettings.Font.Style := btnLoRaBT.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnUDP.TextSettings.Font.Style := btnUDP.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGateway1.TextSettings.Font.Style := btnGateway1.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnGateway2.TextSettings.Font.Style := btnGateway2.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnUploads.TextSettings.Font.Style := btnUploads.TextSettings.Font.Style - [TFontStyle.fsUnderline];

    Button.TextSettings.Font.Style := Button.TextSettings.Font.Style + [TFontStyle.fsUnderline];
end;

procedure TfrmSettings.LoadPage(PageIndex: Integer);
begin
    case PageIndex of
        0:  btnGeneralClick(nil);
        1:  btnGPSClick(nil);
        2:  btnGateway1Click(nil);
        3:  btnGateway2Click(nil);
        4:  btnLoRaSerialClick(nil);
        5:  btnLoRaBTClick(nil);
        6:  btnUDPClick(nil);
        7:  btnDownloadsClick(nil);
        8:  btnUploadsClick(nil);
    end;
end;

end.
