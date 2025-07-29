unit Common;

interface

uses
  ActiveDs_TLB,  IdCoder, IdCoder3to4, IdCoderMIME, IdMessage, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, Vcl.Graphics,
  IdMessageClient, IdSMTPBase, IdSMTP, IdCustomTransparentProxy, IdSocks, Vcl.ComCtrls,
  IdIOHandler, IdAttachment, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  System.SysUtils, vcl.Dialogs, IBX.IBDatabase, FirebirdUtils, Utils, DataModel, DB,
  Winapi.Windows, Vcl.Forms, System.Notification, system.classes, System.IniFiles, MeterInfo,
  System.Generics.Collections;

const
    DB_USER = 'SYSDBA';
    DB_PASSWORD = 'masterkey';
    DB_LC_CTYPE = 'UTF8';

    ROLEADMIN = 1;

    CR_LF  = chr(13) + chr(10);      // Перевод строки


  // ----------------------- Статусы КПА длинные названия -----------------------------
  KPAStatusLong : array [0..11] of String =('Плата не вставлена.',
                                           'Плата вставлена и проверка не начата.',
                                           'Скрипт без оператора. Выполняется скрипт, не требующий участия оператора.',
                                           'Скрипт с оператором первые 5 сек. Первые 5 сек. скрипта, в котором требуется действие оператора.',
                                           'Скрипт с оператором вторая часть. Вторая часть скрипта (по времени), в котором требуется действие оператора.',
                                           'Скрипт прошивки. ыполняется прошивка платы.',
                                           'Плата прошла проверку.',
                                           'Плата не прошла проверку.',
                                           'Выполнение скрипта отменено пользователем по кнопке на КПА.',
                                           'Режим ручнкакого тестирования платы.',
                                           'Плату вытащили не закончив проверку (при статусах КПА 2-5).',
                                           'Нет связи с КПА (для программы верхнего уровня).');

  // ---------------------------------------- конец ------------------------------------

    // ----------------------- Статусы КПА длинные названия -----------------------------
  KPAStatusShort : array [0..11] of String =('Плата не вставлена.',
                                             'Плата вставлена и проверка не начата.',
                                             'Скрипт без оператора.',
                                             'Скрипт с оператором первые 5 сек.',
                                             'Скрипт с оператором вторая часть.',
                                             'Скрипт прошивки.',
                                             'Плата прошла проверку.',
                                             'Плата не прошла проверку.',
                                             'Скрипт отменен пользователем по кнопке на КПА.',
                                             'Режим ручного тестирования платы.',
                                             'Плату вытащили не закончив проверку.',
                                             'Нет связи с КПА.');

  // ---------------------------------------- конец ------------------------------------

      // ----------------------- Список ошибок -----------------------------
  KPAErrorName : array [0..6] of String =('KpaError: 1. Запрещён доступ к изменению настроек',
                                           'KpaError: 2. Ошибка синтаксиса',
                                           'KpaError: 3. Функция записи недоступна',
                                           'KpaError: 4. Неизвестная ошибка',
                                           'KpaError: 5. Ошибка записи значения (неверный тип или размер данных)',
                                           'KpaError: 6. Неизвестная команда',
                                           'KpaError: 8. Невозможно выполнить команду');
  // ---------------------------------------- конец ------------------------------------

type
  TConfigParams = record
    current_AD_user : IADsUser;
    user_ID         : Integer;
    user_role       : Integer;
    access          : Integer;
    id_preset       : Integer;
    ports           : array [0..MAX_SENSOR_COUNT-1] of string;
//    login_kpa_id    : Integer;    //id пользователя
//    login_kpa_name  : string;      //имя пользоваталея
    user_role_name  : string;      //наименование роли пользователя
    user_name       : string;
    user_password   : string;
    srv_name_db     : string;
    filepath_db     : string;
    connection_db   : string;
    update_exe_path : string;
    log_path        : string;
    log_extended    : Boolean;
    search_update   : boolean;
    timeout, speed  : Integer;
    stand_id        : Integer;
    CVE1_update_path                      : string;
    CVE1_update                           : Boolean;
    CVE1_test_firmware_update_path        : string;
    MAIN_last_SWVer_SMT_Smart_path        : string;
    MAIN_last_SWVer_SMT_Smart_K_path      : string;
    MAIN_last_SWVer_SMT_Smart_DKZ_path    : string;
  end;

  // ------------------------ Реестр статусов КПА -------------------------
   TPollingStatus = (polStatusLabelKPA, polStatusRichKPA, polLogList, polLogRichMain);
