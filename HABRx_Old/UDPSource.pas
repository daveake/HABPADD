unit UDPSource;

interface

uses Source, Classes, SysUtils, Miscellaneous,
{$IFDEF ANDROID}
     Androidapi.JNI.WiFiManager, Androidapi.Helpers,
{$ENDIF}
     IdBaseComponent, IdComponent, IdUDPServer, IdUDPBase, IdGlobal, IdSocketHandle;

type
  TUDPSource = class(TSource)
  private
    { Private declarations }
    UDPServer: TIdUDPServer;
    PayloadID: String;
    procedure UDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  public
    constructor Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
  end;

implementation

procedure TUDPSource.Execute;
var
    Position: THABPosition;
{$IFDEF ANDROID}
    wifi_manager: JWiFiManager;
    multiCastLock: JMulticastLock;
{$ENDIF}
begin
    FillChar(Position, SizeOf(Position), 0);
    SyncCallback(SourceID, True, '', Position);

{$IFDEF ANDROID}
    wifi_manager := GetWiFiManager;
    multiCastLock := wifi_manager.createMulticastLock(StringToJString('HABMobile'));
    multiCastLock.setReferenceCounted(true);
    multiCastLock.acquire;
{$ENDIF}

    while not Terminated do begin
        SetGroupChangedFlag(GroupName, False);
        PayloadID := GetSettingString(GroupName, 'PayloadID', 'UDP');

        // Create client
        UDPServer := TIdUDPServer.Create;

        with UDPServer.Bindings.Add do begin
            IP := '0.0.0.0';
            Port := GetSettingInteger(GroupName, 'Port', 0);

        end;

        UDPServer.ReuseSocket := rsTrue;
        UDPServer.ThreadedEvent := True;
        UDPServer.OnUDPRead := UDPRead;
        UDPServer.Active := True;

        while (not Terminated) and (not GetGroupChangedFlag(GroupName)) do begin
            Sleep(100);
        end;

        UDPServer.Active := False;
        UDPServer.Free;
        Sleep(100);
    end;
end;

procedure TUDPSource.UDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
    Position: THABPosition;
    Line: String;
begin
    Line := BytesToString(AData);

    Position := ExtractPositionFrom(Line, PayloadID);

    if Position.InUse then begin
        SyncCallback(SourceID, True, Line, Position);
    end;
end;

constructor TUDPSource.Create(ID: Integer; Group: String; Callback: TSourcePositionCallback);
begin
    inherited Create(ID, Group, Callback);
end;

end.
