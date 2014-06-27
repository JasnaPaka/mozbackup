object Form4: TForm4
  Left = 615
  Top = 394
  BorderStyle = bsDialog
  Caption = 'Zad'#225'n'#237' hesla'
  ClientHeight = 181
  ClientWidth = 275
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
    Width = 257
    Height = 121
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 216
      Height = 13
      Caption = 'Zadejte heslo, kter'#253'm bude soubor podm'#237'n'#283'n.'
    end
    object Label2: TLabel
      Left = 16
      Top = 58
      Width = 30
      Height = 13
      Caption = 'Heslo:'
    end
    object Label3: TLabel
      Left = 16
      Top = 84
      Width = 62
      Height = 13
      Caption = 'Znovu heslo:'
    end
    object Bevel1: TBevel
      Left = 16
      Top = 40
      Width = 217
      Height = 2
    end
    object Edit1: TEdit
      Left = 112
      Top = 54
      Width = 121
      Height = 21
      MaxLength = 80
      PasswordChar = '*'
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 112
      Top = 80
      Width = 121
      Height = 21
      MaxLength = 80
      PasswordChar = '*'
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 88
    Top = 144
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 184
    Top = 144
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Zru'#353'it'
    TabOrder = 2
    OnClick = Button2Click
  end
end
