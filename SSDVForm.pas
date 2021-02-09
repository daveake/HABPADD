unit SSDVForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TargetForm, FMX.Controls.Presentation, FMX.Objects, FMX.WebBrowser, Base,
  Source;

type
  TfrmSSDV = class(TfrmTarget)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    WebBrowser: TWebBrowser;
    URL: String;
  public
    { Public declarations }
    procedure NewSelection(Index: Integer); override;
    procedure LoadForm; override;
    procedure HideForm; override;
  end;

var
  frmSSDV: TfrmSSDV;

implementation

{$R *.fmx}

procedure TfrmSSDV.FormCreate(Sender: TObject);
begin
    URL := 'https://ssdv.habhub.org/';
end;

procedure TfrmSSDV.NewSelection(Index: Integer);
begin
    inherited;

    URL := 'https://ssdv.habhub.org/' + Positions[Index].Position.PayloadID;
    if WebBrowser <> nil then begin
        WebBrowser.URL := URL;
        WebBrowser.Navigate;
    end;
end;

procedure TfrmSSDV.LoadForm;
begin
    inherited;

    WebBrowser := TWebBrowser.Create(Self);
    WebBrowser.Parent := pnlMain;
    WebBrowser.Align := TAlignLayout.Client;
    WebBrowser.URL := URL;
    WebBrowser.Navigate;
end;

procedure TfrmSSDV.HideForm;
begin
    WebBrowser.Free;
    WebBrowser := nil;

    inherited;
end;


end.
