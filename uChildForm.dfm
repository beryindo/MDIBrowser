object ChildForm: TChildForm
  Left = 197
  Top = 117
  Caption = 'MDI Child'
  ClientHeight = 451
  ClientWidth = 708
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 708
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    Enabled = False
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    ShowCaption = False
    TabOrder = 0
    object Edit1: TEdit
      Left = 5
      Top = 5
      Width = 667
      Height = 20
      Margins.Right = 5
      Align = alClient
      TabOrder = 0
      Text = 'https://google.com'
      ExplicitHeight = 21
    end
    object Button1: TButton
      Left = 672
      Top = 5
      Width = 31
      Height = 20
      Margins.Left = 5
      Align = alRight
      Caption = 'Go'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 30
    Width = 708
    Height = 402
    Align = alClient
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 432
    Width = 708
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 500
      end>
  end
  object Memo1: TMemo
    Left = 8
    Top = 31
    Width = 417
    Height = 169
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
    WordWrap = False
  end
  object Chromium1: TChromium
    OnLoadEnd = Chromium1LoadEnd
    OnLoadingStateChange = Chromium1LoadingStateChange
    OnStatusMessage = Chromium1StatusMessage
    OnBeforePopup = Chromium1BeforePopup
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    OnBeforeResourceLoad = Chromium1BeforeResourceLoad
    Left = 40
    Top = 184
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    Left = 32
    Top = 280
  end
  object NetHTTPClient1: TNetHTTPClient
    AllowCookies = True
    HandleRedirects = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 440
    Top = 112
  end
end
