unit LoRaGatewaySettings2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  LoRaGatewaySettings, FMX.TMSCustomEdit, FMX.TMSEdit, FMX.ScrollBox, FMX.Memo,
  FMX.Objects, FMX.Controls.Presentation, Miscellaneous, FMX.Memo.Types;

type
  TfrmLoRaGatewaySettings2 = class(TfrmLoRaGatewaySettings)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoRaGatewaySettings2: TfrmLoRaGatewaySettings2;

implementation

{$R *.fmx}

procedure TfrmLoRaGatewaySettings2.FormCreate(Sender: TObject);
begin
    inherited;
    Group := 'LoRaGateway2';
    SourceIndex := GATEWAY_SOURCE_2;
end;

end.