//   TPollStatus = set of TPollingStatus;
  //-------------------------------- конец -----------------------------------
    // ------------------------ Реестр статусов логов -------------------------
   TLogStatus = (logMain, logError, logSuccess);
  //-------------------------------- конец -----------------------------------

  // ------------------------ Реестр опроса КПА -------------------------
   TRegistrySettings = (polStartPort, polKPA, polFirmware, polStatus, polGetStatusScript, polKpaStart, polGetModemInfo,
                        polStatus_7, polParam, polDownSetupKPA, polDownMeterPO, polClosePort);
   TRegistrySett = set of TRegistrySettings;
  //-------------------------------- конец -----------------------------------

  TProgressDown = record
    NumPanelKPA : Integer;
    MaxValue : Integer;
    Value : Integer;
  end;

  TKpaParam = record
    ExecScriptsMask : string;
    FirmwareReleaseIndex : string;
    FirmwareEepromDataIndex : string;
    RamCommand1 : string;
    RamCommand2 : string;
    RamCommand3 : string;
    RamCommand4 : string;
    RamCommand5 : string;
    UsbReConnect : string;
  end;

  TInfoMeterBoard = record
    VersionKPA : string;
    SerialKPA : string;
    LateStatus : Integer;      //статус прошлой операции
    LateScript : string;     //GetStatusScript прошлой операции
    Comment : string;
    StandID : Integer;
    FlagWaitBoard : Boolean;
    FlagModemInfo : Boolean;
    FlagStatus_7 : Boolean;
    FlagSaveBD : Boolean;
    FBoardStateID : Integer;
//    NamePort : string;
    Color : TColor;
    THRLogStr : string;
    ThrLogStatus : TPollingStatus;
  end;


  TFrmLog = class(TForm)
  redtLog: TRichEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SendToLog(s: string; FlagLog : TLogStatus);
  end;


 var
  meters_info         : TObjectList <TMeterInfo>;  // список объектов класса TMeterInfo, хранящих инфу о счетчике
	mtr_info            : array[ 0..MAX_SENSOR_COUNT - 1 ]of TMeterInfo;  // массив объектов (нужен только при создании)
  ErrStr : string;
  app_filename : string;
  cfg_file_name : string;
  AppVersion : TVersionInfo;        // текущая версия программы
  UpdateVersion : TVersionInfo;        // новая версия программы
  app_folder : string;
  fmt_cfg : TFormatSettings;    // Настройки формата
  FrmLog: TFrmLog;
  FLogFileName : string;     // Имя логфайла программы
  FLogFile : TextFile;   // Логфайл программы
  log_folder : string;     // каталог логов
  cfg_params : TConfigParams;
  cfg_file : TIniFile;
  LogList : TStringList;
  sl_PortsList : TStringList;        // Список портов
  kpa_param : TKpaParam;
  meter_board : array [0..MAX_SENSOR_COUNT-1] of TInfoMeterBoard;
  EnterSerial          : boolean;
  TimeEnterSerial      : TDateTime;
//  ElapsedTime  : Integer;
//  FlagLogSatus : TStatusLog;


  function InterbaseDatabaseExists(const ADataBaseName, ALogin, APassword: string): string;
  procedure LoadParams;
  procedure SaveParam;
  procedure SaveLogList;

implementation

function InterbaseDatabaseExists(const ADataBaseName, ALogin, APassword: string): string;
var
  fDataBase: TIBDataBase;
