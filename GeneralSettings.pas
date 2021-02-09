unit GeneralSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmGeneralSettings = class(TfrmSettingsBase)
    Label3: TLabel;
    edtCallsign: TTMSFMXEdit;
    chkPositionBeeps: TLabel;
    chkAlarmBeeps: TLabel;
    chkSpeech: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkSettingsClick(Sender: TObject);
    procedure edtCallsignChangeTracking(Sender: TObject);
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
  frmGeneralSettings: TfrmGeneralSettings;

implementation

{$R *.fmx}

procedure TfrmGeneralSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'General';
end;

procedure TfrmGeneralSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Callsign', edtCallsign.Text);

    SetSettingBoolean(Group, 'PositionBeeps', LCARSLabelIsChecked(chkPositionBeeps));
    SetSettingBoolean(Group, 'AlarmBeeps', LCARSLabelIsChecked(chkAlarmBeeps));
    SetSettingBoolean(Group, 'Speech', LCARSLabelIsChecked(chkSpeech));
    // SetSettingBoolean(Group, 'Tweet', LCARSLabelIsChecked(chkTweet));

    inherited;
end;

procedure TfrmGeneralSettings.CancelChanges;
begin
    inherited;

    edtCallsign.Text := GetSettingString(Group, 'Callsign', '');

    CheckLCARSLabel(chkPositionBeeps, GetSettingBoolean(Group, 'PositionBeeps', False));
    CheckLCARSLabel(chkAlarmBeeps, GetSettingBoolean(Group, 'AlarmBeeps', False));
    CheckLCARSLabel(chkSpeech, GetSettingBoolean(Group, 'Speech', False));
    // CheckLCARSLabel(chkTweet, GetSettingBoolean(Group, 'Tweet', False));

    inherited;
end;

procedure TfrmGeneralSettings.chkSettingsClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmGeneralSettings.edtCallsignChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmGeneralSettings.LoadForm;
begin
    inherited;

    Label3.Font.Size := Label3.Size.Height * 0.5;
    // chkTweet.Font.Size := chkTweet.Size.Height * 18/42;
    chkPositionBeeps.Font.Size := chkPositionBeeps.Size.Height * 18/42;
    chkAlarmBeeps.Font.Size := chkAlarmBeeps.Size.Height * 18/42;
    chkSpeech.Font.Size := chkSpeech.Size.Height * 18/42;
end;

end.
