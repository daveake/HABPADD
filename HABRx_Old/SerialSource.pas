unit SerialSource;

interface

uses Source, Classes, SysUtils;

type
  TSerialSource = class(TSource)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  end;

implementation

procedure TSerialSource.Execute;
var
    Position: THABPosition;
begin
//  FMsg := Format('Thread %d started', [ThreadID]);
//  Synchronize(Log);
    while not Terminated do begin
        // some real work could be done here
        Sleep(1000);
        if Enabled then begin
            // ZeroMemory(@Position, sizeof(Position));
            FillChar(Position, SizeOf(Position), 0);
            PositionCallback(SourceID, True, 'SerialSource', Position);
        end;
        // FMsg := Format('Thread %d working ...', [ThreadID]);
        // Synchronize(Log);
    end;
    // FMsg := Format('Thread %d stopping ...', [ThreadID]);
    // Synchronize(Log);
end;

end.
