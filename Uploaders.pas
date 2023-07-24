unit Uploaders;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, FMX.Objects,
  FMX.Platform, FMX.Clipboard;

type
  TfrmUploaders = class(TfrmBase)
    rectLeft: TRectangle;
    rectRight: TRectangle;
    rectSH: TRectangle;
    Rectangle8: TRectangle;
    Label4: TLabel;
    lblClipboard: TLabel;
    lstSondehub: TListBox;
    Timer2: TTimer;
    rectSSDV: TRectangle;
    Rectangle2: TRectangle;
    Label2: TLabel;
    lblSSDVClipboard: TLabel;
    lstSSDV: TListBox;
    Timer3: TTimer;
    rectHABLink: TRectangle;
    Rectangle3: TRectangle;
    Label1: TLabel;
    lblHABLinkClipboard: TLabel;
    lstHABLink: TListBox;
    Timer1: TTimer;
    rectMQTT: TRectangle;
    Rectangle5: TRectangle;
    Label5: TLabel;
    lblMQTTClipboard: TLabel;
    lstMQTT: TListBox;
    Timer4: TTimer;
    Timer5: TTimer;
    procedure lblClipboardClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer5Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure lblSSDVClipboardClick(Sender: TObject);
    procedure lblHABLinkClipboardClick(Sender: TObject);
    procedure lblMQTTClipboardClick(Sender: TObject);
    procedure pnlMainResized(Sender: TObject);
  private
    { Private declarations }
    procedure ShowSuccess(ALabel: TLabel);
    procedure WriteToLog(ListBox: TListBox; Scroll: Boolean; Msg: String);
  public
    { Public declarations }
    procedure WriteSondehubStatus(Msg: String);
    procedure WriteSSDVStatus(Msg: String);
    procedure WriteHABLinkStatus(Msg: String);
    procedure WriteMQTTStatus(Msg: String);
  end;

var
  frmUploaders: TfrmUploaders;

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

procedure TfrmUploaders.lblHABLinkClipboardClick(Sender: TObject);
begin
    CopyListBoxTextToClipboard(lstHABLink);
    ShowSuccess(lblHABLinkClipboard);
end;

procedure TfrmUploaders.lblMQTTClipboardClick(Sender: TObject);
begin
    CopyListBoxTextToClipboard(lstMQTT);
    ShowSuccess(lblMQTTClipboard);
end;

procedure TfrmUploaders.lblSSDVClipboardClick(Sender: TObject);
begin
    CopyListBoxTextToClipboard(lstSSDV);
    ShowSuccess(lblSSDVClipboard);
end;

procedure TfrmUploaders.pnlMainResized(Sender: TObject);
begin
    inherited;
    rectLeft.Size.Width := pnlMain.Size.Width / 2;
    rectSH.Size.Height := pnlMain.Size.Height / 2;
    rectHABLink.Size.Height := pnlMain.Size.Height / 2;
end;

procedure TfrmUploaders.ShowSuccess(ALabel: TLabel);
begin
    if ALabel.Hint = '' then begin
        Timer1.Enabled := True;
        ALabel.Hint := ALabel.Text;
        ALabel.Text := 'Log copied to clipboard!';
        Timer1.Enabled := True;
    end;
end;

procedure TfrmUploaders.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := False;
    if lblClipboard.Hint <> '' then lblClipboard.Text := lblClipboard.Hint;
    if lblSSDVClipboard.Hint <> '' then lblSSDVClipboard.Text := lblSSDVClipboard.Hint;
    if lblHABLinkClipboard.Hint <> '' then lblHABLinkClipboard.Text := lblHABLinkClipboard.Hint;
    if lblMQTTClipboard.Hint <> '' then lblMQTTClipboard.Text := lblMQTTClipboard.Hint;
end;

procedure TfrmUploaders.Timer2Timer(Sender: TObject);
begin
    Timer2.Enabled := False;
end;

procedure TfrmUploaders.Timer3Timer(Sender: TObject);
begin
    Timer3.Enabled := False;
end;

procedure TfrmUploaders.Timer4Timer(Sender: TObject);
begin
    Timer4.Enabled := False;
end;

procedure TfrmUploaders.Timer5Timer(Sender: TObject);
begin
    Timer5.Enabled := False;
end;

procedure TfrmUploaders.lblClipboardClick(Sender: TObject);
begin
    CopyListBoxTextToClipboard(lstSondehub);
    ShowSuccess(lblClipboard);
end;

procedure TfrmUploaders.WriteToLog(ListBox: TListBox; Scroll: Boolean; Msg: String);
begin
    if Msg <> ListBox.Hint then begin
        ListBox.Hint := Msg;

        if ListBox.Items.Count > 9999 then begin
            ListBox.Items.Delete(0);
        end;

        ListBox.Items.Add(FormatDateTime('hh:nn:ss', Now) + ': ' + Msg);

        if Scroll then begin
            ListBox.ItemIndex := ListBox.Items.Count-1;
        end;
    end;
end;

procedure TfrmUploaders.WriteSondehubStatus(Msg: String);
begin
    WriteToLog(lstSondehub, not Timer2.Enabled, Msg);
end;

procedure TfrmUploaders.WriteSSDVStatus(Msg: String);
begin
    WriteToLog(lstSSDV, not Timer3.Enabled, Msg);
end;

procedure TfrmUploaders.WriteHABLinkStatus(Msg: String);
begin
    WriteToLog(lstHABLink, not Timer4.Enabled, Msg);
end;

procedure TfrmUploaders.WriteMQTTStatus(Msg: String);
begin
    WriteToLog(lstMQTT, not Timer5.Enabled, Msg);
end;

end.

