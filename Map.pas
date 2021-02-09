unit Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Base, TargetForm, System.IOUtils,
  FMX.TMSWebGMapsWebBrowser, FMX.TMSWebGMaps, FMX.TMSWebGMapsMarkers, FMX.TMSWebGMapsPolylines,
  FMX.TMSWebGMapsCommon, FMX.Controls.Presentation, Source, FMX.Objects;

type
  TFollowMode = (fmInit, fmNone, fmCar, fmPayload);

type
  TDirections = record
    Active: Boolean;
    TargetLatitude: Double;
    TargetLongitude: Double;
    CurrentLatitude: Double;
    CurrentLongitude: Double;
  end;


type
  TfrmMap = class(TfrmTarget)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    V: TPanel;
    btnCar: TButton;
    btnPayload: TButton;
    btnFree: TButton;
    Rectangle4: TRectangle;
    Rectangle6: TRectangle;
    pnlCentre: TPanel;
    Rectangle5: TRectangle;
    GMap: TTMSFMXWebGMaps;
    tmrDirections: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure GMapDownloadFinish(Sender: TObject);
    procedure btnCarClick(Sender: TObject);
    procedure btnFreeClick(Sender: TObject);
    procedure btnPayloadClick(Sender: TObject);
    procedure tmrDirectionsTimer(Sender: TObject);
    procedure GMapMapIdle(Sender: TObject);
  private
    { Private declarations }
    OKToUpdateMap: Boolean;
    MarkerNames: array[0..6] of String;
    PolylineItems: array[0..3] of TPolylineItem;
    FollowMode: TFollowMode;
    Directions: TDirections;
    function FindMapMarker(PayloadID: String): Integer;
    procedure AddOrUpdateMapMarker(PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
    procedure ShowSelectedButton(Button: TButton);
  protected
    function ProcessNewPosition(Index: Integer): Boolean; override;
  public
    { Public declarations }
    procedure LoadForm; override;
    procedure HideForm; override;
    procedure ShowDirections(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double);
  end;

var
  frmMap: TfrmMap;

implementation

{$R *.fmx}

uses Main, Miscellaneous, Debug;

// IF THE FOLLOWING LINE GIVES AN ERROR

{$INCLUDE 'key.pas'}

(* THEN CREATE A FILE key.pas CONTAINING:

const GoogleMapsAPIKey = '<YOUR_GOOGLE_API_KEY>';

THIS FILE IS SPECIFICALLY EXCLUDED in .gitignore TO AVOID SHARING API KEYS
*)

procedure TfrmMap.FormCreate(Sender: TObject);
var
    i: Integer;
begin
    GMap.LocationAPIKey := GoogleMapsAPIKey;

    GMap.APIKey := GMap.LocationAPIKey;
    GMap.LocationAPIKey := '';

    {$IFDEF ANDROID}
        GMap.Visible := False;
    {$ENDIF}

    for i := 0 to 3 do begin
        PolylineItems[i] := GMap.Polylines.Add;
        PolylineItems[i].Polyline.Width := 2;
        GMap.CreateMapPolyline(PolylineItems[i].Polyline);
    end;

    {$IFDEF MSWINDOWS}
        GMap.Position.X := 100;
        GMap.Position.Y := 32;
    {$ENDIF}

    OKToUpdateMap := True;
end;

procedure TfrmMap.LoadForm;
begin
    inherited;

//    if not GMap.Visible then begin
//        GMap.Width := frmMain.pnlCentre.Width;
//        GMap.Height := frmMain.pnlCentre.Height - 32;
//        GMap.Visible := True;
//    end;
    if not GMap.Visible then begin
        GMap.Visible := True;
    end;

//    btnCar.Font.Size := btnCar.Size.Height * 36/64;
//    btnFree.Font.Size := btnCar.Font.Size;
//    btnPayload.Font.Size := btnCar.Font.Size;

    FollowMode := fmInit;
end;

procedure TfrmMap.HideForm;
begin
    {$IFDEF ANDROID}
        GMap.Visible := False;
    {$ENDIF}
    inherited;
end;

procedure TfrmMap.GMapDownloadFinish(Sender: TObject);
begin
    OKToUpdateMap := True;
    if FollowMode = fmInit then begin
        GMap.MapPanTo(Positions[0].Position.Latitude, Positions[0].Position.Longitude);
        btnFreeClick(btnFree);
    end;

    if Directions.Active then begin
        frmDebug.Debug('3');
        tmrDirections.Enabled := True;
        Directions.Active := False;
    end;
end;

procedure TfrmMap.GMapMapIdle(Sender: TObject);
begin
    OKToUpdateMap := True;

    if Directions.Active then begin
        frmDebug.Debug('2');
        tmrDirections.Enabled := True;
        Directions.Active := False;
    end;
end;

procedure TfrmMap.btnCarClick(Sender: TObject);
begin
    ShowSelectedButton(TButton(Sender));
    FollowMode := fmCar;
    GMap.MapPanTo(Positions[0].Position.Latitude, Positions[0].Position.Longitude);
end;

procedure TfrmMap.btnFreeClick(Sender: TObject);
begin
    ShowSelectedButton(TButton(Sender));
    FollowMode := fmNone;
end;

procedure TfrmMap.btnPayloadClick(Sender: TObject);
begin
    ShowSelectedButton(TButton(Sender));
    FollowMode := fmPayload;
    GMap.MapPanTo(Positions[SelectedIndex].Position.Latitude, Positions[SelectedIndex].Position.Longitude);
end;

function TfrmMap.FindMapMarker(PayloadID: String): Integer;
var
    i: Integer;
begin
    for i := 0 to GMap.Markers.Count-1 do begin
        if GMap.Markers[i].Title = PayloadID then begin
            // Found it
            Result := i;
            Exit;
        end;
    end;

    Result := -1;
end;

procedure TfrmMap.AddOrUpdateMapMarker(PayloadID: String; Latitude: Double; Longitude: Double; ImageName: String);
var
    MarkerIndex: Integer;
    Marker: TMarker;
    FileName: String;
begin
    MarkerIndex := FindMapMarker(PayloadID);
    if MarkerIndex >= 0 then begin
        Marker := GMap.Markers[MarkerIndex];
    end else begin
        Marker := GMap.Markers.Add(Latitude, Longitude, PayloadID);
        MarkerIndex := GMap.Markers.Count-1;
    end;

    Marker.Latitude := Latitude;
    Marker.Longitude := Longitude;

    // Marker.Icon := StringReplace('File://' + 'C:\Dropbox\dev\HAB\HABMobile2\images\' + ImageName + '.png', '\', '/',[rfReplaceAll, rfIgnoreCase]);
    FileName := System.IOUtils.TPath.Combine(ImageFolder, ImageName + '.png');

    if FileName <> MarkerNames[MarkerIndex] then begin
        MarkerNames[MarkerIndex] := FileName;
        if FileExists(FileName) then begin
            Marker.Icon := StringReplace('File://' + FileName, '\', '/',[rfReplaceAll, rfIgnoreCase]);
        end;
    end;
end;


function TfrmMap.ProcessNewPosition(Index: Integer): Boolean;
begin
    Result := False;

    if OKToUpdateMap then begin
        // Find or create marker fo this payload
        if Index = 0 then begin
            AddOrUpdateMapMarker('Car', Positions[0].Position.Latitude, Positions[0].Position.Longitude, 'car-blue');
            if FollowMode = fmCar then begin
                GMap.MapPanTo(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            end;
        end else begin
            AddOrUpdateMapMarker(Positions[Index].Position.PayloadID,
                                 Positions[Index].Position.Latitude,
                                 Positions[Index].Position.Longitude,
                                 frmMain.BalloonIconName(Index));

            PolylineItems[Index].Polyline.Path.Add(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            GMap.UpdateMapPolyline(PolylineItems[Index].Polyline);
            if (FollowMode = fmPayload) and (Index = SelectedIndex) then begin
                GMap.MapPanTo(Positions[Index].Position.Latitude, Positions[Index].Position.Longitude);
            end;
        end;

        if Positions[Index].Position.ContainsPrediction then begin
            AddOrUpdateMapMarker(Positions[Index].Position.PayloadID + '-X', Positions[Index].Position.PredictedLatitude, Positions[Index].Position.PredictedLongitude, frmMain.BalloonIconName(Index, True));
        end;
        Result := True;
    end;
end;

procedure TfrmMap.tmrDirectionsTimer(Sender: TObject);
begin
    frmDebug.Debug('4');
    tmrDirections.Enabled := False;
    with Directions do begin
        GMap.RenderDirections(CurrentLatitude, CurrentLongitude, TargetLatitude, TargetLongitude, tmDriving);
    end;
end;

procedure TfrmMap.ShowDirections(TargetLatitude, TargetLongitude, CurrentLatitude, CurrentLongitude: Double);
begin
    frmDebug.Debug('1');
    Directions.TargetLatitude := TargetLatitude;
    Directions.TargetLongitude := TargetLongitude;
    Directions.CurrentLatitude := CurrentLatitude;
    Directions.CurrentLongitude := CurrentLongitude;
    Directions.Active := True;
end;

procedure TfrmMap.ShowSelectedButton(Button: TButton);
begin
    btnCar.TextSettings.Font.Style := btnCar.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnFree.TextSettings.Font.Style := btnFree.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    btnPayload.TextSettings.Font.Style := btnPayload.TextSettings.Font.Style - [TFontStyle.fsUnderline];

    Button.TextSettings.Font.Style := Button.TextSettings.Font.Style + [TFontStyle.fsUnderline];
end;

end.
