unit UploadSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.Controls.Presentation, FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmUploadSettings = class(TfrmSettingsBase)
    Label3: TLabel;
    edtBroker: TTMSFMXEdit;
    edtUser: TTMSFMXEdit;
    edtPassword: TTMSFMXEdit;
    Label6: TLabel;
    edtTopic: TTMSFMXEdit;
    Label7: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    edtChaseTopic: TTMSFMXEdit;
    chkSondehub: TLabel;
    chkMQTT: TLabel;
    chkHABLINK: TLabel;
    chkSSDV: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkHabitatClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure edtBrokerChangeTracking(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    { Public declarations }
    procedure LoadForm; override;
  end;

var
  frmUploadSettings: TfrmUploadSettings;

implementation

uses Main;

{$R *.fmx}

procedure TfrmUploadSettings.chkHabitatClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmUploadSettings.edtBrokerChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmUploadSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'Upload';
end;

procedure TfrmUploadSettings.ApplyChanges;
begin
    SetSettingString(Group, 'MQTTBroker', edtBroker.Text);
    SetSettingString(Group, 'MQTTUserName', edtUser.Text);
    SetSettingString(Group, 'MQTTPassword', edtPassword.Text);
    SetSettingString(Group, 'MQTTTopic', edtTopic.Text);
    SetSettingString(Group, 'MQTTChaseTopic', edtChaseTopic.Text);

    SetSettingBoolean(Group, 'HABLINK', LCARSLabelIsChecked(chkHABLINK));
    SetSettingBoolean(Group, 'MQTT', LCARSLabelIsChecked(chkMQTT));
    SetSettingBoolean(Group, 'SSDV', LCARSLabelIsChecked(chkSSDV));
    SetSettingBoolean(Group, 'Sondehub', LCARSLabelIsChecked(chkSondehub));


    inherited;
end;

procedure TfrmUploadSettings.btnApplyClick(Sender: TObject);
begin
    inherited;

    frmMain.UpdateAllUploadStatus;
end;

procedure TfrmUploadSettings.CancelChanges;
begin
    inherited;

    edtBroker.Text := GetSettingString(Group, 'MQTTBroker', '');
    edtUser.Text := GetSettingString(Group, 'MQTTUserName', '');
    edtPassword.Text := GetSettingString(Group, 'MQTTPassword', '');
    edtTopic.Text := GetSettingString(Group, 'MQTTTopic', 'incoming/payloads/$PAYLOAD$/$LISTENER$/sentence');
    edtChaseTopic.Text := GetSettingString(Group, 'MQTTChaseTopic', 'incoming/chase/$CALLSIGN$/position');

    CheckLCARSLabel(chkHABLINK, GetSettingBoolean(Group, 'HABLINK', False));
    CheckLCARSLabel(chkMQTT, GetSettingBoolean(Group, 'MQTT', False));
    CheckLCARSLabel(chkSSDV, GetSettingBoolean(Group, 'SSDV', False));
    CheckLCARSLabel(chkSondehub, GetSettingBoolean(Group, 'Sondehub', False));

    inherited;
end;


procedure TfrmUploadSettings.LoadForm;
begin
    inherited;

    Label3.Font.Size := Label3.Size.Height * 0.5;
    // chkTweet.Font.Size := chkTweet.Size.Height * 18/42;
//    chkPositionBeeps.Font.Size := chkPositionBeeps.Size.Height * 18/42;
//    chkAlarmBeeps.Font.Size := chkAlarmBeeps.Size.Height * 18/42;
//    chkSpeech.Font.Size := chkSpeech.Size.Height * 18/42;
end;


end.
