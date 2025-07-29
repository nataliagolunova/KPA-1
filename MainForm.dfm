object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'KPA_1'
  ClientHeight = 821
  ClientWidth = 948
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 18
  object pnlTop: TPanel
    Left = 0
    Top = 22
    Width = 948
    Height = 48
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 14
      Width = 47
      Height = 16
      Caption = 'QR-'#1082#1086#1076':'
    end
    object Label2: TLabel
      Left = 419
      Top = 15
      Width = 46
      Height = 16
      Caption = #1055#1088#1077#1089#1077#1090':'
    end
    object edtFocusSerial: TEdit
      Left = 66
      Top = 11
      Width = 296
      Height = 24
      TabOrder = 0
      OnChange = edtFocusSerialChange
    end
    object cbbPreset: TDBLookupComboboxEh
      Left = 471
      Top = 11
      Width = 304
      Height = 24
      DynProps = <>
      DataField = ''
      DropDownBox.Options = [dlgColLinesEh, dlgAutoFitRowHeightEh]
      DropDownBox.Rows = 20
      EditButtons = <>
      KeyField = 'ID'
      ListField = 'NAME_PRESET'
      ListSource = DataMod.dsCV1Settings
      TabOrder = 1
      Visible = True
      OnCloseUp = cbbPresetCloseUp
    end
  end
  object spnlCenter: TPanel
    Left = 0
    Top = 70
    Width = 948
    Height = 557
    Align = alClient
    TabOrder = 1
    DesignSize = (
      948
      557)
    object Splitter1: TSplitter
      Left = 1
      Top = 549
      Width = 946
      Height = 7
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 551
    end
    object sPanel1: TPanel
      Left = 10
      Top = 2
      Width = 306
      Height = 268
      TabOrder = 0
    end
    object sPanel2: TPanel
      Left = 322
      Top = 4
      Width = 306
      Height = 268
      Anchors = [akTop]
      TabOrder = 1
    end
    object sPanel3: TPanel
      Left = 634
      Top = 4
      Width = 306
      Height = 268
      Anchors = [akTop, akRight]
      TabOrder = 2
    end
    object sPanel4: TPanel
      Left = 10
      Top = 276
      Width = 306
      Height = 268
      Anchors = [akLeft, akBottom]
      TabOrder = 3
    end
    object sPanel5: TPanel
      Left = 322
      Top = 276
      Width = 306
      Height = 268
      Anchors = [akBottom]
      TabOrder = 4
    end
    object sPanel6: TPanel
      Left = 634
      Top = 276
      Width = 306
      Height = 268
      Anchors = [akRight, akBottom]
      TabOrder = 5
    end
  end
  object spnlBottom: TPanel
    Left = 0
    Top = 627
    Width = 948
    Height = 194
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = spnlBottomClick
    DesignSize = (
      948
      194)
    object Label3: TLabel
      Left = 10
      Top = 1
      Width = 29
      Height = 18
      Caption = #1051#1086#1075':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object redtLog: TRichEdit
      Left = 10
      Top = 20
      Width = 927
      Height = 150
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      HideScrollBars = False
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      WantTabs = True
      OnClick = redtLogClick
    end
    object sStatusBar1: TStatusBar
      Left = 1
      Top = 174
      Width = 946
      Height = 19
      Panels = <
        item
          Width = 50
        end>
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 948
    Height = 22
    ButtonWidth = 173
    Caption = 'ToolBar1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    List = True
    ParentFont = False
    ParentShowHint = False
    ShowCaptions = True
    ShowHint = False
    TabOrder = 3
    Transparent = False
    Wrapable = False
    object btnSetup: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      OnClick = btnSetupClick
    end
    object btnDownSetup: TToolButton
      Left = 72
      Top = 0
      AutoSize = True
      Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1085#1072#1089#1090#1088#1086#1077#1082' '#1050#1055#1040
      ImageIndex = 0
      OnClick = btnDownSetupClick
    end
    object btnDownMeterPO: TToolButton
      Left = 223
      Top = 0
      AutoSize = True
      Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1055#1054' '#1076#1083#1103' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
      ImageIndex = 1
      OnClick = btnDownMeterPOClick
    end
    object btnAutoHW: TToolButton
      Left = 400
      Top = 0
      AutoSize = True
      Caption = #1040#1074#1090#1086#1086#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1087#1088#1086#1096#1080#1074#1086#1082
      ImageIndex = 2
      OnClick = btnAutoHWClick
    end
  end
  object tmrLog: TTimer
    OnTimer = tmrLogTimer
    Left = 774
    Top = 62
  end
  object tmrWriteSerial: TTimer
    Enabled = False
    OnTimer = tmrWriteSerialTimer
    Left = 58
    Top = 74
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer1Timer
    Left = 872
    Top = 54
  end
end
