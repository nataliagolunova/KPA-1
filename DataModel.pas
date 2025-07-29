unit DataModel;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Data.DB, IBX.IBDatabase, DataDriverEh,
  IBXDataDriverEh, IBX.IBQuery, FirebirdUtils, MeterInfo, System.NetEncoding,
  System.TypInfo, System.Rtti, Utils, MemTableEh, MemTableDataEh,
  RSAOpenSSL, DCPrijndael, DCPcrypt2, System.Hash;

type
  TDataMod = class(TDataModule)
    IBTransaction1: TIBTransaction;
    IBXConnectionProviderEh1: TIBXConnectionProviderEh;
    IBDatabase1: TIBDatabase;
    ibxddeSecuser: TIBXDataDriverEh;
    mteSecuser: TMemTableEh;
    dsSecuser: TDataSource;
    mteSecuserID: TIntegerField;
    mteSecuserSAMACCOUNTNAME: TWideStringField;
    mteSecuserFNAME: TWideStringField;
    mteSecuserLNAME: TWideStringField;
    mteSecuserMNAME: TWideStringField;
    mteSecuserFULLNAME: TWideStringField;
    mteSecuserROLE: TIntegerField;
    mteSecuserSTANDID: TIntegerField;
    mteSecuserHESHPASS: TWideStringField;
    mteSecuserENABLED: TSmallintField;
    mteSecuserCOMPANY: TWideStringField;
    mteSecuserEMAIL: TWideStringField;
    ibxdtdrvrhCV1Settings: TIBXDataDriverEh;
    mteCV1Settings: TMemTableEh;
    dsCV1Settings: TDataSource;
    mteCV1SettingsID: TIntegerField;
    mteCV1SettingsMETEREVENTTYPEID: TIntegerField;
    mteCV1SettingsNAME_TEST_FIRMWARE: TWideStringField;
    mteCV1SettingsNAME_RELEASE_FIRMWARE: TWideStringField;
    mteCV1SettingsFILE_NAME_EEPROM: TWideStringField;
    mteCV1SettingsNAME_PRESET: TWideStringField;
    mteCV1SettingsACTIVE_PRESET: TSmallintField;
    mteCV1SettingsENABLE_SCRIPT: TLargeintField;
    mteCV1SettingsBOARDTYPEID: TIntegerField;
    mteCV1SettingsDECCODEID: TSmallintField;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetCVE2Settings( out MsgStr : string ) : Boolean;
    function AddBoardProbe( aDB: TIBDatabase; UserID, StandID,
  BoardID: Integer; MeterInfo: TMeterInfo; BoardIndex: Byte;
  EventDateTime: TDateTime; EventComment: string; STATEID : Integer; out MessageStr : string ): Boolean;
    function GetOrAddComment( aDB : TIBDatabase; Comment : string ) : Cardinal;
  end;

var
  DataMod: TDataMod;

implementation
  uses Common;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TDataMod.GetCVE2Settings( out MsgStr : string ) : Boolean;

var
  q : TIBQuery;
  ParamName, ParamIndex : string;
  ParamIdx : Integer;
  ParamType : TTypeDict;
  rttiContext : TRTTIContext;
  fld : TRTTIField;
