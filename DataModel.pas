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

  with DataMod.IBDatabase1 do begin    //����� IBX ����������
    Close;
    DatabaseName := cfg_params.connection_db; // ������ ���������� � �� ����� �� ���������� �� INI
    Params.Clear;
    Params.Append( 'user_name=' + DB_USER {MasterLogin} );   // ������������ ����
    Params.Append( 'password=' + DB_PASSWORD{MasterPass} );     // ������ ������������
    Params.Append( 'sql_role_name=' + cfg_params.user_role_name{SQL_Role} );  // ��� ���� ������������
    Params.Append( 'lc_ctype=' + DB_LC_CTYPE {BCodePage} );       // ��������� ����
    LoginPrompt := False;                          // �� ���������� ������� ������ ��� ������� ����������
    Open;                                          // ��������� ��
  end;
  if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;

  q := OpenIBQuery( IBDatabase1
    , 'select NAME, VALUETYPE, PARAMVALUE, DESCRIPTION from CVE2SETTINGS, VALUETYPEDICT '
    + 'where CVE2SETTINGS.PARAMTYPE = VALUETYPEDICT.ID', [ ] ); // �������� �� ���� ������ ���� �������� � ������ ������ ��� ���

  try
    while not q.Eof do begin    // ���������� ��� ��������� � ������ �� ����

      ParamName := q.Fields[ 0 ].AsString;  // ����� ��� ���������
      ParamIndex := string.Empty;           // ��������� ���������� ��� ������ ��������

      if ParamName.Contains( '[' ) then begin    // ���� �������� - ��� ������� ������
        // ������� ������ �������� �������
        ParamIndex := ParamName.Substring( ParamName.IndexOf( '[' ) + 1, Length( ParamName ) - ParamName.IndexOf( ']' ));
        if not TryStrToInt( ParamIndex, ParamIdx ) then begin
          MsgStr := Format( ' �� ������� �������� �������� ������ ������� ��������� %s �� ������� CVE2SETTINGS'
            , [ ParamName ]);
          Exit( False );
        end;
        ParamName := ParamName.Remove( ParamName.IndexOf( '[' ));   // ������� ������ �� ��������
      end; {}

     for fld in rttiContext.GetType( TypeInfo( TConfigParams )).GetFields do  // ��� ������� ���� �� TConfigParam
       if ( UpperCase( fld.Name ) = UpperCase( ParamName )) then begin       // ���� ��� ��� ��������� � ������ �� ������ � ����

          ParamType := TTypeDict( GetEnumValue( TypeInfo( TTypeDict ), '_' + q.Fields[ 1 ].AsString ));  // ��������� ��� ���������
          case ParamType of   // � � ����������� �� ���� �������� ��������
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
  // ������ ID �����������
  CommentID := GetOrAddComment( datamod.IBDatabase1, EventComment );

  if STATEID > 0 then begin
    // �� � ��� �������� ������� ������ �������������� �������� ��� ������ ���������� �����
    // � ��������� ������� METERPSI

    // ��� ���. ���������� ��� ������ ������� �������� ����� ����� ������������
    // ��� ������������ ������� METERPSI, � STATEID �������� ����� � METERPSISTATEDICT
    PSIID := GetQueryAloneValueInsertSQL( aDB, 'Insert INTO METERPSI( STATEID )'
                + ' values ( :pSTATEID ) returning ID', 'ID'
                ,[ STATEID ], 0 );
    if PSIID = 0 then begin
      MessageStr := '�� ������� �������� ������ � ������� METERPSI � ��';
      Exit( False );
    end;

    TABLEID := GetQueryAloneValue( aDB, 'Select ID from REGISTERTABLE where TABLENAME = :pTABLENAME '
      ,[ TABLENAME_PSI ], 0 );
  end
  else begin  // ��. ���������� � ������ ��������� ���������
    PSIID := 0;
    TABLEID := GetQueryAloneValue( aDB, 'Select ID from REGISTERTABLE where TABLENAME = :pTABLENAME '
      ,[ TABLENAME_NO_TABLE ], 0 );
  end;
  LastEventID := GetQueryAloneValue(datamod.IBDatabase1,'select METEREVENTTYPEID from CVE1SETTINGS where ID = :pID',
                [cfg_params.id_preset], 0);

  // ����� ������� � BOARDEVENTS
  if not ExecIBQueryInTransaction(aDB,'Insert INTO BOARDEVENTS ( BRDEVENTTYPEID,'
    + 'BRDEVENTDATE, BOARDID, USERID, STANDID, EVENTSTATE, PRESETID, COMMENTID, TABLEID, OBJECTID ) values '
    + '( :pEventtypeid, :pEventDate, :pBoardID, :pUserID, :pStandID, :pEVENTSTATE, :pPresetID, :pCOMMENTID, :pTableID, :pObjectID )'
    ,'������ ���������� ������� �������� ����� #' + IntToStr( BoardIndex + 1 ) + ' � ��. '
    ,[ LastEventID, EventDateTime, BoardID, UserID, StandID
      , MeterInfo.MeterState.BoardState, cfg_params.id_preset, CommentID, TABLEID, PSIID ])
  then begin
    MessageStr := '�� ������� �������� ������� ��� ����� � ������� BOARDEVENTS ��';
    Exit( False );
  end;

  // ������� ������� ������ ����� � ��������� ��������
  if not ExecIBQueryInTransaction( aDB,'update METERBOARDS set STATE_CURR_ID = :pState'
    + ', LAST_EVENT_ID = :pEventTypeID where ID = :pBoardID'
    , Format( '������ ���������� �������� ������� ����� # %s, ID=%u � ������� METERBOARDS'
    , [ MeterInfo.BoardSerial, BoardID ])
    ,[  MeterInfo.MeterState.BoardState, LastEventID, BoardID ] )
  then  Exit( False );

  Result := True;
end;

function TDataMod.GetOrAddComment( aDB : TIBDatabase; Comment : string ) : Cardinal;
var
  res : Int64;
begin
  // ������ ID �����������
  res := GetQueryAloneValue( aDB, 'Select ID from COMMENTS where COMMENT = :pComment'
    , [ Comment ], -1 );
  if res < 0 then
  begin
    if not ExecIBQueryInTransaction( aDB
      , 'Insert Into COMMENTS (COMMENT) values (:pComment)'
      , '������ ���������� ����������� � ��'
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

