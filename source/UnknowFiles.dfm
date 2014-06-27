object UnknowFilesFM: TUnknowFilesFM
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Unknow files'
  ClientHeight = 327
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 8
    Top = 8
    Width = 228
    Height = 35
    AutoSize = False
    Caption = 
      'Check unknow files in your profile which you want to backup/rest' +
      'ore:'
    TabOrder = 0
  end
  object CheckListBox1: TCheckListBox
    Left = 8
    Top = 49
    Width = 228
    Height = 208
    ItemHeight = 13
    TabOrder = 1
  end
  object Button1: TButton
    Left = 72
    Top = 286
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 161
    Top = 286
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 263
    Width = 228
    Height = 17
    Caption = 'Select/Deselect all'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBox1Click
  end
end
