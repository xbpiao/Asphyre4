object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Asphyre 4: GUI Example'
  ClientHeight = 376
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 357
    Width = 585
    Height = 19
    Panels = <>
  end
  object XPManifest1: TXPManifest
    Left = 504
    Top = 440
  end
end
