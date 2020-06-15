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
    edtUDPRxPort: TTMSFMXEdit;
    Label2: TLabel;
    edtUDPTxPort: TTMSFMXEdit;
    procedure FormCreate(Sender: TObject);
    procedure edtUDPRxPortChangeTracking(Sender: TObject);
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
    Group := 'General';
end;

procedure TfrmUDPSettings.ApplyChanges;
begin
    SetSettingInteger(Group, 'UDPTxPort', StrToIntDef(edtUDPTxPort.Text, 0));
    SetSettingString('UDP', 'Port', edtUDPRxPort.Text);

    inherited;
end;

procedure TfrmUDPSettings.CancelChanges;
begin
    inherited;

    edtUDPTxPort.Text := IntToStr(GetSettingInteger(Group, 'UDPTxPort', 0));

    edtUDPRxPort.Text := GetSettingString('UDP', 'Port', '');
end;


procedure TfrmUDPSettings.edtUDPRxPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmUDPSettings.LoadForm;
begin
    inherited;

    Label1.Font.Size := Label1.Size.Height * 0.5;
end;

end.
