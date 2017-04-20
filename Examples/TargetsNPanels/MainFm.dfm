object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Targets'#39'n'#39'Panels'
  ClientHeight = 306
  ClientWidth = 537
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
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 121
    Height = 13
    Caption = 'Primary Rendering Panel:'
  end
  object Label2: TLabel
    Left = 270
    Top = 5
    Width = 126
    Height = 13
    Caption = 'Auxiliary Rendering Panel:'
  end
  object PrimaryPanel: TPanel
    Left = 8
    Top = 24
    Width = 256
    Height = 256
    TabOrder = 0
  end
  object AuxiliaryPanel: TPanel
    Left = 270
    Top = 24
    Width = 256
    Height = 256
    TabOrder = 1
  end
end
