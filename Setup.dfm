object frmSetup: TfrmSetup
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 505
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 447
    Height = 63
    Align = alTop
    BiDiMode = bdLeftToRight
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1095#1090#1077#1085#1080#1103
    ParentBiDiMode = False
    TabOrder = 0
    object Label1: TLabel
      Left = 13
      Top = 28
      Width = 99
      Height = 16
      Caption = #1058#1072#1081#1084#1072#1091#1090' '#1095#1090#1077#1085#1080#1103':'
    end
    object Label2: TLabel
      Left = 212
      Top = 28
      Width = 14
      Height = 16
      Caption = #1084#1089
    end
    object Label3: TLabel
      Left = 258
      Top = 28
      Width = 59
      Height = 16
      Caption = #1057#1082#1086#1088#1086#1089#1090#1100':'
    end
    object speReadTimeOut: TSpinEdit
      Left = 118
      Top = 25
      Width = 87
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object cbxBaudRate: TComboBox
      Left = 318
      Top = 25
      Width = 120
      Height = 24
      TabOrder = 1
      Items.Strings = (
        '110'
        '300'
        '600'
        '1200'
        '2400'
        '4800'
        '9600'
        '14400'
        '19200'
        '38400'
        '56000'
        '57600'
        '115200')
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 63
    Width = 447
    Height = 208
    Align = alTop
    Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
    TabOrder = 1
    object Label4: TLabel
      Left = 13
      Top = 24
      Width = 215
      Height = 16
      Caption = #1048#1084#1103'/IP-'#1072#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093':'
    end
    object Label5: TLabel
      Left = 13
      Top = 75
      Width = 232
      Height = 16
      Caption = #1051#1086#1082#1072#1083#1100#1085#1099#1081' '#1087#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093':'
    end
    object Label6: TLabel
      Left = 13
      Top = 127
      Width = 214
      Height = 16
      Caption = #1057#1090#1088#1086#1082#1072' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' '#1089' '#1073#1072#1079#1086#1081' '#1076#1072#1085#1085#1099#1093':'
    end
    object sLabel1: TLabel
      Left = 13
      Top = 182
      Width = 124
      Height = 16
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1073#1072#1079#1086#1081':'
    end
    object edtSrvStr: TEdit
      Left = 13
      Top = 46
      Width = 185
      Height = 24
      TabOrder = 0
      Text = 'srv-pr'
      OnChange = edtSrvStrChange
    end
    object edtFBDStr: TEdit
      Left = 13
      Top = 96
      Width = 338
      Height = 24
      TabOrder = 1
      OnChange = edtFBDStrChange
    end
    object edtConnectionStr: TEdit
      Left = 13
      Top = 149
      Width = 425
      Height = 24
      TabOrder = 2
    end
    object sbtbtnOpenBase: TBitBtn
      Left = 360
      Top = 96
      Width = 78
      Height = 25
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 3
      OnClick = sbtbtnOpenBaseClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 271
    Width = 447
    Height = 186
    Align = alTop
    Caption = #1040#1074#1090#1086#1086#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1080' '#1083#1086#1075' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
    TabOrder = 2
    object Label7: TLabel
      Left = 13
      Top = 47
      Width = 275
      Height = 16
      Caption = #1050#1072#1090#1072#1083#1086#1075' '#1087#1088#1086#1074#1077#1088#1082#1080' '#1085#1086#1074#1086#1081' '#1074#1077#1088#1089#1080#1080' '#1087#1088#1086#1075#1088#1072#1084#1084#1084#1099': '
    end
    object Label8: TLabel
      Left = 13
      Top = 99
      Width = 165
      Height = 16
      Caption = #1054#1073#1097#1080#1081' '#1087#1091#1090#1100' '#1082' '#1087#1072#1087#1082#1077' '#1083#1086#1075#1086#1074': '
    end
    object cbxAutoUpdate: TCheckBox
      Left = 13
      Top = 24
      Width = 185
      Height = 17
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1072#1074#1090#1086#1086#1073#1085#1086#1074#1083#1077#1085#1080#1077
      TabOrder = 0
      OnClick = cbxAutoUpdateClick
    end
    object edtUpdatePath: TEdit
      Left = 13
      Top = 69
      Width = 338
      Height = 24
      TabOrder = 1
    end
    object edtLogPath: TEdit
      Left = 13
      Top = 121
      Width = 338
      Height = 24
      TabOrder = 2
    end
    object btnUpdPath: TBitBtn
      Left = 360
      Top = 69
      Width = 78
      Height = 24
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 3
      OnClick = btnUpdPathClick
    end
    object sbtbtnLogPath: TBitBtn
      Left = 360
      Top = 121
      Width = 78
      Height = 24
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 4
      OnClick = sbtbtnLogPathClick
    end
    object chkExtendedLog: TCheckBox
      Left = 13
      Top = 155
      Width = 202
      Height = 17
      Caption = #1042#1099#1074#1086#1076' '#1088#1072#1089#1096#1080#1088#1077#1085#1085#1099#1093' '#1083#1086#1075#1086#1074
      TabOrder = 5
    end
  end
  object sbtbtnSave: TBitBtn
    Left = 172
    Top = 466
    Width = 116
    Height = 34
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = sbtbtnSaveClick
  end
  object sbtbtnSignOut: TBitBtn
    Left = 323
    Top = 466
    Width = 116
    Height = 34
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 4
    OnClick = sbtbtnSignOutClick
  end
  object fodDatabase: TFileOpenDialog
    DefaultExtension = 'FDB'
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPathMustExist, fdoFileMustExist]
    Left = 384
    Top = 99
  end
  object fodUpdate: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1103
        FileMask = '*.exe'
      end>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 309
    Top = 294
  end
  object flpndlgLog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1103
        FileMask = '*.exe'
      end>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 381
    Top = 302
  end
end
