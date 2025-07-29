object frmAutor: TfrmAutor
  Left = 0
  Top = 0
  Anchors = [akLeft, akTop, akRight, akBottom]
  Caption = 'KPA-1. '#1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103
  ClientHeight = 144
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 18
  object sbtbtnSignIn: TsBitBtn
    Left = 78
    Top = 97
    Width = 129
    Height = 38
    Caption = #1042#1086#1081#1090#1080
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 0
    OnClick = sbtbtnSignInClick
  end
  object sbtbtnSignOut: TsBitBtn
    Left = 254
    Top = 97
    Width = 129
    Height = 38
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    Kind = bkCancel
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 1
    OnClick = sbtbtnSignOutClick
  end
  object edtPassword: TsEdit
    Left = 78
    Top = 55
    Width = 305
    Height = 26
    PasswordChar = '*'
    TabOrder = 2
    BoundLabel.Active = True
    BoundLabel.Indent = 10
    BoundLabel.Caption = #1055#1072#1088#1086#1083#1100':'
  end
  object cbbLoginSecuser: TDBLookupComboboxEh
    Left = 78
    Top = 15
    Width = 305
    Height = 26
    ControlLabel.Width = 45
    ControlLabel.Height = 18
    ControlLabel.BiDiMode = bdLeftToRight
    ControlLabel.Caption = #1051#1086#1075#1080#1085':'
    ControlLabel.ParentBiDiMode = False
    ControlLabel.Visible = True
    ControlLabelLocation.Spacing = 14
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    DataField = ''
    DropDownBox.Options = [dlgColumnResizeEh, dlgColLinesEh]
    DropDownBox.Sizable = True
    DropDownBox.Width = 30
    EditButtons = <>
    KeyField = 'ID'
    ListField = 'SAMACCOUNTNAME'
    ListSource = DataMod.dsSecuser
    TabOrder = 3
    Visible = True
  end
end
