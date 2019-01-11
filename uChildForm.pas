unit uChildForm;

{$I cef.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Menus,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Types, Vcl.ComCtrls, Vcl.ClipBrd,
  System.UITypes,
  uMainForm, uCEFChromium, uCEFWindowParent, uCEFInterfaces, uCEFConstants, uCEFTypes,
  uCEFWinControl, uCEFCookieManager, uCEFCookieVisitor, uCefStringMultimap;

const
  CEFBROWSER_CONTEXTMENU_DELETECOOKIES = MENU_ID_USER_FIRST + 1;
  CEFBROWSER_CONTEXTMENU_GETCOOKIES    = MENU_ID_USER_FIRST + 2;
  CEFBROWSER_CONTEXTMENU_SETCOOKIE     = MENU_ID_USER_FIRST + 3;

type
  TChildForm = class(TForm)
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    Chromium1: TChromium;
    CEFWindowParent1: TCEFWindowParent;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Chromium1Close(Sender: TObject; const browser: ICefBrowser;
      out Result: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure Chromium1BeforeClose(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1LoadingStateChange(Sender: TObject;
      const browser: ICefBrowser; isLoading, canGoBack,
      canGoForward: Boolean);
    procedure Chromium1StatusMessage(Sender: TObject;
      const browser: ICefBrowser; const value: ustring);
    procedure Chromium1BeforePopup(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
      targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean; var Result: Boolean);
    procedure Chromium1BeforeResourceLoad(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback;
      out Result: TCefReturnValue);
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure BrowserCreatedMsg(var aMessage : TMessage); message CEFBROWSER_CREATED;
    procedure BrowserDestroyMsg(var aMessage : TMessage); message CEFBROWSER_DESTROY;
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;
    procedure WMEnterMenuLoop(var aMessage: TMessage); message WM_ENTERMENULOOP;
    procedure WMExitMenuLoop(var aMessage: TMessage); message WM_EXITMENULOOP;
    procedure AddCookieInfo(const aCookie : TCookie);
    procedure ShowCookiesMsg(var aMessage : TMessage); message CEFBROWSER_SHOWCOOKIES;
    procedure Button2Click(Sender: TObject);
  private

  protected

  public
  FCanClose : boolean;  // Set to True in TChromium.OnBeforeClose
  FClosing  : boolean;  // Set to True in the CloseQuery event.
  property Closing   : boolean
  read FClosing;
  end;

var
  ChildForm : TChildForm;
  FText     : string;
  FVisitor  : ICefCookieVisitor;

implementation

{$R *.dfm}
uses
  uCEFRequestContext, uCEFApplication;

function CookieVisitorProc(const name, value, domain, path: ustring;
                                 secure, httponly, hasExpires: Boolean;
                           const creation, lastAccess, expires: TDateTime;
                                 count, total: Integer;
                           out   deleteCookie: Boolean): Boolean;
var
  TempCookie : TCookie;
begin
  deleteCookie := False;

  TempCookie.name        := name;
  TempCookie.value       := value;
//  TempCookie.domain      := domain;
//  TempCookie.path        := path;
//  TempCookie.secure      := secure;
//  TempCookie.httponly    := httponly;
//  TempCookie.creation    := creation;
//  TempCookie.last_access := lastAccess;
//  TempCookie.has_expires := hasExpires;
  TempCookie.expires     := expires;

  ChildForm.AddCookieInfo(TempCookie);

  if (count = pred(total)) then
    begin
      if (ChildForm <> nil) and ChildForm.HandleAllocated then
        PostMessage(ChildForm.Handle, CEFBROWSER_SHOWCOOKIES, 0, 0);
      Result := False;
    end
   else
    Result := True;
end;

procedure TChildForm.AddCookieInfo(const aCookie : TCookie);
begin
  FText := FText + aCookie.name + '=' + aCookie.value +'; '+#13#10;
end;

procedure TChildForm.ShowCookiesMsg(var aMessage : TMessage);
begin
  Memo1.Lines.Text := FText;
end;

procedure TChildForm.Button1Click(Sender: TObject);
begin
  Chromium1.LoadURL(Edit1.Text);
end;

procedure TChildForm.Button2Click(Sender: TObject);
var
  TempManager : ICefCookieManager;
begin
//    FText := '';
    TempManager := TCefRequestContextRef.Global.GetDefaultCookieManager(nil);
    TempManager.VisitAllCookies(FVisitor);
    Memo1.Lines.Text := FText;
end;

function Explode(const str: string; const separator: string): TStrings;
var
  n: integer;
  p, q, s: PChar;
  item: string;
begin

  Result := TStringList.Create;
  try
    p := PChar(str);
    s := PChar(separator);
    n := Length(separator);
    repeat
      q := StrPos(p, s);
      if q = nil then q := StrScan(p, #0);
      SetString(item, p, q - p);
      Result.Add(item);
      p := q + n;
    until q^ = #0;
  except
    item := '';
    Result.Free;
    raise;
  end;
end;

procedure TChildForm.Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  PostMessage(Handle, CEFBROWSER_CREATED, 0, 0);
end;

procedure TChildForm.Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  FCanClose := True;
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TChildForm.Chromium1BeforePopup(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
  targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
  userGesture: Boolean; const popupFeatures: TCefPopupFeatures;
  var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings; var noJavascriptAccess: Boolean;
  var Result: Boolean);
begin
  // For simplicity, this demo blocks all popup windows and new tabs
  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;

procedure TChildForm.Chromium1BeforeResourceLoad(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const callback: ICefRequestCallback;
  out Result: TCefReturnValue);
var
 Header: ICefStringMultimap;
begin
  Header := TCefStringMultimapOwn.Create;
  Header.Clear;
  Header.Append('Content-Type', 'application/x-www-form-urlencoded');
  Header.Append('User-Agent', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) '+
  'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36');
  Request.SetHeaderMap(Header);
end;

procedure TChildForm.Chromium1Close(Sender: TObject; const browser: ICefBrowser; out Result: Boolean);
begin
  PostMessage(Handle, CEFBROWSER_DESTROY, 0, 0);
  Result := False;
end;

procedure TChildForm.Chromium1LoadEnd(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  TempManager : ICefCookieManager;
  NewChildContext : ICefRequestContext;
begin
  if Pos('google.com',frame.Url) <>0 then
  begin
    FText := '';
    TempManager := NewChildContext.GetDefaultCookieManager(nil);
    TempManager.VisitAllCookies(FVisitor);
    Memo1.Lines.Text := FText;
  end;
end;

procedure TChildForm.Chromium1LoadingStateChange(Sender: TObject; const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
begin
  if isLoading then
    begin
      StatusBar1.Panels[0].Text := 'Loading...';
      cursor := crAppStart;
    end
   else
    begin
      StatusBar1.Panels[0].Text := '';
      cursor := crDefault;
    end;
end;

procedure TChildForm.Chromium1StatusMessage(Sender: TObject; const browser: ICefBrowser; const value: ustring);
begin
  StatusBar1.Panels[1].Text := value;
end;

procedure TChildForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TChildForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FCanClose;

  if not(FClosing) and Panel1.Enabled then
    begin
      FClosing       := True;
      Panel1.Enabled := False;
      Chromium1.CloseBrowser(True);
    end;
end;

procedure TChildForm.FormCreate(Sender: TObject);
begin
  FVisitor  := TCefFastCookieVisitor.Create(CookieVisitorProc);
  FCanClose := False;
  FClosing  := False;
end;

procedure TChildForm.FormDestroy(Sender: TObject);
begin
  // Tell the main form that a child has been destroyed.
  // The main form will check if this was the last child to close itself
  FVisitor := nil;
  PostMessage(MainForm.Handle, CEFBROWSER_CHILDDESTROYED, 0, 0);
end;

procedure TChildForm.FormShow(Sender: TObject);
var
  TempContext : ICefRequestContext;
begin
  TempContext := TCefRequestContextRef.New('', '', False, False, False, False);
  Chromium1.CreateBrowser(CEFWindowParent1, '', TempContext);
end;

procedure TChildForm.WMMove(var aMessage : TWMMove);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TChildForm.WMMoving(var aMessage : TMessage);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TChildForm.WMEnterMenuLoop(var aMessage: TMessage);
begin
  inherited;
  if (aMessage.wParam = 0) and (GlobalCEFApp <> nil) then GlobalCEFApp.OsmodalLoop := True;
end;

procedure TChildForm.WMExitMenuLoop(var aMessage: TMessage);
begin
  inherited;
  if (aMessage.wParam = 0) and (GlobalCEFApp <> nil) then GlobalCEFApp.OsmodalLoop := False;
end;

procedure TChildForm.BrowserCreatedMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.UpdateSize;
  Panel1.Enabled := True;
  Button1.Click;
end;

procedure TChildForm.BrowserDestroyMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.Free;
end;

end.
