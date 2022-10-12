unit DownloadSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  Miscellaneous, FMX.TMSCustomEdit, FMX.TMSEdit, FMX.Memo.Types;

type
  TfrmDownloadSettings = class(TfrmSettingsBase)
    chkEnableSondehub: TLabel;
    Label1: TLabel;
    edtWhiteList: TTMSFMXEdit;
    chkEnableHABHUB: TLabel;
    chkEnableHABLINK: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkEnableSondehubClick(Sender: TObject);
    procedure edtWhiteListKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  end;

var
  frmDownloadSettings: TfrmDownloadSettings;

implementation

{$R *.fmx}

procedure TfrmDownloadSettings.ApplyChanges;
begin
    SetSettingBoolean('Habitat', 'Enabled', LCARSLabelIsChecked(chkEnableHABHUB));

    SetSettingBoolean(Group, 'SONDEHUB', LCARSLabelIsChecked(chkEnableSondehub));
    SetSettingBoolean(Group, 'HABLINK', LCARSLabelIsChecked(chkEnableHABLINK));

    SetSettingString('Habitat', 'WhiteList', edtWhiteList.Text);
    SetSettingString('Sondehub', 'WhiteList', edtWhiteList.Text);
    SetSettingString('HabLink', 'WhiteList', edtWhiteList.Text);

    inherited;
end;

procedure TfrmDownloadSettings.CancelChanges;
begin
    inherited;

    CheckLCARSLabel(chkEnableHABHUB, GetSettingBoolean('Habitat', 'Enabled', False));

    CheckLCARSLabel(chkEnableSondehub, GetSettingBoolean(Group, 'SONDEHUB', False));
    CheckLCARSLabel(chkEnableHABLINK, GetSettingBoolean(Group, 'HABLINK', False));

    edtWhiteList.Text := GetSettingString('Habitat', 'WhiteList', '');
end;

procedure TfrmDownloadSettings.chkEnableSondehubClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmDownloadSettings.edtWhiteListKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
    SetingsHaveChanged;
end;

procedure TfrmDownloadSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'Downloads';
end;

end.
