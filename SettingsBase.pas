unit SettingsBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  Miscellaneous;

type
  TfrmSettingsBase = class(TfrmBase)
    Panel1: TPanel;
    Rectangle3: TRectangle;
    Panel3: TPanel;
    Rectangle1: TRectangle;
    Memo1: TMemo;
    Panel2: TPanel;
    btnApply: TButton;
    btnCancel: TButton;
    tmrLoadSettings: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure tmrLoadSettingsTimer(Sender: TObject);
  private
    { Private declarations }
  protected
    Loading: Boolean;
    Group: String;
    procedure ApplyChanges; virtual;
    procedure CancelChanges; virtual;
    procedure SetingsHaveChanged;
  public
    { Public declarations }
    procedure LoadForm; override;
  end;

implementation

{$R *.fmx}

uses Main;

procedure TfrmSettingsBase.btnApplyClick(Sender: TObject);
begin
    ApplyChanges;
end;

procedure TfrmSettingsBase.btnCancelClick(Sender: TObject);
begin
    CancelChanges;
end;

procedure TfrmSettingsBase.ApplyChanges;
begin
    SetGroupChangedFlag(Group, True);
    btnApply.Enabled := False;
    btnCancel.Enabled := False;
end;

procedure TfrmSettingsBase.CancelChanges;
begin
    btnApply.Enabled := False;
    btnCancel.Enabled := False;
end;

procedure TfrmSettingsBase.LoadForm;
begin
    Loading := True;

    inherited;

    tmrLoadSettings.Enabled := True;

    Loading := False;
end;

procedure TfrmSettingsBase.Rectangle1Click(Sender: TObject);
begin
    btnCancel.SetFocus;
end;

procedure TfrmSettingsBase.SetingsHaveChanged;
begin
    if not Loading then begin
        btnApply.Enabled := True;
        btnCancel.Enabled := True;
    end;
end;


procedure TfrmSettingsBase.tmrLoadSettingsTimer(Sender: TObject);
begin
    tmrLoadSettings.Enabled := False;

    CancelChanges;
end;

end.