begin

  // Проверка наличия базы данных методом коннекта
  fDataBase := TIBDatabase.Create(nil); // Временный экземпляр TIBDataBase
  try
    try
      if ((ADataBaseName.Contains('srv-pr'))
        or (ADataBaseName.Contains('localhost')))
        and ((ADataBaseName.Contains('.FDB'))
        or (ADataBaseName.Contains('.fdb'))) then begin

        fDataBase.DatabaseName := ADataBaseName;
        fDataBase.Params.Clear;
        fDataBase.Params.Append('user_name='+ ALogin);
        fDataBase.Params.Append('password=' + APassword);
        fDataBase.LoginPrompt := False;
        fDataBase.Open;
        Result := 'OK';
      end;
    except
      on e: Exception do
        Result := 'Ошибка: '+ e.Message
    end
  finally
    fDataBase.Free
  end;
end;

procedure TFrmLog.SendToLog(s: string; FlagLog : TLogStatus);
//var
//a : TLogStatus;
begin
//  for a in FlagLog do begin
    case FlagLog of
      logMain: begin
        LogList.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[main]' + s)
      end;
      logError: begin
        LogList.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[error]' + s)
      end;
      logSuccess: begin
        LogList.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[success]' + s)
      end;
    end;
end;

procedure SaveLogList;
var
  i: Integer;
  F : TextFile;
begin
  if (not Assigned(LogList)) or (LogList.Count <= 0) then  Exit;

  if FileExists(FLogFileName) then begin
    AssignFile(F, FLogFileName);
    Append(F);
  end
  else begin
    AssignFile(F, FLogFileName);
    Rewrite(F);
  end;

  for i := 0 to LogList.Count-1 do
    Writeln(F,LogList[i]);

  LogList.Clear;
  CloseFile(F);
end;


procedure LoadParams;
var i : Integer;
begin
  if ( Assigned( cfg_file ) ) then with cfg_params do begin
    timeout := cfg_file.ReadInteger('SETUPREAD', 'TimeOut', 0);
    speed := cfg_file.ReadInteger ('SETUPREAD', 'Speed', 0);
    srv_name_db := cfg_file.ReadString ('DATABASE', 'SrvName', '');
    filepath_db := cfg_file.ReadString ('DATABASE', 'FilePathDB', '');
    connection_db := cfg_file.ReadString ('DATABASE', 'ConnectDB', '');

    search_update := cfg_file.ReadBool ('UPDATE', 'CheckUpD', False);
    update_exe_path := cfg_file.ReadString ('UPDATE', 'FilePathUpD', '');
    log_path := cfg_file.ReadString ('UPDATE', 'LogPath', '');
    log_extended := cfg_file.ReadBool ('UPDATE', 'LogExcended', False);

    id_preset := cfg_file.ReadInteger('PRESET', 'id', 0);

    for i := 0 to MAX_SENSOR_COUNT-1 do
      ports[i] := cfg_file.ReadString('GENERAL', 'Port' + IntToStr(i + 1), '');

    user_ID := cfg_file.ReadInteger('GENERAL', 'LoginID', 0);
    user_name := cfg_file.ReadString('GENERAL', 'LoginID', '');
    stand_id := cfg_file.ReadInteger('GENERAL', 'StandID', 0);
  end;

end;

procedure SaveParam;
var i : Integer;
begin
  if ( Assigned( cfg_file ) ) then with cfg_params do begin
    cfg_file.WriteInteger('SETUPREAD', 'TimeOut', timeout);
    cfg_file.WriteInteger('SETUPREAD', 'Speed', speed);
    cfg_file.WriteString('DATABASE', 'SrvName', srv_name_db);
    cfg_file.WriteString('DATABASE', 'FilePathDB', filepath_db);
    cfg_file.WriteString('DATABASE', 'ConnectDB', connection_db);

    cfg_file.WriteBool('UPDATE', 'CheckUpD', search_update);
    cfg_file.WriteString('UPDATE', 'FilePathUpD', update_exe_path);
    cfg_file.WriteString('UPDATE', 'LogPath', log_path);
    cfg_file.WriteBool('UPDATE', 'LogExcended', log_extended);

    for i := 0 to MAX_SENSOR_COUNT-1 do begin
      cfg_file.WriteString('GENERAL', 'Port' + IntToStr(i + 1), cfg_params.ports[i]);
    end;
    cfg_file.WriteInteger('GENERAL', 'LoginID', user_ID);
    cfg_file.WriteString('GENERAL', 'LoginName', user_name);
    cfg_file.WriteInteger('GENERAL', 'StandID', stand_id);

  end;
end;

end.