//  rttiType: TRttiType;
//  fields: TArray< TRttiField >;
begin
  Result := False;

  with DataMod.IBDatabase1 do begin    //Через IBX компоненты
    Close;
    DatabaseName := cfg_params.connection_db; // строку соединения с БД берем из параметров из INI
    Params.Clear;
    Params.Append( 'user_name=' + DB_USER {MasterLogin} );   // Пользователь базы
    Params.Append( 'password=' + DB_PASSWORD{MasterPass} );     // Пароль пользователя
    Params.Append( 'sql_role_name=' + cfg_params.user_role_name{SQL_Role} );  // Имя роли пользователя
    Params.Append( 'lc_ctype=' + DB_LC_CTYPE {BCodePage} );       // Кодировка базы
    LoginPrompt := False;                          // Не спрашивать учетные данные при запуске приложения
    Open;                                          // открываем БД
  end;
  if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;

  q := OpenIBQuery( IBDatabase1
    , 'select NAME, VALUETYPE, PARAMVALUE, DESCRIPTION from CVE2SETTINGS, VALUETYPEDICT '
    + 'where CVE2SETTINGS.PARAMTYPE = VALUETYPEDICT.ID', [ ] ); // Получаем из базы список всех настроек с типами данных для них

  try
    while not q.Eof do begin    // перебираем все настройки в списке из базы

      ParamName := q.Fields[ 0 ].AsString;  // берем имя параметра
      ParamIndex := string.Empty;           // строковую переменную под индекс почистим

      if ParamName.Contains( '[' ) then begin    // Если параметр - это элемент мссива
        // Получим индекс элемента массива
        ParamIndex := ParamName.Substring( ParamName.IndexOf( '[' ) + 1, Length( ParamName ) - ParamName.IndexOf( ']' ));
        if not TryStrToInt( ParamIndex, ParamIdx ) then begin
          MsgStr := Format( ' Не удалось получить цифровой индекс массива параметра %s из таблицы CVE2SETTINGS'
            , [ ParamName ]);
          Exit( False );
        end;
        ParamName := ParamName.Remove( ParamName.IndexOf( '[' ));   // Отрежем индекс со скобками
      end; {}

     for fld in rttiContext.GetType( TypeInfo( TConfigParams )).GetFields do  // для каждого поля из TConfigParam
       if ( UpperCase( fld.Name ) = UpperCase( ParamName )) then begin       // если его имя совпадает с именем из списка в базе

          ParamType := TTypeDict( GetEnumValue( TypeInfo( TTypeDict ), '_' + q.Fields[ 1 ].AsString ));  // определим тип параметра
          case ParamType of   // и в зависимости от типа присвоим значение
            _UInt8:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, Byte( q.Fields[ 2 ].AsInteger ))
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx, Byte( q.Fields[ 2 ].AsInteger ));

            _UInt16:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, Word( q.Fields[ 2 ].AsInteger ))
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx, Word( q.Fields[ 2 ].AsInteger ));

            _UInt32:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params,  q.Fields[ 2 ].AsLongWord )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsLongWord );

            _Int8:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params,  ShortInt( q.Fields[ 2 ].AsInteger ))
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  ShortInt( q.Fields[ 2 ].AsInteger ));

            _Int16:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params,  SmallInt( q.Fields[ 2 ].AsInteger ))
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  SmallInt( q.Fields[ 2 ].AsInteger ));

            _Int32:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsInteger )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsInteger );

            _Int64:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsLargeInt )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsLargeInt );

            _Single:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsSingle )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsSingle );

            _Double:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsFloat )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsFloat );

            _Extend:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsExtended )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx,  q.Fields[ 2 ].AsExtended );

            _Bool:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsBoolean )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx, q.Fields[ 2 ].AsBoolean );

            _String:
              if ParamIndex.IsEmpty then
                fld.SetValue( @cfg_params, q.Fields[ 2 ].AsString )
              else
                fld.GetValue( @cfg_params ).SetArrayElement( ParamIdx, q.Fields[ 2 ].AsString );
          end;
       end;

      q.Next;
    end;

    Result := True;
  finally
    if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;
    q.Destroy;
  end;

end;

function TDataMod.AddBoardProbe( aDB: TIBDatabase; UserID, StandID,
  BoardID: Integer; MeterInfo: TMeterInfo; BoardIndex: Byte;
  EventDateTime: TDateTime; EventComment: string; STATEID : Integer; out MessageStr : string ): Boolean;
var
  TABLEID : integer;
  PSIID, CommentID : Cardinal;
  LastEventID : Cardinal;
