unit UDPSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmUDPSettings = class(TfrmSettingsBase)
    Label1: TLabel;
    edtPort: TTMSFMXEdit;
    procedure FormCreate(Sender: TObject);
    procedure edtPortChangeTracking(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure ApplyChanges; override;
    procedure CancelChanges; override;
  public
    procedure LoadForm; override;
  end;

var
  frmUDPSettings: TfrmUDPSettings;

implementation

{$R *.fmx}

procedure TfrmUDPSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'UDP';
end;

procedure TfrmUDPSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);

    inherited;
end;

procedure TfrmUDPSettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');
end;


procedure TfrmUDPSettings.edtPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmUDPSettings.LoadForm;
begin
    inherited;

    Label1.Font.Size := Label1.Size.Height * 0.5;
end;

end.
