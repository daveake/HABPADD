unit GPSSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.TMSCustomEdit, FMX.TMSEdit, FMX.Objects, Miscellaneous,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Memo.Types;

type
  TfrmGPSSettings = class(TfrmSettingsBase)
    Label1: TLabel;
    edtPort: TTMSFMXEdit;
    Label2: TLabel;
    edtPeriod: TTMSFMXEdit;
    Label3: TLabel;
    edtCallsign: TTMSFMXEdit;
    chkUpload: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkSettingsClick(Sender: TObject);
    procedure edtPortChangeTracking(Sender: TObject);
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
  frmGPSSettings: TfrmGPSSettings;

implementation

uses Main;

{$R *.fmx}

procedure TfrmGPSSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'GPS';
{$IF Defined(IOS) or Defined(ANDROID)}
    Label1.Visible := False;
    edtPort.Visible := False;
{$ENDIF}
end;

procedure TfrmGPSSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);

    inherited;

    SetSettingString('CHASE', 'Callsign', edtCallsign.Text);
    SetSettingBoolean('CHASE', 'Upload', LCARSLabelIsChecked(chkUpload));
    SetSettingInteger('CHASE', 'Period', edtPeriod.Text.ToInteger);

    frmMain.UpdateCarUploadSettings;
end;

procedure TfrmGPSSettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');

    edtCallsign.Text := GetSettingString('CHASE', 'Callsign', '');
    CheckLCARSLabel(chkUpload, GetSettingBoolean('CHASE', 'Upload', False));
    edtPeriod.Text := GetSettingInteger('CHASE', 'Period', 0).ToString;

    inherited;
end;

procedure TfrmGPSSettings.chkSettingsClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmGPSSettings.edtPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmGPSSettings.LoadForm;
begin
    inherited;

    Label1.Font.Size := Label1.Size.Height * 0.5;
    Label2.Font.Size := Label2.Size.Height * 0.5;
    Label3.Font.Size := Label3.Size.Height * 0.5;

    chkUpload.Font.Size := chkUpload.Size.Height * 18/42;
end;


end.
