unit HabitatSource;

interface

uses Source, DateUtils, SysUtils, Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  THabitatSource = class(TSource)
  private
    { Private declarations }
    procedure ProcessHabitatResponse(Response: String);
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
    PayloadList: String;
  public
    constructor Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
  end;

implementation

uses Miscellaneous;

constructor THabitatSource.Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
begin
    inherited Create(ID, Group, Callback);
end;

function GetURL(URL: String): String;
var
    ResponseStream: TMemoryStream;
    html: string;
    HTTP: TIdHTTP;
begin
    try
        try
            ResponseStream := TMemoryStream.Create;
            HTTP := TIdHTTP.Create(nil);
            HTTP.Request.ContentType := 'text/xml; charset=utf-8';
            HTTP.Request.ContentEncoding := 'utf-8';
            HTTP.HTTPOptions := [hoForceEncodeParams];
            HTTP.Get(url, responseStream);
            with TStringStream.Create do
            try
                LoadFromStream(ResponseStream);
               Result := DataString;
            finally
              Free;
            end;
        except
            //
        end;
    finally
        try
            HTTP.Disconnect;
        except
        end;

        HTTP.Free;
        ResponseStream.Free;
    end;
end;

procedure THabitatSource.ProcessHabitatResponse(Response: String);
var
    Strings: TStringList;
    i: Integer;
    Position: THABPosition;
    Line, TimeStamp: String;
begin
    Strings := TStringList.Create;
    Strings.Text := Response;

    for i := 0 to Strings.Count-1 do begin
        Line := Strings[i];
        if GetJSONInteger(Line, 'position_id') > 0 then begin
            FillChar(Position, SizeOf(Position), 0);
            // "position_id":"21593335","vehicle":"PTE2"
            Position.PayloadID := GetJSONString(Line, 'vehicle');

            // "gps_time":"2018-09-19 11:14:58",
            TimeStamp := GetJSONString(Line, 'gps_time');

            Position.TimeStamp := EncodedateTime(StrToIntDef(Copy(TimeStamp, 1, 4), 0),
                                                 StrToIntDef(Copy(TimeStamp, 6, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 9, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 12, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 15, 2), 0),
                                                 StrToIntDef(Copy(TimeStamp, 18, 2), 0),
                                                 0);

            // "gps_lat":"51.95016","gps_lon":"-2.5446","gps_alt":"130"
            Position.Latitude := GetJSONFloat(Line, 'gps_lat');
            Position.Longitude := GetJSONFloat(Line, 'gps_lon');
            Position.Altitude := GetJSONFloat(Line, 'gps_alt');

            // "data":{"landing_speed":"0.0","cda":"0.66","predicted_latitude":"0.0","temperature_internal":"40.1","ttl":0,"satellites":10,"predicted_longitude":"0.0"},"callsign":"M0RPI\/5","sequence":"50"},
            // "predicted_latitude":"0.0","temperature_internal":"40.1","ttl":0,"satellites":10,"predicted_longitude":"0.0"},"callsign":"M0RPI\/5","sequence":"50"},
            Position.PredictedLatitude := GetJSONFloat(Line, 'predicted_latitude');
            Position.PredictedLongitude := GetJSONFloat(Line, 'predicted_longitude');
            Position.ContainsPrediction := (Position.PredictedLatitude <> 0) or (Position.PredictedLongitude <> 0);

            Position.Line := ' ' + Position.PayloadID + ': ' + FormatDateTime('hh:nn:ss', Position.TimeStamp) + ' - ' + Position.Latitude.ToString + ',' + Position.Longitude.ToString + ',' + Position.Altitude.ToString;

            Position.ReceivedAt := Now;
            Position.InUse := True;

            SyncCallback(SourceID, True, '', Position);

            Position.ReceivedAt := Now;
        end;
    end;

    Strings.Free;
end;


procedure THabitatSource.Execute;
var
    Position: THABPosition;
    Response, Request: String;
begin
    while not Terminated do begin
        if PayloadList <> '' then begin
            Request := 'http://spacenear.us/tracker/datanew.php?mode=Position&type=positions&format=json&max_positions=10&vehicles=' + PayloadList;
            Response := GetURL(Request);
            // Response := GetURL('http://spacenear.us/tracker/datanew.php?mode=Position&type=positions&format=json&max_positions=10&vehicles=DRAGINO');

            ProcessHabitatResponse(Response);
        end;

        Sleep(5000);
    end;
end;


end.

