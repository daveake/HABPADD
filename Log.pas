unit Log;

interface

uses
  {$IFDEF ANDROID}
  Androidapi.JNI.TTS, AndroidAPI.JNIBridge, Androidapi.JNI.Speech, Androidapi.JNI.Os, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes, FMX.Helpers.Android,
    {$IF CompilerVersion >= 27.0}
    Androidapi.Helpers,
    {$ENDIF}
  {$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  TargetForm, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, IPPeerClient,
  REST.Client, REST.Types, Data.Bind.Components, Data.Bind.ObjectScope,
  REST.Authenticator.OAuth, FMX.Objects, HABLink;

type
  TfrmLog = class(TfrmTarget)
    lstLog: TListBox;
    OAuth1_Twitter: TOAuth1Authenticator;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    Rectangle1: TRectangle;
    Button3: TButton;
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    lstSpeech: TListBox;
    procedure btnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrUpdatesTimer(Sender: TObject);
  private
    { Private declarations }
  {$IFDEF ANDROID}
    tts: JTextToSpeech;
  {$ENDIF}
    HabLinkUploader: THABLinkThread;
    procedure ResetRESTComponentsToDefaults;
    procedure PostTweet(Temp: String);
    procedure TextToSpeech(Temp: String);
  public
    { Public declarations }
    procedure AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
  end;

var
  frmLog: TfrmLog;

implementation

{$R *.fmx}

uses Miscellaneous, Debug;

function SpellOut(Temp: String): String;
var
    i: Integer;
begin
    Result := '';

    for i := 1 to Length(Temp) do begin
        Result := Result + Copy(Temp, i, 1) + ' ';
    end;
end;

procedure TfrmLog.AddMessage(PayloadID, Temp: String; Speak, Tweet: Boolean);
var
    Speech, Msg, TimedMsg: String;
begin
    if PayloadID = '' then begin
        Msg := Temp;
        Speech := Msg;
    end else begin
        Msg := PayloadID + ' - ' + Temp;
        // Speech := SpellOut(PayloadID) + Temp;
        Speech := PayloadID + ' ' + Temp;
    end;

    TimedMsg := formatDateTime('hh:nn:ss', Now) + ': ' + Msg;

    lstLog.ItemIndex := lstLog.Items.Add(TimedMsg);

    Application.ProcessMessages;

    // Text to speech, for Android
    if Speak and GetSettingBoolean('General', 'Speech', False) then begin
        lstSpeech.Items.Add(Speech);
    end;

    // Twitter
    if Tweet and GetSettingBoolean('General', 'Tweet', False) then begin
        PostTweet('HAB PADD: ' + TimedMsg);
    end;

    // hab.link
    if Tweet then begin
        HabLinkUploader.SendMessage('MESSAGE:' + Speech);
    end;
end;

procedure TfrmLog.btnClick(Sender: TObject);
var
    Temp: String;
begin
    Temp := TButton(Sender).Text;

    AddMessage('', Temp, False, True);
end;

procedure TfrmLog.FormCreate(Sender: TObject);
begin
    inherited;

  {$IFDEF ANDROID}
    tts := TJTextToSpeech.JavaClass.init(SharedActivityContext, nil); // ttsListener);
  {$ENDIF}

    // hab.link uploader
    HabLinkUploader := THABLinkThread.Create(nil);
end;

procedure TfrmLog.PostTweet(Temp: String);
begin
    ResetRESTComponentsToDefaults;

    RESTClient.BaseURL := 'https://api.twitter.com';
    RESTClient.Authenticator := OAuth1_Twitter;

    RESTRequest.Resource := '1.1/statuses/update.json';

    RESTRequest.Method := TRESTRequestMethod.rmPOST;

    RESTRequest.Params.AddItem('status', Temp, TRESTRequestParameterKind.pkGETorPOST);

    RESTRequest.Execute;
end;

procedure TfrmLog.ResetRESTComponentsToDefaults;
begin
    RESTRequest.ResetToDefaults;
    RESTClient.ResetToDefaults;
    RESTResponse.ResetToDefaults;
end;

{$IFDEF ANDROID}
procedure TfrmLog.TextToSpeech(Temp: String);
var
    text: JString;
begin
    text := StringToJString(temp);

    // tts.speak(text, TJTextToSpeech.JavaClass.QUEUE_FLUSH, nil);
    tts.speak(text, TJTextToSpeech.JavaClass.QUEUE_ADD, nil);
end;
{$ELSE}
procedure TfrmLog.TextToSpeech(Temp: String);
begin
    //
end;
{$ENDIF}

procedure TfrmLog.tmrUpdatesTimer(Sender: TObject);
begin
    inherited;

    if lstSpeech.Items.Count > 0 then begin
        TextToSpeech(lstSpeech.Items[0]);
        lstSpeech.Items.Delete(0);
    end;
end;

end.
