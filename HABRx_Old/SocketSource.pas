unit SocketSource;

interface

uses Source, Classes, SysUtils, Miscellaneous,
     IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TSocketSource = class(TSource)
  private
    { Private declarations }
    AClient: TIdTCPClient;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  public
    constructor Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
  end;

implementation

procedure TSocketSource.Execute;
var
    Position: THABPosition;
    Line: String;
begin
    // Create client
    AClient := TIdTCPClient.Create;

    while not Terminated do begin
        // Connect to socket server
        AClient.Host := GetSettingString(GroupName, 'Host', '');
        AClient.Port := GetSettingInteger(GroupName, 'Port', 0);
        SetGroupChangedFlag(GroupName, False);

        if (AClient.Host = '') or (AClient.Port <= 0) then begin
            Sleep(1000);
        end else begin
            while (not Terminated) and (not GetGroupChangedFlag(GroupName)) do begin
                try
                    FillChar(Position, SizeOf(Position), 0);
                    SyncCallback(SourceID, True, 'Connecting ...', Position);
                    AClient.Connect;
                    SyncCallback(SourceID, True, 'Connected', Position);
                    while not GetGroupChangedFlag(GroupName) do begin
                        Line := AClient.IOHandler.ReadLn;
                        if Line <> '' then begin
                            Position := ExtractPositionFrom(Line);
                            if Position.InUse or Position.HasRSSI then begin
                                SyncCallback(SourceID, True, '', Position);
                            end;
                        end;
                    end;
                    AClient.IOHandler.InputBuffer.clear;
                    AClient.IOHandler.CloseGracefully;
                    AClient.Disconnect;
                except
                    // Wait before retrying
                    SyncCallback(SourceID, False, 'No Connection', Position);
                    Sleep(5000);
                end;
            end;
        end;
    end;
end;

constructor TSocketSource.Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
begin
    inherited Create(ID, Group, Callback);
end;

end.
