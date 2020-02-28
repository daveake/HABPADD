unit LoRaSerialSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  Math, FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmLoRaSerialSettings = class(TfrmSettingsBase)
    Label2: TLabel;
    edtFrequency: TTMSFMXEdit;
    Label3: TLabel;
    btnModeDown: TLabel;
    edtMode: TTMSFMXEdit;
    btnModeUp: TLabel;
    chkHabitat: TLabel;
    chkSSDV: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkUploadClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtPortChangeTracking(Sender: TObject);
    procedure btnModeDownClick(Sender: TObject);
    procedure btnModeUpClick(Sender: TObject);
    procedure chkHabitatClick(Sender: TObject);
  private
    { Private declarations }
    procedure SendSettingsToDevice;
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    { Public declarations }
  end;

var
  frmLoRaSerialSettings: TfrmLoRaSerialSettings;

implementation

{$R *.fmx}

uses SourcesForm;

procedure TfrmLoRaSerialSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Frequency', edtFrequency.Text);
    SetSettingString(Group, 'Mode', edtMode.Text);

    SetSettingBoolean(Group, 'Habitat', LCARSLabelIsChecked(chkHabitat));
    SetSettingBoolean(Group, 'SSDV', LCARSLabelIsChecked(chkSSDV));

    inherited;

    SendSettingsToDevice;
end;

procedure TfrmLoRaSerialSettings.btnApplyClick(Sender: TObject);
begin
    inherited;
    //
end;

procedure TfrmLoRaSerialSettings.btnCancelClick(Sender: TObject);
begin
    inherited;
    //
end;

procedure TfrmLoRaSerialSettings.btnModeDownClick(Sender: TObject);
begin
    edtMode.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode.Text, 0)-1)));
end;

procedure TfrmLoRaSerialSettings.btnModeUpClick(Sender: TObject);
begin
    edtMode.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode.Text, 0)+1)));
end;

procedure TfrmLoRaSerialSettings.CancelChanges;
begin
    inherited;

    edtFrequency.Text := GetSettingString(Group, 'Frequency', '');
    edtMode.Text := GetSettingString(Group, 'Mode', '');
    CheckLCARSLabel(chkHabitat, GetSettingBoolean(Group, 'Habitat', False));
    CheckLCARSLabel(chkSSDV, GetSettingBoolean(Group, 'SSDV', False));
end;

procedure TfrmLoRaSerialSettings.SendSettingsToDevice;
begin
    frmSources.SendParameterToSource(SERIAL_SOURCE, 'F', edtFrequency.Text);
    frmSources.SendParameterToSource(SERIAL_SOURCE, 'M', edtMode.Text);
end;

procedure TfrmLoRaSerialSettings.chkHabitatClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmLoRaSerialSettings.chkUploadClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmLoRaSerialSettings.edtPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmLoRaSerialSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'LoRaSerial';
end;

end.
