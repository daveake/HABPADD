unit LoRaBluetoothSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous, System.Bluetooth,  Math,
  System.Bluetooth.Components, FMX.ListBox;

type
  TfrmBluetoothSettings = class(TfrmSettingsBase)
    cmbDevices: TComboBox;
    edtDevice: TTMSFMXEdit;
    edtFrequency: TTMSFMXEdit;
    Label2: TLabel;
    Label3: TLabel;
    btnModeDown: TLabel;
    edtMode: TTMSFMXEdit;
    btnModeUp: TLabel;
    Label1: TLabel;
    BluetoothLE1: TBluetoothLE;
    procedure FormCreate(Sender: TObject);
    procedure edtDeviceClick(Sender: TObject);
    procedure cmbDevicesClosePopup(Sender: TObject);
    procedure btnModeDownClick(Sender: TObject);
    procedure btnModeUpClick(Sender: TObject);
    procedure edtModeChangeTracking(Sender: TObject);
    procedure BluetoothLE1DiscoverLEDevice(const Sender: TObject;
      const ADevice: TBluetoothLEDevice; Rssi: Integer;
      const ScanResponse: TScanResponse);
  private
    { Private declarations }
    procedure UpdateBluetoothList;
    procedure SendSettingsToDevice;
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    { Public declarations }
    procedure LoadForm; override;
  end;

var
  frmBluetoothSettings: TfrmBluetoothSettings;

implementation

{$R *.fmx}

uses SourcesForm;

procedure TfrmBluetoothSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Device', edtDevice.Text);

    SetSettingString(Group, 'Frequency', edtFrequency.Text);
    SetSettingString(Group, 'Mode', edtMode.Text);

    inherited;

    SendSettingsToDevice;
end;

procedure TfrmBluetoothSettings.BluetoothLE1DiscoverLEDevice(
  const Sender: TObject; const ADevice: TBluetoothLEDevice; Rssi: Integer;
  const ScanResponse: TScanResponse);
var
    i, Index: Integer;
    DeviceName: String;
begin
    for i := 0 to BluetoothLE1.DiscoveredDevices.Count-1 do begin
        DeviceName := BluetoothLE1.DiscoveredDevices.Items[i].DeviceName;
        Index := cmbDevices.Items.IndexOf(DeviceName);
        if Index < 0 then begin
            Index := cmbDevices.Items.Add(DeviceName);
        end;

        cmbDevices.ItemIndex := cmbDevices.Items.IndexOf(edtDevice.Text);
    end;
end;

procedure TfrmBluetoothSettings.btnModeDownClick(Sender: TObject);
begin
    edtMode.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode.Text, 0)-1)));
end;

procedure TfrmBluetoothSettings.btnModeUpClick(Sender: TObject);
begin
    edtMode.Text := IntToStr(Min(7,Max(0,StrToIntDef(edtMode.Text, 0)+1)));
end;

procedure TfrmBluetoothSettings.CancelChanges;
begin
    inherited;

    edtDevice.Text := GetSettingString(Group, 'Device', '');

    edtFrequency.Text := GetSettingString(Group, 'Frequency', '');
    edtMode.Text := GetSettingString(Group, 'Mode', '');
end;

procedure TfrmBluetoothSettings.SendSettingsToDevice;
begin
    frmSources.SendParameterToSource(BLUETOOTH_SOURCE, 'F', edtFrequency.Text);
    frmSources.SendParameterToSource(BLUETOOTH_SOURCE, 'M', edtMode.Text);
end;

procedure TfrmBluetoothSettings.cmbDevicesClosePopup(Sender: TObject);
begin
    if cmbDevices.ItemIndex >= 0 then begin
        if edtDevice.Text <> cmbDevices.Items[cmbDevices.ItemIndex] then begin
            edtDevice.Text := cmbDevices.Items[cmbDevices.ItemIndex];
            SetingsHaveChanged;
        end;
    end;
end;

procedure TfrmBluetoothSettings.edtDeviceClick(Sender: TObject);
begin
    cmbDevices.DropDown;
end;

procedure TfrmBluetoothSettings.edtModeChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmBluetoothSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'LoRaBluetooth';
end;

procedure TfrmBluetoothSettings.LoadForm;
begin
    inherited;
    UpdateBluetoothList;
end;

procedure TfrmBluetoothSettings.UpdateBluetoothList;
var
    i: Integer;
{$IF Defined(MSWINDOWS) or Defined(ANDROID)}
    Bluetooth1: TBluetooth;
{$ENDIF}
begin
    cmbDevices.Items.Clear;

{$IF Defined(MSWINDOWS) or Defined(ANDROID)}
    try
        Bluetooth1 := TBluetooth.Create(nil);
        Bluetooth1.Enabled := True;

        if Bluetooth1.LastPairedDevices <> nil then begin
            for i := 0 to Bluetooth1.LastPairedDevices.Count-1 do begin
                // cmbDevices.Items.Add(IntToStr(Ord(Bluetooth1.LastPairedDevices[i].State)) + ': ' + Bluetooth1.LastPairedDevices[i].DeviceName + ' - ' + Bluetooth1.LastPairedDevices[i].Address);
                cmbDevices.Items.Add(Bluetooth1.LastPairedDevices[i].DeviceName);
            end;
        end;
        Bluetooth1.Free;
    finally
    end;
{$ELSE}
    BluetoothLE1.Enabled := True;
    BluetoothLE1.DiscoverDevices(5000);
{$ENDIF}

    cmbDevices.ItemIndex := cmbDevices.Items.IndexOf(edtDevice.Text);
end;

end.
