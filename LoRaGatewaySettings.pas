unit LoRaGatewaySettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Math, Miscellaneous, Source, SourcesForm,
  FMX.Memo.Types;

type
  TfrmLoRaGatewaySettings = class(TfrmSettingsBase)
    Label1: TLabel;
    edtHost: TTMSFMXEdit;
    Label3: TLabel;
    edtPort: TTMSFMXEdit;
    Label2: TLabel;
    edtFrequency1: TTMSFMXEdit;
    Label4: TLabel;
    btnModeDown: TLabel;
    edtMode1: TTMSFMXEdit;
    btnModeUp: TLabel;
    Label5: TLabel;
    edtFrequency2: TTMSFMXEdit;
    Label6: TLabel;
    Label7: TLabel;
    edtMode2: TTMSFMXEdit;
    Label8: TLabel;
    chkAFC1: TLabel;
    chkAFC2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure edtHostChangeTracking(Sender: TObject);
    procedure btnModeDownClick(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure btnModeUpClick(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure chkAFC1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    SourceIndex: Integer;
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    { Public declarations }
  end;

var
  frmLoRaGatewaySettings: TfrmLoRaGatewaySettings;

implementation

{$R *.fmx}

uses Main;

procedure TfrmLoRaGatewaySettings.ApplyChanges;
begin
    SetSettingString(Group, 'Host', edtHost.Text);
    SetSettingInteger(Group, 'Port', StrToIntDef(edtPort.Text, 0));

    SetSettingString(Group, 'Frequency_0', edtFrequency1.Text);
    SetSettingInteger(Group, 'Mode_0', StrToIntDef(edtMode1.Text, 0));
    SetSettingBoolean(Group, 'AFC_0', LCARSLabelIsChecked(chkAFC1));

    SetSettingString(Group, 'Frequency_1', edtFrequency2.Text);
    SetSettingInteger(Group, 'Mode_1', StrToIntDef(edtMode2.Text, 0));
    SetSettingBoolean(Group, 'AFC_1', LCARSLabelIsChecked(chkAFC2));

    inherited;
end;

procedure TfrmLoRaGatewaySettings.btnModeDownClick(Sender: TObject);
begin
    edtMode1.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode1.Text, 0)-1)));
end;

procedure TfrmLoRaGatewaySettings.btnModeUpClick(Sender: TObject);
begin
    edtMode1.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode1.Text, 0)+1)));
end;

procedure TfrmLoRaGatewaySettings.CancelChanges;
begin
    edtHost.Text := GetSettingString(Group, 'Host', '');
    edtPort.Text := GetSettingInteger(Group, 'Port', 0).ToString;

    edtFrequency1.Text := GetSettingString(Group, 'Frequency_0', '');
    edtMode1.Text := GetSettingString(Group, 'Mode_0', '');
    CheckLCARSLabel(chkAFC1, GetSettingBoolean(Group, 'AFC_0', False));

    edtFrequency2.Text := GetSettingString(Group, 'Frequency_1', '');
    edtMode2.Text := GetSettingString(Group, 'Mode_1', '');
    CheckLCARSLabel(chkAFC2, GetSettingBoolean(Group, 'AFC_1', False));

    inherited;
end;

procedure TfrmLoRaGatewaySettings.chkAFC1Click(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmLoRaGatewaySettings.edtHostChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmLoRaGatewaySettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'LoRaGateway1';
    SourceIndex := GATEWAY_SOURCE_1;
end;

procedure TfrmLoRaGatewaySettings.Label7Click(Sender: TObject);
begin
    edtMode2.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode2.Text, 0)-1)));
end;

procedure TfrmLoRaGatewaySettings.Label8Click(Sender: TObject);
begin
    edtMode2.Text := IntToStr(Max(0,Min(7,StrToIntDef(edtMode2.Text, 0)+1)));
end;


end.
