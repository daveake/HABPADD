unit Miscellaneous;

interface

uses DateUtils, Math, Source, HABTypes, INIFiles, Generics.Collections, System.IOUtils;

type
  TStatusCallback = procedure(Active, OK: Boolean) of object;

type
  TSettings = TDictionary<String, Variant>;

function GetJSONString(Line: String; FieldName: String): String;
function GetJSONInteger(Line: String; FieldName: String): LongInt;
function GetJSONFloat(Line: String; FieldName: String): Double;
function PayloadHasFieldType(Position: THABPosition; FieldType: TFieldType): Boolean;
procedure InsertDate(var TimeStamp: TDateTime);
function CalculateDescentTime(Altitude, DescentRate, Land: Double): Double;
function DataFolder: String;
function ImageFolder: String;
function GetString(var Line: String; Delimiter: String=','): String;

procedure InitialiseSettings;

function GetSettingString(Section, Item, Default: String): String;
function GetSettingInteger(Section, Item: String; Default: Integer): Integer;
function GetSettingBoolean(Section, Item: String; Default: Boolean): Boolean;
function GetGroupChangedFlag(Section: String): Boolean;

procedure SetSettingString(Section, Item, Value: String);
procedure SetSettingInteger(Section, Item: String; Value: Integer);
procedure SetSettingBoolean(Section, Item: String; Value: Boolean);
procedure SetGroupChangedFlag(Section: String; Changed: Boolean);

const
    GPS_SOURCE = 0;
    GATEWAY_SOURCE = 1;
    SERIAL_SOURCE = 2;
    BLUETOOTH_SOURCE = 3;
    UDP_SOURCE = 4;
    HABITAT_SOURCE = 5;

var
    INIFileName: String;

implementation

uses SysUtils;

var
    Settings: TSettings;
    Ini: TIniFile;


function DataFolder: String;
begin
    if ParamCount > 0 then begin
        Result := ParamStr(1);
    end else begin
        Result := ExtractFilePath(ParamStr(0));
    end;

    {$IFDEF ANDROID}
        Result := TPath.GetDocumentsPath;
    {$ENDIF}

    Result := IncludeTrailingPathDelimiter(Result);
end;

function ImageFolder: String;
begin
    Result := DataFolder;

    {$IFDEF MSWINDOWS}
        Result := TPath.Combine(DataFolder, 'Images');
    {$ENDIF}
end;


function GetJSONString(Line: String; FieldName: String): String;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Copy(Line, Position + Length(FieldName) + 3, 1) = '"' then begin
        Line := Copy(Line, Position + Length(FieldName) + 4, 999);
        Position := Pos('"', Line);

        Result := Copy(Line, 1, Position-1);
//    end else if Line[Position + Length(FieldName) + 4] = '"' then begin
//        Line := Copy(Line, Position + Length(FieldName) + 5, 999);
//        Position := Pos('"', Line);
//
//        Result := Copy(Line, 1, Position-1);
    end else begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end;

        Result := Copy(Line, 1, Position-1);
    end;
end;


function GetJSONFloat(Line: String; FieldName: String): Double;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Position > 0 then begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end else if Pos('}', Line) < Position then begin
            Position := Pos('}', Line);
        end;


        Line := Copy(Line, 1, Position-1);

        if Copy(Line, 1, 1) = '"' then begin
            Line := Copy(Line,2, Length(Line)-2);
        end;

        try
            Result := StrToFloat(Line);
        except
            Result := 0;
        end;
    end else begin
        Result := 0;
    end;
end;

function GetJSONInteger(Line: String; FieldName: String): LongInt;
var
    Position: Integer;
begin
    // {"class":"POSN","payload":"NOTAFLIGHT","time":"13:01:56","lat":52.01363,"lon":-2.50647,"alt":5507,"rate":7.0}

    Position := Pos('"' + FieldName + '":', Line);

    if Position > 0 then begin
        Line := Copy(Line, Position + Length(FieldName) + 3, 999);

        Position := Pos(',', Line);
        if Position = 0 then begin
            Position := Pos('}', Line);
        end;

        Line := Copy(Line, 1, Position-1);

        if Copy(Line, 1, 1) = '"' then begin
            Line := Copy(Line,2, Length(Line)-2);
        end;

        Result := StrToIntDef(Line, 0);
    end else begin
        Result := 0;
    end;
end;

function PayloadHasFieldType(Position: THABPosition; FieldType: TFieldType): Boolean;
var
    i: Integer;
begin
    for i := 0 to length(Position.FieldList)-1 do begin
        if Position.FieldList[i] = FieldType then begin
            Result := True;
            Exit;
        end;
    end;

    Result := False;
end;

procedure InsertDate(var TimeStamp: TDateTime);
begin
    if TimeStamp < 1 then begin
        // Add today's date
        TimeStamp := TimeStamp + Trunc(TTimeZone.Local.ToUniversalTime(Now));

        if (TimeStamp > 0.99) and (Frac(TTimeZone.Local.ToUniversalTime(Now)) < 0.01) then begin
            // Just past midnight, but payload transmitted just before midnight, so use yesterday's date
            TimeStamp := TimeStamp - 1;
        end;
    end;
