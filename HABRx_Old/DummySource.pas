unit DummySource;

interface

uses Source, Classes, SysUtils;

type
  TDummySource = class(TSource)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  public
  end;

implementation

procedure TDummySource.Execute;
var
    Position: THABPosition;
begin
    while not Terminated do begin
        // some real work could be done here
        Sleep(1000);
        if Enabled then begin
            // ZeroMemory(@Position, sizeof(Position));
            FillChar(Position, SizeOf(Position), 0);
            SyncCallback(SourceID, True, 'DummySource', Position);
        end;
    end;
end;

end.
