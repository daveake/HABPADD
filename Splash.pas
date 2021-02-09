unit Splash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
{$IFDEF ANDROID}
  FMX.Helpers.Android, FMX.Platform.Android,
  Androidapi.JNI.JavaTypes, Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
{$ENDIF}
{$IFDEF MSWINDOWS}
    Windows,
{$ENDIF}
  Base, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox;

type
  TfrmSplash = class(TfrmBase)
    Image1: TImage;
    lblVersion: TLabel;
    rectLoading: TRectangle;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadForm; override;
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.fmx}

uses Main, Debug;

procedure TfrmSplash.FormCreate(Sender: TObject);
{$IFDEF ANDROID}
var
    PackageManager: JPackageManager;
    PackageInfo: JPackageInfo;
{$ENDIF}
{$IFDEF MSWINDOWS}
var
    verblock:PVSFIXEDFILEINFO;
    versionMS,versionLS:cardinal;
    verlen:cardinal;
    rs:TResourceStream;
    m:TMemoryStream;
    p:pointer;
    s:cardinal;
    AppVersionString: String;
{$ENDIF}
begin
{$IFDEF ANDROID}
    try
        PackageManager := TAndroidHelper.Context.getPackageManager; //SharedActivityContext.getPackageManager;
        PackageInfo := PackageManager.getPackageInfo(TAndroidHelper.Context.getPackageName, 0);  //SharedActivityContext.getPackageName, 0);
        lblVersion.Text := JStringToString(PackageInfo.versionName);
    except
    end;
{$ENDIF}
{$IFDEF MSWINDOWS}
    m:=TMemoryStream.Create;
    try
        rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
        try
            m.CopyFrom(rs,rs.Size);
        finally
            rs.Free;
        end;

        m.Position:=0;

        if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then begin
            VersionMS:=verblock.dwFileVersionMS;
            VersionLS:=verblock.dwFileVersionLS;
            AppVersionString := IntToStr(versionMS shr 16)+'.'+
                                IntToStr(versionMS and $FFFF)+'.'+
                                IntToStr(VersionLS shr 16)+'.'+
                                IntToStr(VersionLS and $FFFF);
        end;

        if VerQueryValue(m.Memory,PChar('\\StringFileInfo\\'+
          IntToHex(GetThreadLocale,4)+IntToHex(GetACP,4)+'\\FileDescription'),p,s) or
            VerQueryValue(m.Memory,'\\StringFileInfo\\040904E4\\FileDescription',p,s) then begin
                lblVersion.Text := pChar(p) + ' ' + AppVersionString;
        end else begin
            lblVersion.Text := Application.Title + ' ' + AppVersionString;
        end;

   finally
        m.Free;
    end;
{$ENDIF}
end;

procedure TfrmSplash.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if frmDebug <> nil then begin
        frmMain.LoadForm(nil, frmDebug);
    end;
end;

procedure TfrmSplash.LoadForm;
begin
end;


end.
