unit SourceLog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, FMX.Objects,
  FMX.Platform, FMX.Clipboard;

type
  TfrmSourceLog = class(TfrmBase)
    rectMain: TRectangle;
    Rectangle5: TRectangle;
    lblCaption: TLabel;
    lblClipboard: TLabel;
    lstLog: TListBox;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure lstLogMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure lblClipboardClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    procedure ShowSuccess(ALabel: TLabel);
  public
    { Public declarations }
    procedure WriteToLog(Msg: String);
  end;

var
  frmSourceLog: TfrmSourceLog;

implementation

{$R *.fmx}

procedure CopyListBoxTextToClipboard(ListBox: TListBox);
var
    I: Integer;
    Text: string;
    ClipboardService: IFMXClipboardService;
begin
  // Concatenate all list items' text into a single string
    for I := 0 to ListBox.Count - 1 do begin
        Text := Text + ListBox.ListItems[I].Text + sLineBreak;
    end;

   // Get the clipboard service
   if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(ClipboardService)) then begin
      // Copy the text to the clipboard
        ClipboardService.SetClipboard(Text);
    end;
end;

procedure TfrmSourceLog.lstLogMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
    Timer2.Enabled := True;
end;

procedure TfrmSourceLog.ShowSuccess(ALabel: TLabel);
begin
    if ALabel.Hint = '' then begin
        Timer1.Enabled := True;
        ALabel.Hint := ALabel.Text;
        ALabel.Text := 'Log copied to clipboard!';
        Timer1.Enabled := True;
    end;
end;

procedure TfrmSourceLog.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := False;
    if lblClipboard.Hint <> '' then lblClipboard.Text := lblClipboard.Hint;
end;

procedure TfrmSourceLog.Timer2Timer(Sender: TObject);
begin
    Timer2.Enabled := False;
end;

procedure TfrmSourceLog.lblClipboardClick(Sender: TObject);
begin
    CopyListBoxTextToClipboard(lstLog);
    ShowSuccess(lblClipboard);
end;

procedure TfrmSourceLog.WriteToLog(Msg: String);
begin
    if Msg <> lstLog.Hint then begin
        lstLog.Hint := Msg;

        if lstLog.Items.Count > 9999 then begin
            lstLog.Items.Delete(0);
        end;

        lstLog.Items.Add(FormatDateTime('hh:nn:ss', Now) + ': ' + Msg);

        if not Timer2.Enabled then begin
            lstLog.ItemIndex := lstLog.Items.Count-1;
        end;
    end;
end;

end.
