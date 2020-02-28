unit Debug;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation;

type
  TfrmDebug = class(TfrmBase)
    lstDebug: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Debug(Msg: String);
  end;

var
  frmDebug: TfrmDebug;

implementation

{$R *.fmx}

procedure TfrmDebug.Debug(Msg: String);
begin
    with lstDebug do begin
        if Items.Count > 50 then begin
            Items.Delete(0);
        end;

        ItemIndex := Items.Add(FormatDateTime('hh:nn:ss', Now) + ': ' + Msg);
    end;
end;

end.
