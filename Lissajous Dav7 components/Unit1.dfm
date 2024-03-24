object Form1: TForm1
  Left = 192
  Top = 124
  Width = 745
  Height = 656
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 16
    Top = 16
    Width = 75
    Height = 25
    Caption = 'create'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 56
    Width = 75
    Height = 25
    Caption = 'hist'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 16
    Top = 128
    Width = 75
    Height = 25
    Caption = 'nohist'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 16
    Top = 176
    Width = 75
    Height = 25
    Caption = 'example'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 16
    Top = 208
    Width = 75
    Height = 25
    Caption = 'no-example'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 16
    Top = 88
    Width = 75
    Height = 25
    Caption = 'update'
    TabOrder = 5
    OnClick = Button6Click
  end
end
