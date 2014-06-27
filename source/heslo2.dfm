object Form5: TForm5
  Left = 424
  Top = 392
  BorderStyle = bsDialog
  Caption = 'Z'#237'sk'#225'n'#237' hesla'
  ClientHeight = 135
  ClientWidth = 290
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 89
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 235
      Height = 13
      Caption = 'Z'#225'lo'#382'n'#237' soubor je pod heslem. Zadejte jeho zn'#283'n'#237':'
    end
    object Label2: TLabel
      Left = 16
      Top = 48
      Width = 30
      Height = 13
      Caption = 'Heslo:'
    end
    object Edit1: TEdit
      Left = 80
      Top = 44
      Width = 169
      Height = 21
      MaxLength = 80
      PasswordChar = '*'
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 112
    Top = 104
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 200
    Top = 104
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Zru'#353'it'
    TabOrder = 2
    OnClick = Button2Click
  end
end
