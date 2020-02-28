unit Base;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, Math,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo, FMX.TMSCustomEdit, FMX.TMSEdit;

type
  TfrmBase = class(TForm)
    pnlMain: TPanel;
    procedure pnlMainResized(Sender: TObject);
  private
    { Private declarations }
    Resized: Boolean;
    procedure ResizeFonts;
  public
    { Public declarations }
    procedure LCARSLabelClick(Sender: TObject);
    procedure CheckLCARSLabel(Sender: TObject; Checked: Boolean);
    function LCARSLabelIsChecked(Sender: TObject): Boolean;

    procedure LoadForm; virtual;
    procedure HideForm; virtual;
  end;

var
  frmBase: TfrmBase;

implementation

{$R *.fmx}

uses Main, Debug;

procedure TfrmBase.LoadForm;
begin
    // virtual
end;

procedure TfrmBase.pnlMainResized(Sender: TObject);
begin
    ResizeFonts;
end;

procedure TfrmBase.HideForm;
begin
    pnlMain.Parent := Self;
end;

procedure TfrmBase.LCARSLabelClick(Sender: TObject);
begin
    CheckLCARSLabel(Sender, not LCARSLabelIsChecked(Sender));
end;

procedure TfrmBase.CheckLCARSLabel(Sender: TObject; Checked: Boolean);
var
    Rectangle: TRoundRect;
begin
    Rectangle := TRoundRect(TLabel(Sender).FindStyleResource('rectangle'));

    if Rectangle <> nil then begin
        if Checked then begin
            Rectangle.Stroke.Color := TAlphaColorRec.Yellow;
            TLabel(Sender).Tag := 1;
        end else begin
            Rectangle.Stroke.Color := TAlphaColorRec.Silver;
            TLabel(Sender).Tag := 0;
        end;
    end;
end;

function TfrmBase.LCARSLabelIsChecked(Sender: TObject): Boolean;
begin
    Result := TLabel(Sender).Tag <> 0;
end;

procedure TfrmBase.ResizeFonts;
var
    i: Integer;
    Component: TComponent;
begin
    if (frmMain.FontScaling > 0) and not Resized then begin
        Resized := True;
        for i := 0 to ComponentCount-1 do begin
            Component := Components[i];

            if Component is TLabel then begin
                TLabel(Component).TextSettings.Font.Size := TLabel(Component).TextSettings.Font.Size * frmMain.FontScaling;
            end else if Component is TButton then begin
                TButton(Component).TextSettings.Font.Size := TButton(Component).TextSettings.Font.Size * frmMain.FontScaling;
            end else if Component is TMemo then begin
                TMemo(Component).TextSettings.Font.Size := TMemo(Component).TextSettings.Font.Size * frmMain.FontScaling;
            end else if Component is TTMSFMXEdit then begin
                TTMSFMXEdit(Component).TextSettings.Font.Size := TTMSFMXEdit(Component).TextSettings.Font.Size * frmMain.FontScaling;
            end;
        end;
    end;
end;

end.
