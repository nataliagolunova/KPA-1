object DataMod: TDataMod
  Height = 270
  Width = 297
  object IBTransaction1: TIBTransaction
    DefaultDatabase = IBDatabase1
    Params.Strings = (
      '')
    Left = 112
    Top = 198
  end
  object IBXConnectionProviderEh1: TIBXConnectionProviderEh
    Database = IBDatabase1
    Left = 208
    Top = 198
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'srv-pr:c:\Prodbase\Prodmeter_TEST_BATP.fdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=UTF8')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    ServerType = 'IBServer'
    Left = 32
    Top = 198
  end
  object ibxddeSecuser: TIBXDataDriverEh
    ConnectionProvider = IBXConnectionProviderEh1
    MacroVars.Macros = <>
    SelectCommand.Params = <>
    SelectCommand.CommandText.Strings = (
      'select'
      '  ID'
      '  ,SAMACCOUNTNAME'
      '  ,FNAME'
      '  ,LNAME'
      '  ,MNAME'
      '  ,FULLNAME'
      '  ,ROLE'
      '  ,STANDID'
      '  ,HESHPASS'
      '  ,ENABLED'
      '  ,COMPANY'
      '  ,EMAIL'
      'from'
      '  SECUSER'
      'where STANDID='#39'21'#39' and ENABLED = 1 '
      'ORDER BY SAMACCOUNTNAME')
    UpdateCommand.Params = <
      item
        DataType = ftUnknown
        Name = 'ID'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'SAMACCOUNTNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'FNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'LNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'MNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'FULLNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ROLE'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'STANDID'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'HESHPASS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ENABLED'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'COMPANY'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'EMAIL'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'OLD_ID'
        ParamType = ptUnknown
      end>
    UpdateCommand.CommandText.Strings = (
      'update SECUSER'
      'set'
      '  ID = :ID,'
      '  SAMACCOUNTNAME = :SAMACCOUNTNAME,'
      '  FNAME = :FNAME,'
      '  LNAME = :LNAME,'
      '  MNAME = :MNAME,'
      '  FULLNAME = :FULLNAME,'
      '  ROLE = :ROLE,'
      '  STANDID = :STANDID,'
      '  HESHPASS = :HESHPASS,'
      '  ENABLED = :ENABLED,'
      '  COMPANY = :COMPANY,'
      '  EMAIL = :EMAIL'
      'where'
      '  ID = :OLD_ID')
    InsertCommand.Params = <
      item
        DataType = ftAutoInc
        Name = 'ID'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'SAMACCOUNTNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'FNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'LNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'MNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'FULLNAME'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ROLE'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'STANDID'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'HESHPASS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ENABLED'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'COMPANY'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'EMAIL'
        ParamType = ptUnknown
      end>
    InsertCommand.CommandText.Strings = (
      'insert into SECUSER'
      
        '  (ID, SAMACCOUNTNAME, FNAME, LNAME, MNAME, FULLNAME, ROLE, STAN' +
        'DID, '
      '   HESHPASS, ENABLED, COMPANY, EMAIL)'
      'values'
      
        '  (:ID, :SAMACCOUNTNAME, :FNAME, :LNAME, :MNAME, :FULLNAME, :ROL' +
        'E, :STANDID, '
      '   :HESHPASS, :ENABLED, :COMPANY, :EMAIL)')
    DeleteCommand.Params = <
      item
        DataType = ftUnknown
        Name = 'OLD_ID'
        ParamType = ptUnknown
      end>
    DeleteCommand.CommandText.Strings = (
      'delete from SECUSER'
      'where'
      '  ID = :OLD_ID')
    GetrecCommand.Params = <
      item
        DataType = ftUnknown
        Name = 'OLD_ID'
        ParamType = ptUnknown
      end>
    GetrecCommand.CommandText.Strings = (
      'select'
      '  ID'
      '  ,SAMACCOUNTNAME'
      '  ,FNAME'
      '  ,LNAME'
      '  ,MNAME'
      '  ,FULLNAME'
      '  ,ROLE'
      '  ,STANDID'
      '  ,HESHPASS'
      '  ,ENABLED'
      '  ,COMPANY'
      '  ,EMAIL'
      'from'
      '  SECUSER'
      'where STANDID='#39'21'#39' and ENABLED = 1'
      'ORDER BY SAMACCOUNTNAME'
      '  ID = :OLD_ID')
    DynaSQLParams.Options = []
    SpecParams.Strings = (
      'AUTO_INCREMENT_FIELD=ID'
      'GENERATOR_FIELD=ID'
      'GENERATOR=SECUSER_ID                                    '
      
        '                                                                ' +
        '              ')
    Left = 32
    Top = 128
  end
  object mteSecuser: TMemTableEh
    FieldDefs = <
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'SAMACCOUNTNAME'
        DataType = ftWideString
        Size = 200
      end
      item
        Name = 'FNAME'
        Attributes = [faRequired]
        DataType = ftWideString
        Size = 200
      end
      item
        Name = 'LNAME'
        Attributes = [faRequired]
        DataType = ftWideString
        Size = 200
      end
      item
        Name = 'MNAME'
        DataType = ftWideString
        Size = 200
      end
      item
        Name = 'FULLNAME'
        DataType = ftWideString
        Size = 1020
      end
      item
        Name = 'ROLE'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'STANDID'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'HESHPASS'
        DataType = ftWideString
        Size = 1020
      end
      item
        Name = 'ENABLED'
        DataType = ftSmallint
        Precision = 15
      end
      item
        Name = 'COMPANY'
        DataType = ftWideString
        Size = 200
      end
      item
        Name = 'EMAIL'
        DataType = ftWideString
        Size = 120
      end>
    FetchAllOnOpen = True
    IndexDefs = <>
    Params = <>
    DataDriver = ibxddeSecuser
    StoreDefs = True
    Left = 32
    Top = 72
    object mteSecuserID: TIntegerField
      FieldName = 'ID'
      Required = True
    end
    object mteSecuserSAMACCOUNTNAME: TWideStringField
      FieldName = 'SAMACCOUNTNAME'
      Size = 200
    end
    object mteSecuserFNAME: TWideStringField
      FieldName = 'FNAME'
      Required = True
      Size = 200
    end
    object mteSecuserLNAME: TWideStringField
      FieldName = 'LNAME'
      Required = True
      Size = 200
    end
    object mteSecuserMNAME: TWideStringField
      FieldName = 'MNAME'
      Size = 200
    end
    object mteSecuserFULLNAME: TWideStringField
      FieldName = 'FULLNAME'
      Size = 1020
    end
    object mteSecuserROLE: TIntegerField
      FieldName = 'ROLE'
      Required = True
    end
    object mteSecuserSTANDID: TIntegerField
      FieldName = 'STANDID'
      Required = True
    end
    object mteSecuserHESHPASS: TWideStringField
      FieldName = 'HESHPASS'
      Size = 1020
    end
    object mteSecuserENABLED: TSmallintField
      FieldName = 'ENABLED'
    end
    object mteSecuserCOMPANY: TWideStringField
      FieldName = 'COMPANY'
      Size = 200
    end
    object mteSecuserEMAIL: TWideStringField
      FieldName = 'EMAIL'
      Size = 120
    end
  end
  object dsSecuser: TDataSource
    DataSet = mteSecuser
    Left = 32
    Top = 8
  end
  object ibxdtdrvrhCV1Settings: TIBXDataDriverEh
    ConnectionProvider = IBXConnectionProviderEh1
    MacroVars.Macros = <>
    SelectCommand.Params = <>
    SelectCommand.CommandText.Strings = (
      'select'
      '  ID'
      '  ,METEREVENTTYPEID'
      '  ,NAME_TEST_FIRMWARE'
      '  ,NAME_RELEASE_FIRMWARE'
      '  ,FILE_NAME_EEPROM'
      '  ,NAME_PRESET'
      '  ,ACTIVE_PRESET'
      '  ,ENABLE_SCRIPT'
      '  ,BOARDTYPEID'
      '  ,DECCODEID'
      'from'
      '  CVE1SETTINGS'
      'where ACTIVE_PRESET = 1')
    UpdateCommand.Params = <>
    InsertCommand.Params = <>
    DeleteCommand.Params = <>
    GetrecCommand.Params = <>
    DynaSQLParams.Options = []
    Left = 128
    Top = 128
  end
  object mteCV1Settings: TMemTableEh
    FieldDefs = <
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'METEREVENTTYPEID'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'NAME_TEST_FIRMWARE'
        DataType = ftWideString
        Size = 1020
      end
      item
        Name = 'NAME_RELEASE_FIRMWARE'
        DataType = ftWideString
        Size = 1020
      end
      item
        Name = 'FILE_NAME_EEPROM'
        DataType = ftWideString
        Size = 1020
      end
      item
        Name = 'NAME_PRESET'
        Attributes = [faRequired]
        DataType = ftWideString
        Size = 280
      end
      item
        Name = 'ACTIVE_PRESET'
        Attributes = [faRequired]
        DataType = ftSmallint
        Precision = 15
      end
      item
        Name = 'ENABLE_SCRIPT'
        Attributes = [faRequired]
        DataType = ftLargeint
        Precision = 15
      end
      item
        Name = 'NUMBER_SCRIPT_VALVE'
        Attributes = [faRequired]
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'BOARDTYPEID'
        DataType = ftInteger
        Precision = 15
      end
      item
        Name = 'DECCODEID'
        DataType = ftSmallint
        Precision = 15
      end>
    FetchAllOnOpen = True
    IndexDefs = <>
    Params = <>
    DataDriver = ibxdtdrvrhCV1Settings
    StoreDefs = True
    Left = 128
    Top = 72
    object mteCV1SettingsID: TIntegerField
      FieldName = 'ID'
      Required = True
    end
    object mteCV1SettingsMETEREVENTTYPEID: TIntegerField
      FieldName = 'METEREVENTTYPEID'
      Required = True
    end
    object mteCV1SettingsNAME_TEST_FIRMWARE: TWideStringField
      FieldName = 'NAME_TEST_FIRMWARE'
      Size = 1020
    end
    object mteCV1SettingsNAME_RELEASE_FIRMWARE: TWideStringField
      FieldName = 'NAME_RELEASE_FIRMWARE'
      Size = 1020
    end
    object mteCV1SettingsFILE_NAME_EEPROM: TWideStringField
      FieldName = 'FILE_NAME_EEPROM'
      Size = 1020
    end
    object mteCV1SettingsNAME_PRESET: TWideStringField
      FieldName = 'NAME_PRESET'
      Required = True
      Size = 280
    end
    object mteCV1SettingsACTIVE_PRESET: TSmallintField
      FieldName = 'ACTIVE_PRESET'
      Required = True
    end
    object mteCV1SettingsENABLE_SCRIPT: TLargeintField
      FieldName = 'ENABLE_SCRIPT'
      Required = True
    end
    object mteCV1SettingsBOARDTYPEID: TIntegerField
      FieldName = 'BOARDTYPEID'
    end
    object mteCV1SettingsDECCODEID: TSmallintField
      FieldName = 'DECCODEID'
    end
  end
  object dsCV1Settings: TDataSource
    DataSet = mteCV1Settings
    Left = 128
    Top = 8
  end
end
