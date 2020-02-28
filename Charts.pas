unit Charts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TargetForm, FMX.Controls.Presentation, Source, FMXTee.Engine, FMXTee.Series,
  FMXTee.Procs, FMXTee.Chart;

type
  TfrmCharts = class(TfrmTarget)
    Chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure NewPosition(Index: Integer; Position: THABPosition); override;
  end;

var
  frmCharts: TfrmCharts;

implementation

{$R *.fmx}

procedure TfrmCharts.NewPosition(Index: Integer; Position: THABPosition);
begin
    if (Index >= 1) and (Index <= 3) then begin
        Index := Index - 1;

        Chart1.Series[Index].AddXY(Position.TimeStamp, Position.Altitude);
    end;
end;


end.
