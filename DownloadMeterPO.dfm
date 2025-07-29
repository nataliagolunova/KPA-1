object frmDownloadMeterPO: TfrmDownloadMeterPO
  Left = 0
  Top = 0
  Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1055#1054' '#1076#1083#1103' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
  ClientHeight = 310
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 84
    Height = 16
    Caption = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072':'
  end
  object Label2: TLabel
    Left = 16
    Top = 61
    Width = 81
    Height = 16
    Caption = #1071#1095#1077#1081#1082#1072' '#1050#1055#1040'-1'
  end
  object Gauge1: TGauge
    Left = 116
    Top = 125
    Width = 178
    Height = 17
    Progress = 0
  end
  object Gauge2: TGauge
    Left = 116
    Top = 157
    Width = 178
    Height = 17
    Progress = 0
  end
  object Gauge3: TGauge
    Left = 116
    Top = 189
    Width = 178
    Height = 17
    Progress = 0
  end
  object Gauge4: TGauge
    Left = 116
    Top = 221
    Width = 178
    Height = 17
    Progress = 0
  end
  object Gauge5: TGauge
    Left = 116
    Top = 253
    Width = 178
    Height = 17
    Progress = 0
  end
  object Gauge6: TGauge
    Left = 116
    Top = 285
    Width = 178
    Height = 17
    Progress = 0
  end
  object edtFilePO: TEdit
    Left = 16
    Top = 30
    Width = 278
    Height = 24
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 300
    Top = 30
    Width = 85
    Height = 25
    Caption = #1054#1073#1079#1086#1088
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object DBLookupComboBox1: TDBLookupComboBox
    Left = 16
    Top = 83
    Width = 369
    Height = 24
    TabOrder = 2
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 125
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-1 1 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object CheckBox2: TCheckBox
    Left = 16
    Top = 157
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-1 2 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object CheckBox3: TCheckBox
    Left = 16
    Top = 189
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-1 3 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object CheckBox4: TCheckBox
    Left = 16
    Top = 221
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-1 4 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object CheckBox5: TCheckBox
    Left = 16
    Top = 253
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-15 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object CheckBox6: TCheckBox
    Left = 16
    Top = 285
    Width = 97
    Height = 17
    Caption = #1050#1055#1040'-1 6 '#1089#1083#1086#1090
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object BitBtn2: TBitBtn
    Left = 300
    Top = 125
    Width = 85
    Height = 177
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 9
    OnClick = BitBtn2Click
  end
  object cbbCell: TComboBox
    Left = 16
    Top = 83
    Width = 369
    Height = 24
    ItemIndex = 0
    TabOrder = 10
    Text = 'Test L433'
    Items.Strings = (
      'Test L433'
      'Release '#1057#1052#1058'-'#1057#1084#1072#1088#1090' L433'
      'Release '#1057#1052#1058'-'#1057#1084#1072#1088#1090' '#1050' L433'
      'Release '#1057#1052#1058'-'#1057#1084#1072#1088#1090' '#1044#1050#1047' L433')
  end
  object dlgFileMeterPO: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPathMustExist, fdoFileMustExist]
    Left = 195
    Top = 18
  end
end
