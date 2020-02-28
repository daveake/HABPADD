unit DLFLDIGISettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmDLFLDIGISettings = class(TfrmSettingsBase)
    Label1: TLabel;
    edtPort: TTMSFMXEdit;
    procedure FormCreate(Sender: TObject);
    procedure edtPortChangeTracking(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    { Public declarations }
  end;

var
  frmDLFLDIGISettings: TfrmDLFLDIGISettings;

implementation

{$R *.fmx}

procedure TfrmDLFLDIGISettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);

    inherited;
end;

procedure TfrmDLFLDIGISettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');
end;

procedure TfrmDLFLDIGISettings.edtPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmDLFLDIGISettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'RTTY';
end;

end.
