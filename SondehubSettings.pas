unit SondehubSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  Miscellaneous, FMX.TMSCustomEdit, FMX.TMSEdit, FMX.Memo.Types;

type
  TfrmSondehubSettings = class(TfrmSettingsBase)
    ChkEnable: TLabel;
    Label1: TLabel;
    edtWhiteList: TTMSFMXEdit;
    procedure FormCreate(Sender: TObject);
    procedure ChkEnableClick(Sender: TObject);
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
  frmSondehubSettings: TfrmSondehubSettings;

implementation

{$R *.fmx}

procedure TfrmSondehubSettings.ApplyChanges;
begin
    SetSettingBoolean(Group, 'Enabled', LCARSLabelIsChecked(chkEnable));
    SetSettingString(Group, 'WhiteList', edtWhiteList.Text);

    inherited;
end;

procedure TfrmSondehubSettings.CancelChanges;
begin
    inherited;

    CheckLCARSLabel(chkEnable, GetSettingBoolean(Group, 'Enabled', False));
    edtWhiteList.Text := GetSettingString(Group, 'WhiteList', '');
end;

procedure TfrmSondehubSettings.ChkEnableClick(Sender: TObject);
begin
    SetingsHaveChanged;
    LCARSLabelClick(Sender);
end;

procedure TfrmSondehubSettings.edtWhiteListKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
    SetingsHaveChanged;
end;

procedure TfrmSondehubSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'Sondehub';
end;

end.
