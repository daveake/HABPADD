unit HabitatSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  Miscellaneous, FMX.TMSCustomEdit, FMX.TMSEdit;

type
  TfrmHabitatSettings = class(TfrmSettingsBase)
    ChkEnable: TLabel;
    Label1: TLabel;
    edtWhiteList: TTMSFMXEdit;
    procedure FormCreate(Sender: TObject);
    procedure ChkEnableClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  end;

var
  frmHabitatSettings: TfrmHabitatSettings;

implementation

{$R *.fmx}

procedure TfrmHabitatSettings.ApplyChanges;
begin
    SetSettingBoolean(Group, 'Enable', LCARSLabelIsChecked(chkEnable));
    SetSettingString(Group, 'WhiteList', edtWhiteList.Text);

    inherited;
end;

procedure TfrmHabitatSettings.CancelChanges;
begin
    inherited;

    CheckLCARSLabel(chkEnable, GetSettingBoolean(Group, 'Enable', False));
    edtWhiteList.Text := GetSettingString(Group, 'WhiteList', '');
end;

procedure TfrmHabitatSettings.ChkEnableClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmHabitatSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'Habitat';
end;

end.
