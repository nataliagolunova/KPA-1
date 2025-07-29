object frmDownloadSetup: TfrmDownloadSetup
  Left = 0
  Top = 0
  Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1085#1072#1089#1090#1088#1086#1077#1082' '#1050#1055#1040'-1'
  ClientHeight = 254
  ClientWidth = 407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmExplicit
  PopupParent = frmMainForm.Owner
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 71
    Height = 13
    Caption = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072':'
  end
  object edtSetupKPA: TEdit
    Left = 16
    Top = 30
    Width = 286
    Height = 21
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 308
    Top = 30
    Width = 85
    Height = 25
    Caption = #1054#1073#1079#1086#1088
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 308
    Top = 61
    Width = 85
    Height = 185
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 2
    OnClick = BitBtn2Click
  end
  object CheckListBox1: TCheckListBox
    Left = 16
    Top = 61
    Width = 94
    Height = 185
    ItemHeight = 30
    Items.Strings = (
      #1050#1055#1040'-1 1 '#1089#1083#1086#1090
      #1050#1055#1040'-2 2 '#1089#1083#1086#1090
      #1050#1055#1040'-3 3 '#1089#1083#1086#1090
      #1050#1055#1040'-4 4 '#1089#1083#1086#1090
      #1050#1055#1040'-5 5 '#1089#1083#1086#1090
      #1050#1055#1040'-6 6 '#1089#1083#1086#1090)
    Style = lbOwnerDrawFixed
    TabOrder = 3
  end
  object Panel1: TPanel
    Left = 116
    Top = 61
    Width = 186
    Height = 185
    TabOrder = 4
    object Gauge1: TGauge
      Left = 4
      Top = 8
      Width = 178
      Height = 17
      Progress = 0
    end
    object Gauge2: TGauge
      Left = 4
      Top = 38
      Width = 178
      Height = 17
      Progress = 0
    end
    object Gauge3: TGauge
      Left = 4
      Top = 68
      Width = 178
      Height = 17
      Progress = 0
    end
    object Gauge4: TGauge
      Left = 4
      Top = 99
      Width = 178
      Height = 17
      Progress = 0
    end
    object Gauge5: TGauge
      Left = 4
      Top = 129
      Width = 178
      Height = 17
      Progress = 0
    end
    object Gauge6: TGauge
      Left = 4
      Top = 160
      Width = 178
      Height = 17
      Progress = 0
    end
  end
  object dlgFileSetupKPA: TFileOpenDialog
    DefaultExtension = 'OPT'
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPathMustExist, fdoFileMustExist]
    Left = 243
    Top = 10
  end
end