end;


function CalculateAirDensity(alt: Double): Double;
var
    Temperature, Pressure: Double;
begin
    if alt < 11000.0 then begin
        // below 11Km - Troposphere
        Temperature := 15.04 - (0.00649 * alt);
        Pressure := 101.29 * power((Temperature + 273.1) / 288.08, 5.256);
    end else if alt < 25000.0 then begin
        // between 11Km and 25Km - lower Stratosphere
        Temperature := -56.46;
        Pressure := 22.65 * exp(1.73 - ( 0.000157 * alt));
    end else begin
        // above 25Km - upper Stratosphere
        Temperature := -131.21 + (0.00299 * alt);
        Pressure := 2.488 * power((Temperature + 273.1) / 216.6, -11.388);
    end;

    Result := Pressure / (0.2869 * (Temperature + 273.1));
end;

function CalculateDescentRate(Weight, Density, CDTimesArea: Double): Double;
begin
    Result := sqrt((Weight * 9.81)/(0.5 * Density * CDTimesArea));
end;

function CalculateCDA(Weight, Altitude, DescentRate: Double): Double;
var
	Density: Double;
begin
	Density := CalculateAirDensity(Altitude);

    Result := (Weight * 9.81)/(0.5 * Density * DescentRate * DescentRate);
end;

function CalculateDescentTime(Altitude, DescentRate, Land: Double): Double;
var
    Density, CDTimesArea, TimeAtAltitude, TotalTime, Step: Double;
begin
    Step := 100;

    CDTimesArea := CalculateCDA(1.0, Altitude, DescentRate);

    TotalTime := 0;

    while Altitude > Land do begin
        Density := CalculateAirDensity(Altitude);

        DescentRate := CalculateDescentRate(1.0, Density, CDTimesArea);

        TimeAtAltitude := Step / DescentRate;
        TotalTime := TotalTime + TimeAtAltitude;

        Altitude := Altitude - Step;
    end;

    Result := TotalTime;
end;

procedure InitialiseSettings;
begin
    Settings := TSettings.Create;

    Ini := TIniFile.Create(INIFileName);
end;

function GetSettingString(Section, Item, Default: String): String;
var
    Key: String;
begin
    Key := Section + '/' + Item;

    if Settings.ContainsKey(Key) then begin
        Result := Settings[Key];
    end else begin
        Result := Ini.ReadString(Section, Item, Default);
        Settings.Add(Key, Result);
    end;
end;

function GetSettingInteger(Section, Item: String; Default: Integer): Integer;
var
    Key: String;
begin
    Key := Section + '/' + Item;

    if Settings.ContainsKey(Key) then begin
        Result := Settings[Key];
    end else begin
        Result := Ini.ReadInteger(Section, Item, Default);
        Settings.Add(Key, Result);
    end;
end;

function GetSettingBoolean(Section, Item: String; Default: Boolean): Boolean;
var
    Key: String;
begin
    Key := Section + '/' + Item;

    if Settings.ContainsKey(Key) then begin
        Result := Settings[Key];
    end else begin
        Result := Ini.ReadBool(Section, Item, Default);
        Settings.Add(Key, Result);
    end;
end;

procedure SetGroupChangedFlag(Section: String; Changed: Boolean);
begin
    Settings.AddOrSetValue(Section, Changed);
end;

function GetGroupChangedFlag(Section: String): Boolean;
begin
    if Settings.ContainsKey(Section) then begin
        Result := Settings[Section];
    end else begin
        Result := False;
        Settings.Add(Section, False);
    end;
end;

procedure SetSettingString(Section, Item, Value: String);
var
    Key: String;
begin
    Key := Section + '/' + Item;
    Settings.AddOrSetValue(Key, Value);
    Ini.WriteString(Section, Item, Value);
    Ini.UpdateFile;
end;

procedure SetSettingInteger(Section, Item: String; Value: Integer);
var
    Key: String;
begin
    Key := Section + '/' + Item;
    Settings.AddOrSetValue(Key, Value);
    Ini.WriteInteger(Section, Item, Value);
    Ini.UpdateFile;
end;

procedure SetSettingBoolean(Section, Item: String; Value: Boolean);
var
    Key: String;
begin
    Key := Section + '/' + Item;
    Settings.AddOrSetValue(Key, Value);
    Ini.WriteBool(Section, Item, Value);
    Ini.UpdateFile;
end;

function GetString(var Line: String; Delimiter: String=','): String;
var
    Position: Integer;
begin
    Position := Pos(Delimiter, string(Line));
    if Position > 0 then begin
        Result := Copy(Line, 1, Position-1);
        Line := Copy(Line, Position+Length(Delimiter), Length(Line));
    end else begin
        Result := Line;
        Line := '';
    end;
end;


end.

