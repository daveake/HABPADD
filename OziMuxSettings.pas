unit OziMuxSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  SettingsBase, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Controls.Presentation,
  FMX.TMSCustomEdit, FMX.TMSEdit, Miscellaneous;

type
  TfrmOziMuxSettings = class(TfrmSettingsBase)
    Label1: TLabel;
    edtPort: TTMSFMXEdit;
    Label3: TLabel;
    edtPayloadID: TTMSFMXEdit;
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
  frmOziMuxSettings: TfrmOziMuxSettings;

implementation

{$R *.fmx}

procedure TfrmOziMuxSettings.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'OziMux';
end;

procedure TfrmOziMuxSettings.ApplyChanges;
begin
    SetSettingString(Group, 'Port', edtPort.Text);
    SetSettingString(Group, 'PayloadID', edtPayloadID.Text);

    inherited;
end;

procedure TfrmOziMuxSettings.CancelChanges;
begin
    inherited;

    edtPort.Text := GetSettingString(Group, 'Port', '');
    edtPayloadID.Text := GetSettingString(Group, 'PayloadID', 'OZIMUX');
end;


procedure TfrmOziMuxSettings.edtPortChangeTracking(Sender: TObject);
begin
    SetingsHaveChanged;
end;

procedure TfrmOziMuxSettings.LoadForm;
begin
    inherited;

    Label1.Font.Size := Label1.Size.Height * 0.5;
    Label3.Font.Size := Label3.Size.Height * 0.5;
end;

end.
