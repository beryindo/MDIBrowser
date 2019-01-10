unit uMainForm;

{$I cef.inc}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Dialogs, Vcl.Buttons, Winapi.Messages,
  Vcl.ExtCtrls, Vcl.ComCtrls;

const
  CEFBROWSER_SHOWCOOKIES      = WM_APP + $100;
  CEFBROWSER_CREATED          = WM_APP + $101;
  CEFBROWSER_CHILDDESTROYED   = WM_APP + $102;
  CEFBROWSER_DESTROY          = WM_APP + $103;
  CEFBROWSER_INITIALIZED      = WM_APP + $104;

type
  TMainForm = class(TForm)
    ButtonPnl: TPanel;
    NewBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bMulaiClick(Sender: TObject);
  private
    // Variables to control when can we destroy the form safely
    FCanClose     : boolean;  // Set to True when all the child forms are closed
    FClosing      : boolean;  // Set to True in the CloseQuery event.
    FBrowserCount : integer;

    procedure CreateMDIChild(const Name: string);
    procedure CloseAllChildForms;
    function  GetChildClosing : boolean;

  protected
    procedure ChildDestroyedMsg(var aMessage : TMessage); message CEFBROWSER_CHILDDESTROYED;
    procedure CEFInitializedMsg(var aMessage : TMessage); message CEFBROWSER_INITIALIZED;

  public
    function CloseQuery: Boolean; override;

    property ChildClosing : boolean read GetChildClosing;
    property BrowserCount : integer read FBrowserCount;
  end;

var
  MainForm: TMainForm;

procedure CreateGlobalCEFApp;

implementation

{$R *.dfm}

uses
  uChildForm, uCEFApplication;

// Destruction steps
// =================
// 1. Destroy all child forms
// 2. Wait until all the child forms are closed before closing the main form and terminating the application.

procedure GlobalCEFApp_OnContextInitialized;
begin
  if (MainForm <> nil) and MainForm.HandleAllocated then
    PostMessage(MainForm.Handle, CEFBROWSER_INITIALIZED, 0, 0);
end;

procedure CreateGlobalCEFApp;
begin
  GlobalCEFApp                      := TCefApplication.Create;
  GlobalCEFApp.OnContextInitialized := GlobalCEFApp_OnContextInitialized;
end;

procedure TMainForm.CreateMDIChild(const Name: string);
var
  TempChild : TChildForm;
begin
  TempChild         := TChildForm.Create(Application);
  TempChild.Caption := Name;
end;

procedure TMainForm.CloseAllChildForms;
var
  i : integer;
begin
  i := pred(MDIChildCount);

  while (i >= 0) do
    begin
      if not(TChildForm(MDIChildren[i]).Closing) then
        PostMessage(MDIChildren[i].Handle, WM_CLOSE, 0, 0);

      dec(i);
    end;
end;

function TMainForm.GetChildClosing : boolean;
var
  i : integer;
begin
  Result := false;
  i      := pred(MDIChildCount);

  while (i >= 0) do
    if TChildForm(MDIChildren[i]).Closing then
      begin
        Result := True;
        exit;
      end
     else
      dec(i);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FCanClose     := False;
  FClosing      := False;
  FBrowserCount := 0;
end;

procedure TMainForm.NewBtnClick(Sender: TObject);
begin
  inc(FBrowserCount);
  CreateMDIChild('Facebook' + IntToStr(FBrowserCount));
end;

procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  ButtonPnl.Enabled := False;

  if (MDIChildCount = 0) then
    Close
   else
    CloseAllChildForms;
end;

procedure TMainForm.ChildDestroyedMsg(var aMessage : TMessage);
begin
  // If there are no more child forms we can destroy the main form
  if (MDIChildCount = 0) then
    begin
      ButtonPnl.Enabled := False;
      FCanClose := True;
      PostMessage(Handle, WM_CLOSE, 0, 0);
    end;
end;

procedure TMainForm.bMulaiClick(Sender: TObject);
begin
  inc(FBrowserCount);
  CreateMDIChild('MDI' + IntToStr(FBrowserCount));
end;

procedure TMainForm.CEFInitializedMsg(var aMessage : TMessage);
begin
  Caption           := 'MDI';
  ButtonPnl.Enabled := True;
  cursor            := crDefault;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if (GlobalCEFApp <> nil) and GlobalCEFApp.GlobalContextInitialized then
    begin
      Caption           := 'MDI';
      ButtonPnl.Enabled := True;
      cursor            := crDefault;
    end;
end;

function TMainForm.CloseQuery: Boolean;
begin
  if FClosing or ChildClosing then
    Result := FCanClose
   else
    begin
      FClosing := True;

      if (MDIChildCount = 0) then
        Result := True
       else
        begin
          Result := False;
          CloseAllChildForms;
        end;
    end;
end;

end.
