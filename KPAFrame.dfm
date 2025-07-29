object frameKPA: TframeKPA
  Left = 0
  Top = 0
  Width = 306
  Height = 268
  Align = alClient
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object grpKPA: TGroupBox
    Left = 0
    Top = 0
    Width = 306
    Height = 268
    Align = alClient
    BiDiMode = bdLeftToRight
    Caption = #1042#1077#1088#1089#1080#1103' '#1055#1054' '#1050#1055#1040' '#1080' '#1077#1075#1086' '#1089#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    Color = clWhite
    DoubleBuffered = False
    ParentBackground = False
    ParentBiDiMode = False
    ParentColor = False
    ParentDoubleBuffered = False
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 29
      Width = 33
      Height = 16
      Caption = #1055#1086#1088#1090':'
    end
    object Label2: TLabel
      Left = 10
      Top = 55
      Width = 144
      Height = 16
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088' '#1087#1083#1072#1090#1099':'
    end
    object lblStatus: TLabel
      AlignWithMargins = True
      Left = 10
      Top = 101
      Width = 131
      Height = 16
      Caption = #1057#1090#1072#1090#1091#1089' '#1050#1055#1040' '#1080' '#1087#1086#1088#1090#1072
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNone
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object Shape1: TShape
      Left = 10
      Top = 125
      Width = 288
      Height = 107
      Pen.Color = clGray
      Pen.Width = 3
    end
    object cbbPort: TComboBox
      Left = 58
      Top = 26
      Width = 240
      Height = 24
      TabOrder = 0
      Text = #1042#1099#1073#1077#1088#1080#1090#1077' '#1087#1086#1088#1090
      OnChange = cbbPortChange
    end
    object edtSerialChip: TEdit
      Left = 10
      Top = 73
      Width = 288
      Height = 24
      ReadOnly = True
      TabOrder = 1
    end
    object btnRepeat: TButton
      Left = 10
      Top = 237
      Width = 288
      Height = 25
      Caption = #1055#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
      TabOrder = 3
      OnClick = btnRepeatClick
    end
    object redtComment: TRichEdit
      Left = 13
      Top = 128
      Width = 282
      Height = 101
      BorderWidth = 4
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 2
    end
  end
end