begin
  // найдем ID комментария
  CommentID := GetOrAddComment( datamod.IBDatabase1, EventComment );

  if STATEID > 0 then begin
    // То у нас известна причина отказа автоматической проверки или ручная забраковка платы
    // и требуется таблица METERPSI

    // Для доп. информации при записи события проверки платы будем использовать
    // уже существующую таблицу METERPSI, а STATEID статусов лежат в METERPSISTATEDICT
    PSIID := GetQueryAloneValueInsertSQL( aDB, 'Insert INTO METERPSI( STATEID )'
                + ' values ( :pSTATEID ) returning ID', 'ID'
                ,[ STATEID ], 0 );
    if PSIID = 0 then begin
      MessageStr := 'Не удалось добавить запись в таблицу METERPSI в БД';
      Exit( False );
    end;

    TABLEID := GetQueryAloneValue( aDB, 'Select ID from REGISTERTABLE where TABLENAME = :pTABLENAME '
      ,[ TABLENAME_PSI ], 0 );
  end
  else begin  // см. коментарий в начале условного оператора
    PSIID := 0;
    TABLEID := GetQueryAloneValue( aDB, 'Select ID from REGISTERTABLE where TABLENAME = :pTABLENAME '
      ,[ TABLENAME_NO_TABLE ], 0 );
  end;
  LastEventID := GetQueryAloneValue(datamod.IBDatabase1,'select METEREVENTTYPEID from CVE1SETTINGS where ID = :pID',
                [cfg_params.id_preset], 0);

  // пишем событие в BOARDEVENTS
  if not ExecIBQueryInTransaction(aDB,'Insert INTO BOARDEVENTS ( BRDEVENTTYPEID,'
    + 'BRDEVENTDATE, BOARDID, USERID, STANDID, EVENTSTATE, PRESETID, COMMENTID, TABLEID, OBJECTID ) values '
    + '( :pEventtypeid, :pEventDate, :pBoardID, :pUserID, :pStandID, :pEVENTSTATE, :pPresetID, :pCOMMENTID, :pTableID, :pObjectID )'
    ,'Ошибка добавления события проверки платы #' + IntToStr( BoardIndex + 1 ) + ' в БД. '
    ,[ LastEventID, EventDateTime, BoardID, UserID, StandID
      , MeterInfo.MeterState.BoardState, cfg_params.id_preset, CommentID, TABLEID, PSIID ])
  then begin
    MessageStr := 'Не удалось добавить событие для платы в таблицу BOARDEVENTS БД';
    Exit( False );
  end;

  // Обновим текущий статус платы и последнюю операцию
  if not ExecIBQueryInTransaction( aDB,'update METERBOARDS set STATE_CURR_ID = :pState'
    + ', LAST_EVENT_ID = :pEventTypeID where ID = :pBoardID'
    , Format( 'Ошибка обновления текущего статуса платы # %s, ID=%u в таблице METERBOARDS'
    , [ MeterInfo.BoardSerial, BoardID ])
    ,[  MeterInfo.MeterState.BoardState, LastEventID, BoardID ] )
  then  Exit( False );

  Result := True;
end;

function TDataMod.GetOrAddComment( aDB : TIBDatabase; Comment : string ) : Cardinal;
var
  res : Int64;
begin
  // найдем ID комментария
  res := GetQueryAloneValue( aDB, 'Select ID from COMMENTS where COMMENT = :pComment'
    , [ Comment ], -1 );
  if res < 0 then
  begin
    if not ExecIBQueryInTransaction( aDB
      , 'Insert Into COMMENTS (COMMENT) values (:pComment)'
      , 'Ошибка добавления комментария в БД'
      , [ Comment ])
    then
      Exit( 0 );
    Result := GetQueryAloneValue( aDB, 'Select ID from COMMENTS where COMMENT = :pComment'
    , [ Comment ], 0 );
  end
  else
    Result := Cardinal( res );
end;
end.

