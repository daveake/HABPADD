unit testing;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl, FMX.TMSFNCWebBrowser, FMX.TMSFNCMaps,
  FMX.TMSFNCGoogleMaps, FMX.Objects;

type
  TForm1 = class(TForm)
    rectBottomBar: TRectangle;
    crcBottomRight: TCircle;
    rectBottomRight: TRectangle;
    crcBottomLeft: TCircle;
    rectBottomLeft: TRectangle;
    rectSources: TRectangle;
    btnGateway1: TButton;
    btnGateway2: TButton;
    btnGPS: TButton;
    crcGPS: TCircle;
    btnHabHub: TButton;
    btnLoRaBT: TButton;
    crcLoRaBluetooth: TCircle;
    btnLoRaSerial: TButton;
    crcLoRaSerial: TCircle;
    btnUDP: TButton;
    lblGPS: TLabel;
    rectUploads: TRectangle;
    rectUploadHABLINK: TRectangle;
    Label2: TLabel;
    rectUploadMQTT: TRectangle;
    Label3: TLabel;
    rectUploadSSDV: TRectangle;
    Label4: TLabel;
    rectUploadHABHUB: TRectangle;
    Label1: TLabel;
    rectUploadSondehub: TRectangle;
    Label5: TLabel;
    rectMain: TRectangle;
    pnlCentre: TRectangle;
    rectTopBar: TRectangle;
    crcTopRight: TCircle;
    rctTopRight: TRectangle;
    crcTopLeft: TCircle;
    rectTopLeft: TRectangle;
    rectPayloadButtons: TRectangle;
    btnPayload1: TButton;
    btnPayload2: TButton;
    btnPayload3: TButton;
    lblPayload: TLabel;
    rectButtons: TRectangle;
    btnDirection: TButton;
    btnUplink: TButton;
    btnMap: TButton;
    btnNavigate: TButton;
    btnPayloads: TButton;
    btnSettings: TButton;
    btnSSDV: TButton;
    btnSources: TButton;
    pnlMap: TRectangle;
    StyleBook1: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

end.
