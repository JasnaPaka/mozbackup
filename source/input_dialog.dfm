object Form2: TForm2
  Left = 560
  Top = 205
  BorderStyle = bsDialog
  Caption = 'Nov'#253' profil'
  ClientHeight = 154
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 140
    Height = 13
    Caption = 'Zadejte jm'#233'no nov'#233'ho profilu:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 16
    Top = 24
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 64
    Top = 120
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 168
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Zru'#353'it'
    TabOrder = 2
    OnClick = Button2Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 56
    Width = 281
    Height = 49
    Caption = 'Location:'
    TabOrder = 3
    object Label2: TLabel
      Left = 10
      Top = 22
      Width = 99
      Height = 13
      Caption = 'Not implemented yet!'
      ParentShowHint = False
      ShowHint = True
    end
    object Button3: TButton
      Left = 200
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 0
      OnClick = Button3Click
    end
  end
end
