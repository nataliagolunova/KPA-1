unit MyThread;

interface

uses
  System.Classes, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Common, BCPort, Vcl.Graphics, Vcl.Dialogs, Vcl.Forms, Utilits, System.Types, CRCFunc,
  Math, MeterInfo;

type

  TComP = record
    BCP       : TBComPort;
    FBuffStr  : String;           // Буфер парсинга (основной)
  end;

  TKeyStatus = record
    StatusBoardNotInsert : boolean;
    TimeBrdNotIns        : TDateTime;
//    EnterSerial          : boolean;
//    TimeEnterSerial      : TDateTime;
    StatusBoardInsert    : boolean;
    TimeBrdIns           : TDateTime;
    StatusBoardTest      : boolean;
    TimeBrdTest          : TDateTime;
  end;

  TMyThread = class(TThread)
  private
    { Private declarations }
    CountRepeat : Integer;
  protected
    LogTxt : string;
    FParsEndCMD : Boolean;           // Флаги парсинга
    FParsing : Boolean;              // Общий флаг парсинга
    FTmpRxStr: string;               // Буферы парсинга (конец строки c OK и временный для Qf)
    CountStatus : Integer;
    CountReconnection : Integer;
    ConnectSMT : Boolean;
    FlagStopThread : Boolean;

    procedure Execute; override;
    procedure WorkRegistrySett;
    procedure ParsingAnswer(Answer: string);
    procedure ParsingStatus(ActualNumStatus : Integer);
    function CheckParamKPA(Command, Answer : string): Boolean;
    function KeyWaitBoard (NumStatus : Integer) : Boolean;
    procedure FileDownSetup;
    procedure FileDownMeterPO;
    procedure CheckFirmware;

    procedure StartPort;
    procedure ClosePort;

    function Send_ByteArr( var BArr: TArray<Byte>; WaitResive: Boolean = True): string;
    function ReciveAnswer(Command: string; WaitResive: Boolean = True): string;
    procedure BCPRxChar(Sender: TObject; Count: Integer);

    procedure AddStatusKPA(Str: string; Color : TColor; Status: TPollingStatus);
    procedure AddNameKPA_Sync;
    procedure AddRich_Sync;
    procedure DeleteSerialFrame_Sync;
    procedure SaveBDModem_Sync;
    procedure SaveBDStatus_Sync;
    procedure DestoyThread_Sync;
    procedure GaugeDownSetup_Sync;
    procedure GaugeDownMeterPO_Sync;
    procedure ReadSerialQR_Sync;
    procedure ReconnectionPort;


  public
    ComP : TComP;
    Port: string;
    BaudRate: TBaudRate;
    KeyStatus : TKeyStatus;
    NumKPA: Integer;
    Command : string;
    TimeOut : Integer;
    ModeRegSett: TRegistrySett;
    ProgressDown : TProgressDown;
    CommandParam : string;
    SerialBoard : string;
    VersionBoard : string;
    FlagDownSetup : Boolean;
    FileSetupKPA : string;
    FileMeterPO : string;
    NumCellMeterPO : Integer;
    FlagDownMeterPO : Boolean;
    FlagAutoFirmware : Boolean;
  end;

implementation

uses
  MainForm, DownloadSetup, DownloadMeterPO;

{ MyThread }

procedure TMyThread.AddStatusKPA(Str: string; Color : TColor; Status: TPollingStatus);
//отвечает за lblStatus, дублируя инфу в rich и логфайл
var a : TPollingStatus;
begin
  meter_board[NumKPA].ThrLogStr := Str;
  meter_board[NumKPA].ThrLogStatus := Status;
  meter_board[NumKPA].Color := Color;
  Synchronize(AddRich_Sync);
end;

procedure TMyThread.AddNameKPA_Sync;
begin
  frmMainForm.AddNameKPA(NumKPA);
end;

procedure TMyThread.AddRich_Sync;
begin
  frmMainForm.AddRich(NumKPA);
end;

procedure TMyThread.DeleteSerialFrame_Sync;
begin
//  KeyStatus.StatusBoardNotInsert := false;
  KeyStatus.StatusBoardInsert := False;
  frmMainForm.DeleteSerial(NumKPA);
end;

procedure TMyThread.SaveBDModem_Sync;
begin
  frmMainForm.SaveBDModem(NumKPA);
end;

procedure TMyThread.SaveBDStatus_Sync;
begin
  frmMainForm.SaveBD(NumKPA);
end;

procedure TMyThread.ReconnectionPort;
begin
  while (CountReconnection < 3) and (FlagStopThread){ and (not ConnectSMT)} do begin
      sleep(2000);
    Inc(CountReconnection);
    var ErrSrt := Format( 'Попытка переподключиться №%u к порту - %s.', [CountReconnection, Port ]);
    AddStatusKPA(ErrSrt, clBlue, polLogRichMain);
    StartPort;
  end;
  if ((CountReconnection = 3) and (FlagStopThread)) {or (ConnectSMT) }then begin
    AddStatusKPA(KPAStatusShort[11], clRed, polStatusLabelKPA);
    Synchronize(DestoyThread_Sync);
  end;
end;

procedure TMyThread.DestoyThread_Sync;
begin
  frmMainForm.DestroyThread(NumKPA);
end;

procedure TMyThread.GaugeDownSetup_Sync;
begin
  frmDownloadSetup.IncGauge(ProgressDown);
end;

procedure TMyThread.GaugeDownMeterPO_Sync;
begin
  frmDownloadMeterPO.IncGauge(ProgressDown);
end;

procedure TMyThread.ReadSerialQR_Sync;
begin
  frmMainForm.ReadSerialQR;
end;

procedure TMyThread.Execute;
begin
  inherited;
//переделать вывод в ричи, сделать их через одну функцию
//  Synchronize(StartPort);
//  FlagStopThread := False;
  ModeRegSett := [polStartPort];
  CountReconnection := 0;
  ConnectSMT := False;
  meter_board[NumKPA].LateStatus := 200;     //рандомное число, лишь бы не номер статуса
  while not Terminated  do begin
    sleep(500);
    WorkRegistrySett;

//    if FlagStopThread then Break;
  end;

end;

procedure TMyThread.StartPort;
begin
  ComP.BCP := TBComPort.Create(nil);
  ComP.BCP.OnRxChar := BCPRxChar;
  ComP.BCP.Port := Port;  // Определили порт
  ComP.BCP.BaudRate := BaudRate; // Определили скорость обмена
  ComP.BCP.InBufSize := 1024;
//  meter_board[NumKPA].NamePort := ComP.BCP.Port;
  if ComP.BCP.Connected then ComP.BCP.Close;
  try
    if ComP.BCP.Open then
    begin
      ComP.FBuffStr := string.Empty;
      ComP.BCP.ClearBuffer(True, True);
      AddStatusKPA('Порт открыт!', clBlue, polStatusRichKPA);
//      KeyStatus.StatusBoardNotInsert := false;
//      KeyStatus.StatusBoardInsert := false;
      KeyStatus.StatusBoardTest := False;
      EnterSerial := False;
      FlagStopThread := False;

      ModeRegSett := [polKPA]
    end
    else begin
      AddStatusKPA('Порт закрыт!', clRed, polStatusRichKPA);
      ReconnectionPort;//DestoyThread_Sync;//Synchronize(DestoyThread_Sync);
      Exit;
    end;
//    Application.ProcessMessages;
//    Synchronize(WorkPollSet);
  except
    on e:exception do begin
//      showmessage(e.Message);
      AddStatusKPA('THRD.StartPort.' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;

end;

procedure TMyThread.ClosePort;
begin
  try
    FlagStopThread := True;
    if ComP.BCP.Connected then begin
      ComP.BCP.Close;
      ComP.BCP.Free;
    end;
    AddStatusKPA('Порт закрыт!', clRed, polStatusRichKPA);
//    AddStatusKPA(KPAStatusShort[11], clRed, polStatusLabelKPA);
    ModeRegSett := [];
    ReconnectionPort;//DestoyThread_Sync;//Synchronize(DestoyThread_Sync);
  except
    on e:exception do begin
//      showmessage(e.Message);
      AddStatusKPA('THRD.ClosePort.' + e.Message, clRed, polLogList);
//      AddStatusKPA('Порт закрыт!', clRed, polStatusRichKPA);
//      AddStatusKPA(KPAStatusShort[11], clRed, polStatusLabelKPA);
      ModeRegSett := [];
      ReconnectionPort;//DestoyThread_Sync;//Synchronize(DestoyThread_Sync);
    end;
  end;
end;

procedure TMyThread.WorkRegistrySett;
var
a : TRegistrySettings;
AnswerPort : string;
begin
  try
    if not FlagStopThread then
    for a in ModeRegSett do begin
      case a of
        polStartPort: begin
          Synchronize(StartPort);
          FlagStopThread := False;
        end;
        polKPA: begin
          AddStatusKPA('Опрос КПА', clBlue, polLogRichMain);
          Command := 'kpa' + CR_LF;
          AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
//          {$IFDEF DEBUG} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain); {$ENDIF}
//          {$IFDEF RELEASE} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogList); {$ENDIF}
//          AnswerPort := '';
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polFirmware: begin
          AddStatusKPA('Проверка актуальных прошивок для ПО', clBlue, polLogRichMain);
          CheckFirmware;
        end;
        polStatus: begin
          Command := 'Kpa.Status' + CR_LF;
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polParam: begin
          AddStatusKPA('Опрос параметров КПА', clBlue, polLogRichMain);
          Command := 'Kpa.Param:{' + CommandParam + '}' + CR_LF;
          AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
//          {$IFDEF DEBUG} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain); {$ENDIF}
//          {$IFDEF RELEASE} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogList); {$ENDIF}
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polKpaStart: begin
          AddStatusKPA('Старт проверки', clBlue, polLogRichMain);
          Command := 'KpaStart' + CR_LF;
          AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
//          {$IFDEF DEBUG} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain); {$ENDIF}
//          {$IFDEF RELEASE} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogList); {$ENDIF}
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polGetStatusScript: begin
//          AddStatusKPA('GetStatusScript', clBlue, polStatusRichKPA);
          Command := 'GetStatusScript' + CR_LF;
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polGetModemInfo: begin
//          AddStatusKPA('GetModemInfo', clBlue, polStatusRichKPA);
          Command := 'GetModemInfo' + CR_LF;
          AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
//          {$IFDEF DEBUG} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain); {$ENDIF}
//          {$IFDEF RELEASE} AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogList); {$ENDIF}
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polStatus_7: begin
          Command := 'Kpa.Status:7' + CR_LF;
          AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
          AnswerPort := ReciveAnswer(Command);
          ParsingAnswer(AnswerPort);
          Break;
        end;
        polDownSetupKPA: begin
          AddStatusKPA('Загрузка настроек КПА', clBlue, polLogRichMain);
          FileDownSetup;
        end;
        polDownMeterPO: begin
          AddStatusKPA('Загрузка ПО для счетчиков', clBlue, polLogRichMain);
          FileDownMeterPO;
        end;
      end;

      Application.ProcessMessages;
    end;
  except
    on e:exception do begin
//      showmessage(e.Message);
      AddStatusKPA('THRD.WorkPollSet. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;
end;



procedure TMyThread.ParsingAnswer(Answer: string);
var i : Integer;
  a : TRegistrySettings;
  StrDynArr : TStringDynArray;
  NumStatus : Integer;
  sim_info : TSIM;
begin
  if Answer.Contains('KpaError') then begin
    AddStatusKPA('Ответ: ' + Trim(Answer), clblue, polLogRichMain);
    for i := 0 to High(KPAErrorName) do
      if KPAErrorName[i].Contains(Trim(Answer)) then begin
        AddStatusKPA(KPAErrorName[i], clRed, polStatusRichKPA);
        Inc(CountRepeat);
//        ModeRegSett := [polStatus];//Synchronize(ClosePort);
//        Exit;
        if CountRepeat > 3 then begin
          AddStatusKPA('Ошибка работы в КПА-' + IntToStr(NumKPA + 1), clRed, polStatusLabelKPA);
          ClosePort;//Synchronize(ClosePort);
        end;
      end;
  end
  else begin
    try
      CountRepeat := 0;
      if ModeRegSett = [polKPA] then begin
        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogRichMain);
        if not Answer.Contains('{"KPA-') then begin     //проверка на подключение порта к другим устройствам
          AddStatusKPA(KPAStatusShort[11], clred, polStatusLabelKPA);
//          ConnectSMT := true;
//          AddStatusKPA('Программа посчитала, что есть подключение к СМТ', clRed, polLogList);
          ClosePort;
//          Synchronize(ClosePort);
          Exit;
        end;
        CountStatus := 0;
        StrDynArr := Answer.Split([',']);
        meter_board[NumKPA].VersionKPA := StrDynArr[1];//версия
        meter_board[NumKPA].SerialKPA := StrDynArr[2];//серийник
        Synchronize(AddNameKPA_Sync);
        CountReconnection := 0;
//        ModeRegSett := [polFirmware];

        if meter_board[NumKPA].StandID = 0 then begin
          AddStatusKPA('Не зарегистрированный КПА-' + IntToStr(NumKPA + 1), clRed, polStatusLabelKPA);
          ClosePort;//Synchronize(ClosePort);
//          ModeRegSett := [];
//          Synchronize(DestoyThread_Sync);
        end
        else ModeRegSett := [polStatus];//[polFirmware];
        Exit;
      end;

      if ModeRegSett = [polStatus] then begin
        Delete(Answer, 1, 1);
        Answer := Copy(Answer, 1, Pos('"' + CR_LF, Answer)-1);
        ParsingStatus(StrToInt(Answer));
        Exit;
      end;

      if ModeRegSett = [polParam] then begin
        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogRichMain);
        if CheckParamKPA(CommandParam, Answer) then begin
          meter_board[NumKPA].FlagWaitBoard := false;
//          KeyStatus.StatusBoardNotInsert := false;
//          KeyStatus.StatusBoardInsert := False;
          KeyStatus.StatusBoardTest := False;
          EnterSerial := False;
          ModeRegSett := [polKpaStart];
        end
        else ModeRegSett := [polStatus];
        CommandParam := EmptyStr;
        Exit;
      end;

      if ModeRegSett = [polKpaStart] then begin
        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogRichMain);
        if Answer.contains('OK') then begin
          AddStatusKPA('Старт проверки подтвержден', clBlue, polLogRichMain);
          meter_board[NumKPA].FlagSaveBD := False;
          meter_board[NumKPA].FlagStatus_7 := false;
          meter_board[ NumKPA ].Comment := '';
        end
        else AddStatusKPA('Старт проверки НЕ подтвержден', clRed, polStatusRichKPA);
        ModeRegSett := [polStatus];
        Exit;
      end;

      if ModeRegSett = [polGetStatusScript] then begin
        if {(CountStatus = 0)  or }((cfg_params.log_extended) and
          (not (meter_board[ NumKPA ].Comment.Contains( 'ОШИБКА' )))) then
          AddStatusKPA(Trim(Answer), clBlue, polStatusRichKPA)
        else
        if  (meter_board[NumKPA].LateScript <> Trim(Answer)) and
            (not (meter_board[ NumKPA ].Comment.Contains( 'ОШИБКА' ))) then
          AddStatusKPA(Trim(Answer), clBlue, polStatusRichKPA);
       meter_board[NumKPA].LateScript := Trim(Answer);

        if meter_board[NumKPA].LateStatus = 7 then begin
//          meter_board[NumKPA].Comment := Answer;
          meters_info[ NumKPA ].BoardState := sUnfit;

          if not meter_board[NumKPA].FlagSaveBD then begin
            AddStatusKPA('НЕ ГОДЕН', clRed, polStatusLabelKPA);
            meter_board[NumKPA].Comment := Answer;
            Synchronize(SaveBDStatus_Sync);
            AddStatusKPA('Конец проверки', clBlue, polLogRichMain);
          end;
        end;

        if meter_board[NumKPA].LateStatus = 6 then begin
          if (meter_board[NumKPA].FlagModemInfo = True) and
            (meters_info[ NumKPA ].BoardState = sUnfit) and
            (meter_board[ NumKPA ].Comment.Contains( 'ОШИБКА' )) and
            (meter_board[NumKPA].FlagStatus_7 = false) then begin
            ModeRegSett := [polStatus_7];
            exit;
          end
          else if (meter_board[NumKPA].FlagModemInfo = True) and
            (meters_info[ NumKPA ].BoardState = sUnfit) and
            (meter_board[ NumKPA ].Comment.Contains( 'ОШИБКА' )) and
            (meter_board[NumKPA].FlagStatus_7 = true) then begin
//            AddStatusKPA(meter_board[ NumKPA ].Comment, clred, polStatusRichKPA);
            if not meter_board[NumKPA].FlagSaveBD then begin
              AddStatusKPA('НЕ ГОДЕН', clRed, polStatusLabelKPA);
              meter_board[NumKPA].FlagSaveBD := True;
              AddStatusKPA('Конец проверки', clBlue, polLogRichMain);
            end;
          end
          else begin
            meter_board[NumKPA].Comment := Answer;
            meters_info[ NumKPA ].BoardState := sFit;
            if not meter_board[NumKPA].FlagSaveBD then begin
              AddStatusKPA('ГОДЕН', clGreen, polStatusLabelKPA);
              Synchronize(SaveBDStatus_Sync);
              AddStatusKPA('Конец проверки', clBlue, polLogRichMain);
            end;
          end;
        end;
        ModeRegSett := [polStatus];
        Exit;
      end;

      if ModeRegSett = [polGetModemInfo] then begin
        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogRichMain);
        Answer := StringReplace(Answer,'"','',[rfReplaceAll]);
        Delete(Answer, Pos(CR_LF, Answer), 2);
        StrDynArr := Answer.Split([';']);        //'861292059039157;;89701018291280205651;897010201290304675ff'
        meters_info[ NumKPA].IMEI := StrDynArr[0];
        for i := 1 to MAX_SIM_COUNT do begin
          sim_info.GSMData.ICCID := StrDynArr[i];
          meters_info[NumKPA].SIMInfo[i] := @sim_info;
        end;
        Synchronize(SaveBDModem_Sync);
        meter_board[NumKPA].FlagModemInfo := True;
        ModeRegSett := [polGetStatusScript];
        Exit;
      end;
      if ModeRegSett = [polStatus_7] then begin
        Delete(Answer, 1, 1);
        Answer := Copy(Answer, 1, Pos('"' + CR_LF, Answer)-1);
        if Answer = '7' then begin
          var ErrStr := Format( 'Плата %s установлена не годной', [ meters_info[NumKPA].BoardSerial] );
          AddStatusKPA(ErrStr , clRed, polLogRichMain);
        end
        else begin
          var ErrStr := Format( 'ОШИБКА! Плата %s не установлена не годной', [ meters_info[NumKPA].BoardSerial] );
          AddStatusKPA(ErrStr , clRed, polLogRichMain);
        end;
        meter_board[NumKPA].FlagStatus_7 := True;
        ModeRegSett := [polGetStatusScript];
        Exit;
      end;
    except
      on e:exception do begin
//        showmessage(e.Message);
        AddStatusKPA('THRD.WorkPollSet. ' + e.Message, clRed, polLogList);
        ClosePort;//Synchronize(ClosePort);
      end;
    end;
  end;
end;

function TMyThread.CheckParamKPA(Command, Answer : string): Boolean;
var I : Integer;
StrArrayCom : TStringDynArray;
StrArrayAns : TStringDynArray;
begin
  Result := true;
  try
//  Command = '"0000003F","1","1","NUMBER_BOARD2=1000023060439","HW_VERSION=0203","","","","0"'
//  Answer = '{"3F","1","1","NUMBER_BOARD2=1000023060439","HW_VERSION=0203","","","","0"}'#$D#$A
    Command := StringReplace(Command,'"','',[rfReplaceAll]);
    Answer := StringReplace(Answer,'"','',[rfReplaceAll]);
    Delete(Answer,1,1);
    Delete(Answer, Pos('}', Answer), 3);
    StrArrayCom := Command.Split([',']);
    StrArrayAns := Answer.Split([',']);
    for i := 0 to High(StrArrayAns) do begin
      if i = 0 then begin
        if HexToInt(StrToHex(StrArrayCom[i])) <> HexToInt(StrToHex(StrArrayAns[i])) then begin
          Result := false;
          Break;
        end;
      end
      else if Trim(StrArrayCom[i]) <> Trim(StrArrayAns[i]) then begin
        Result := false;
        Break;
      end;
    end;

  except
    on e:exception do begin
      AddStatusKPA('THRD.CheckParamKPA. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;

end;

function TMyThread.KeyWaitBoard(NumStatus : Integer) : Boolean;
begin
  Result := False;

  if (NumStatus in [0, 10]){ and (not KeyStatus.StatusBoardNotInsert)} then begin
    Synchronize(DeleteSerialFrame_Sync);
//    KeyStatus.StatusBoardNotInsert := True;
    KeyStatus.TimeBrdNotIns := Now;
    AddStatusKPA('Фиксирован статус: ' + KPAStatusShort[NumStatus] +
                '. Фиксированное время : ' + DateTimeToStr(KeyStatus.TimeBrdNotIns), clBlue, polLogList);
  end;
  // Q100012410202246622902001030011                  123456898         956599969

  if (NumStatus = 1) {and (not KeyStatus.StatusBoardInsert)} then begin
//    KeyStatus.StatusBoardInsert := True;
    KeyStatus.TimeBrdIns := Now;
    AddStatusKPA('Фиксирован статус: ' + KPAStatusShort[NumStatus] +
                '. Фиксированное время : ' + DateTimeToStr(KeyStatus.TimeBrdIns), clBlue, polLogList);
  end;

  if (NumStatus = 1) and (EnterSerial){ and (KeyStatus.StatusBoardNotInsert)}
  {and (KeyStatus.StatusBoardInsert)} and (KeyStatus.StatusBoardTest) and
    (KeyStatus.TimeBrdTest < TimeEnterSerial) and
    (TimeEnterSerial < KeyStatus.TimeBrdNotIns) and
    (KeyStatus.TimeBrdNotIns < KeyStatus.TimeBrdIns) then
    Result := true;

  if (NumStatus = 1) and (EnterSerial) {and (KeyStatus.StatusBoardNotInsert)
  and (KeyStatus.StatusBoardInsert)} and
    (KeyStatus.TimeBrdNotIns < TimeEnterSerial) and
    (TimeEnterSerial < KeyStatus.TimeBrdIns) then begin
//    KeyStatus.StatusBoardInsert := True;
    Result := true;
  end;
end;
//время когда плата прошла/не прошла проверку <
//время когда вставлен серийник   <
//время когда плата не вставлена   <
//время когда плата вставлена      <

//время когда плата не вставлена   <
//время когда вставлен серийник   <
//время когда плата вставлена      <

procedure TMyThread.ParsingStatus(ActualNumStatus : Integer);
begin
  try
    if FlagStopThread then begin
      ClosePort;//Synchronize(ClosePort);
      exit;
    end;
    if ActualNumStatus = 100 then ActualNumStatus := 11;

    if (( meter_board[NumKPA].LateStatus <> ActualNumStatus) and
        (meters_info[ NumKpa ].BoardState in [sUnknown]))
        or
       ((meter_board[NumKPA].LateStatus in [6,7]) and
        (ActualNumStatus in [0])) then
      AddStatusKPA(KPAStatusShort[ActualNumStatus], clBlue, polStatusLabelKPA)
    else if ( meter_board[NumKPA].LateStatus <> ActualNumStatus) then
      AddStatusKPA(KPAStatusShort[ActualNumStatus], clBlue, polLogRichMain);

//    Inc(CountStatus);
    case ActualNumStatus of
      0, 1, 8, 10, 11: begin
        if ActualNumStatus in [0, 10] then begin{Synchronize(DeleteSerialFrame_Sync);}
          meters_info[ NumKpa ].BoardState := sUnknown;
          meter_board[NumKPA].FlagModemInfo := false;
        end;
//        AddStatusKPA('LateStatus=' + IntToStr( meter_board[NumKPA].LateStatus) +
//        ', ActualNumStatus=' + IntToStr(ActualNumStatus), clBlue, polLogList);
        if ( meter_board[NumKPA].LateStatus <> ActualNumStatus) then
          if (CommandParam.IsEmpty) and (KeyWaitBoard(ActualNumStatus)) then begin
            meter_board[NumKPA].FlagWaitBoard := True;
            Synchronize(ReadSerialQR_Sync);
          end;
        if (not CommandParam.IsEmpty) and (meter_board[NumKPA].FlagWaitBoard) then
          ModeRegSett := [polParam]
        else  ModeRegSett := [polStatus];
      end;
      6: begin
        if not KeyStatus.StatusBoardTest then begin
          KeyStatus.StatusBoardTest := True;
          KeyStatus.TimeBrdTest := Now;
          AddStatusKPA('Фиксирован статус: ' + KPAStatusShort[ActualNumStatus] +
                '. Фиксированное время : ' + DateTimeToStr(KeyStatus.TimeBrdTest), clBlue, polLogList);
        end;

  //      meter_board[ParsingInfo.NumPanelKPA].ResultFlag := true;
        if (meter_board[NumKPA].FlagSaveBD = true) then begin
          ModeRegSett := [polStatus];
          //exit;
        end
        else if meters_info[NumKPA].BoardSerial = '' then begin
  //        AddStatusKPA('Работа с платой не корректна. Вставленная плата уже прошла проверку.', clBlue, polLogRichMain);
          ModeRegSett := [polStatus];
        end
        else begin
          if meter_board[NumKPA].FlagModemInfo = false then ModeRegSett := [polGetModemInfo]
          else ModeRegSett := [polGetStatusScript];
        end;

      end;
      2..5, 7: begin
        if (meter_board[NumKPA].FlagSaveBD = true) and (ActualNumStatus = 2) then begin
          meter_board[NumKPA].FlagSaveBD := False;
        end;
        if (meter_board[NumKPA].FlagSaveBD = true) and (ActualNumStatus = 7) then begin
          ModeRegSett := [polStatus];
          //exit;
        end
        else if meters_info[NumKPA].BoardSerial = '' then begin
  //        AddStatusKPA('Работа с платой не корректна.', clBlue, polLogRichMain);
          ModeRegSett := [polStatus];
        end
        else ModeRegSett := [polGetStatusScript];
        if (not KeyStatus.StatusBoardTest) and (ActualNumStatus = 7) then begin
          KeyStatus.StatusBoardTest := True;
          KeyStatus.TimeBrdTest := Now;
          AddStatusKPA('Фиксирован статус: ' + KPAStatusShort[ActualNumStatus] +
                '. Фиксированное время : ' + DateTimeToStr(KeyStatus.TimeBrdTest), clBlue, polLogList);
        end;
      end;
    end;
    meter_board[NumKPA].LateStatus := ActualNumStatus;
    if FlagDownSetup then ModeRegSett := [polDownSetupKPA];
    if FlagDownMeterPO then ModeRegSett := [polDownMeterPO];
    if FlagAutoFirmware then ModeRegSett := [polFirmware];
  except
    on e:exception do begin
      AddStatusKPA('THRD.ParsingStatus. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;
end;


procedure TMyThread.CheckFirmware;
const FirmwareCommand : array [0..3] of String =('FirmwareTest_l433.name', 'FirmwareRelease1.name',
                                                  'FirmwareRelease2.name', 'FirmwareRelease3.name');
NameHWVer : array [0..3] of String =('New_SMT433_LCD8_test_v', 'KPA_SMT_', 'KPA_SMTK_', 'KPA_SMTKD_');
var i : Integer;
AnswerPort : string;
FirmwareOLDName, FirmwareNEWName: String;
OLDVersion, NEWVersion, NEWVersionPath : string;
FirmwareOLDVersion, FirmwareNEWVersion : Double;
searchResult : TSearchRec;
begin
  try
    for i := 0 to High(FirmwareCommand) do begin
      if FlagStopThread then begin
        ClosePort;//Synchronize(ClosePort);
        exit;
      end;
      AddStatusKPA('Запрос прошивки: ' + Copy(FirmwareCommand[i], 1, Pos('.',FirmwareCommand[i])-1), clBlue, polLogRichMain);
      Command := FirmwareCommand[i] + CR_LF;
      AnswerPort := ReciveAnswer(Command);     // ('New_SMT433_LCD8_test_v5.5.bin', 'KPA_SMT_1.290264.bin', 'KPA_SMTK_1.290264.bin', 'KPA_SMTKD_1.290264.bin')
      if (AnswerPort = '') then begin
        repeat
          Command := FirmwareCommand[i] + CR_LF;
          AnswerPort := ReciveAnswer(Command);
        until AnswerPort <> '';
      end;
      if (AnswerPort = '""' + CR_LF) then Continue;

      Delete(AnswerPort, 1, 1);
      FirmwareOLDName := Copy(AnswerPort, 1, Pos('"', AnswerPort)-1);
      OldVersion := Copy(FirmwareOLDName, Length(NameHWVer[i])+1, Length(FirmwareOLDName) - Length(NameHWVer[i]) - Length('.bin'));
      FirmwareOLDVersion := StrToFloat(StringReplace(OldVersion,'.',',',[rfReplaceAll]));
      case i of
        0: NEWVersionPath := ExtractFilePath(cfg_params.CVE1_test_firmware_update_path);
        1: NEWVersionPath := ExtractFilePath(cfg_params.MAIN_last_SWVer_SMT_Smart_path);
        2: NEWVersionPath := ExtractFilePath(cfg_params.MAIN_last_SWVer_SMT_Smart_K_path);
        3: NEWVersionPath := ExtractFilePath(cfg_params.MAIN_last_SWVer_SMT_Smart_DKZ_path);
      end;
      if NEWVersionPath = '' then begin
        AddStatusKPA('Отсутствует путь к прошивке ' + FirmwareCommand[i], clRed, polLogRichMain);
        Continue;
      end;
      if FindFirst(NEWVersionPath + NameHWVer[i] + '*', faAnyFile, searchResult) = 0 then
      begin
        FirmwareNEWName := searchResult.Name;
        FindClose(searchResult);
      end;
      if FirmwareNEWName = '' then begin
        AddStatusKPA('Отсутствует прошивка ' + FirmwareCommand[i] + ' по пути: ' + NEWVersionPath, clRed, polLogRichMain);
        Continue;
      end;
      NEWVersion := Copy(FirmwareNEWName, Length(NameHWVer[i])+1, Length(FirmwareNEWName) - Length(NameHWVer[i]) - Length('.bin'));
      FirmwareNEWVersion := StrToFloat(StringReplace(NEWVersion,'.',',',[rfReplaceAll]));
      AddStatusKPA('Старая прошивка: ' + FirmwareOLDName + '. Новая прошивка: ' + FirmwareNEWName, clBlue, polLogList);
      if FirmwareNEWVersion > FirmwareOLDVersion then begin
        AddStatusKPA('Загрузка новой прошивки: ' + FirmwareNEWName, clBlue, polLogRichMain);
        FileMeterPO := NEWVersionPath + FirmwareNEWName;
        NumCellMeterPO := i;
        FileDownMeterPO;
        AddStatusKPA('Загрузка настроек в КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Успешно', clBlue, polLogRichMain);

      end;

    end;
    FlagAutoFirmware := False;
    ModeRegSett := [polStatus];
  except
    on e:exception do begin
//      showmessage(e.Message);
      AddStatusKPA('THRD.CheckFirmware. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;
end;


procedure TMyThread.FileDownSetup;
var StrArray : TStringDynArray;
i, j : Integer;
ValueFile : string;
AnswerPort : string;
begin
  try
    ProgressDown.NumPanelKPA := NumKPA;

    StrArray := FileSetupKPA.Split([CR_LF]);
    ProgressDown.MaxValue := High(StrArray)-1;
    for i := 0 to High(StrArray)-1 do begin
      if FlagStopThread then begin
        ClosePort;//Synchronize(ClosePort);
        exit;
      end;
      if StrArray[i] <> '' then begin
        ValueFile := Copy(StrArray[i], Pos(':', StrArray[i]) + 1, Length(StrArray[i])-Pos(':', StrArray[i]));
        if ValueFile = '' then ValueFile := '""';
        Command := StrArray[i] + CR_LF;
        AddStatusKPA('Запрос: ' + Command, clBlue, polLogRichMain);
        AnswerPort := ReciveAnswer(Command);
        //'"1"'#$D#$A
        CountRepeat := 0;
        repeat
          if AnswerPort.Contains('KpaError') then begin
            for j := 0 to High(KPAErrorName) do
              if KPAErrorName[j].Contains(Trim(AnswerPort)) then begin
                AddStatusKPA(KPAErrorName[j], clRed, polLogRichMain);
                AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Не успешно', clRed, polLogRichMain);
                Inc(CountRepeat);
        //        ModeRegSett := [polStatus];//Synchronize(ClosePort);
        //        Exit;
              end;
            AddStatusKPA('Запрос: ' + Command, clBlue, polLogRichMain);
            AnswerPort := ReciveAnswer(Command);
          end
          else Break;
        until (CountRepeat > 3) or (AnswerPort.Contains(ValueFile));
        if CountRepeat > 3 then begin
          AddStatusKPA('Ошибка работы в КПА-' + IntToStr(NumKPA + 1), clRed, polStatusLabelKPA);
          ClosePort;//Synchronize(ClosePort);
          Exit;
        end;
        if not AnswerPort.Contains(ValueFile) then begin
          AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Не успешно', clRed, polLogRichMain);
          ClosePort;//Synchronize(ClosePort);
          Exit;
        end
        else begin
        //отправить данные через синхронайз в форму загрузки
          ProgressDown.Value := i;
          Synchronize(GaugeDownSetup_Sync);
        end;

      end;

    end;
    AddStatusKPA('Загрузка настроек в КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Успешно', clBlue, polLogRichMain);
    ModeRegSett := [polStatus];
    FlagDownSetup := False;
  except
    on e:exception do begin
      AddStatusKPA('THRD.FileDownSetup. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;
end;

procedure TMyThread.FileDownMeterPO;
var {i,} j: Integer;
Command, AnswerPort : string;
NameFile : string;
CountByteFile, CountByteStr, ReadCount, FUpdPackNum : Integer;
FUpdPack: TArray< Byte >;
FUpdFS : TFileStream;
crc : Cardinal;
NewSize, i : Word;
p : ^Cardinal;
CheckTry : Integer;
begin
  try
//    FileMeterPO := '\\srv-fs\FileServer\Production\Distrib\KPA_1\ПО для платы СМТ\New_SMT433_LCD8_test_v5.5.bin';
//    NumCellMeterPO := 0
    ProgressDown.NumPanelKPA := NumKPA;
    if FUpdFS <> nil then Application.ProcessMessages;

    FUpdFS := TFileStream.Create(FileMeterPO,  fmShareDenyNone);

    NameFile := ExtractFileName(FileMeterPO);
    CountByteFile := FUpdFS.Size;
    case NumCellMeterPO of
      0: Command := 'FirmwareTest_l433.Update:{' + NameFile + ',' + IntToStr(CountByteFile) + '}' + CR_LF;
      1: Command := 'FirmwareRelease1.Update:{' + NameFile + ',' + IntToStr(CountByteFile) + '}' + CR_LF;
      2: Command := 'FirmwareRelease2.Update:{' + NameFile + ',' + IntToStr(CountByteFile) + '}' + CR_LF;
      3: Command := 'FirmwareRelease3.Update:{' + NameFile + ',' + IntToStr(CountByteFile) + '}' + CR_LF;
    end;
    AddStatusKPA('Запрос: ' + Command, clBlue, polLogRichMain);
    AnswerPort := ReciveAnswer(Command);
    CountRepeat := 0;
    repeat
      if AnswerPort.Contains('KpaError') then begin
        for j := 0 to High(KPAErrorName) do
          if KPAErrorName[j].Contains(Trim(AnswerPort)) then begin
            AddStatusKPA(KPAErrorName[j], clRed, polLogRichMain);
            AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Не успешно', clRed, polLogRichMain);
            Inc(CountRepeat);
//            Synchronize(ClosePort);
//            Exit;
          end;
        AddStatusKPA('Запрос: ' + Command, clBlue, polLogRichMain);
        AnswerPort := ReciveAnswer(Command);
      end;
    until (CountRepeat > 3) or (AnswerPort.Contains('update'));
    if CountRepeat > 3 then begin
      AddStatusKPA('Ошибка работы в КПА-' + IntToStr(NumKPA + 1), clRed, polStatusLabelKPA);
      ClosePort;//Synchronize(ClosePort);
      Exit;
    end;
    if not AnswerPort.Contains('update') then begin
      AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Не успешно', clRed, polLogRichMain);
      ClosePort;//Synchronize(ClosePort);
//      ModeRegSett := [];
      Exit;
    end
    else begin
      CountByteStr := StrToInt(Copy(AnswerPort, Pos(':', AnswerPort)+1, Length(AnswerPort)-Pos(':', AnswerPort) - Length(CR_LF))) - 4;
      SetLength(FUpdPack, CountByteStr);
      FUpdFS.Position:= 0;
      FUpdPackNum := 0;
      CheckTry := 1;
      ProgressDown.MaxValue := Ceil(CountByteFile / CountByteStr);
      repeat
        ReadCount := FUpdFS.Read( FUpdPack[ 0 ], CountByteStr );  // Прочтем из файлового потока пакет байт в массив

        if ( ReadCount < CountByteStr ) then begin                // Если был прочитан последний пакет байт из прошивки,
//          FUpdFS.Free;                                           // то файловый поток с прошивкой больше не нужен
          CountByteStr := ReadCount;                              // и длину пакета уменьшаем до кол-ва считанных байт
        end;

        if CountByteStr > 0 then begin
          if FlagStopThread then begin
            FUpdFS.Free;
            ClosePort;//Synchronize(ClosePort);
            exit;
          end;
          crc := CalcCRC32ByteArr( FUpdPack, CountByteStr );        // Вычислим CRC32 пакета
          NewSize := CountByteStr + SizeOf( crc );                  // Увеличим массив на длину контрольной суммы CRC32
          SetLength( FUpdPack, NewSize );                          // и зададим новую длину

          p := @crc;                                               // Получим указатель на переменную контрольной суммы CRC32
          for i := 0 to SizeOf( crc ) - 1 do                       // Допишем в конец массива FUpdPack полученную CRC32
          Move( Pointer( Cardinal( p ) + i )^, FUpdPack[ CountByteStr + i ], 1 ); // побайтно начиная с младшего байта

          Inc( FUpdPackNum );
          {$IFDEF DEBUG}
          AddStatusKPA(Format( 'Пакет обновления # %d отправлен', [ FUpdPackNum ]), clBlue, polLogRichMain);
          {$ENDIF}
          {$IFDEF RELEASE}
          AddStatusKPA(Format( 'Пакет обновления # %d отправлен', [ FUpdPackNum ]), clBlue, polLogList);
          {$ENDIF}
          AnswerPort := Send_ByteArr( FUpdPack );       // Отправим в поток счётчика
        end;
        if AnswerPort.Contains('ACK') then begin          //если в ответе ACK то увеличиваем позицию на чиста считанных байт
          CheckTry := 1;
        end;
        if AnswerPort.Contains('NAK') then begin          //если в ответе NAK, то позицию не меняет и запускаем пакет еще раз
          FUpdFS.Position := FUpdFS.Position - CountByteStr;
          Inc(CheckTry);
        end;
        if AnswerPort.Contains('CAN OK') then begin          //если в ответе NAK, то позицию не меняет и запускаем пакет еще раз
          Break;
        end;
        if CheckTry = 3 then begin
          Command := 'CAN' + CR_LF;
          AddStatusKPA('Запрос: ' + Command, clBlue, polLogRichMain);
          AnswerPort := ReciveAnswer(Command);
          AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Не успешно', clRed, polLogRichMain);

          Break;
        end;
        ProgressDown.Value := FUpdPackNum;
        Synchronize(GaugeDownMeterPO_Sync);
        if FlagStopThread then begin
          FUpdFS.Free;
          ClosePort;//Synchronize(ClosePort);
          exit;
        end;
      until ProgressDown.MaxValue = FUpdPackNum;
      if ProgressDown.MaxValue = FUpdPackNum then
        AddStatusKPA('Загрузка настроек КПА-' + IntToStr(NumKPA + 1) + ' ' + IntToStr(NumKPA + 1) + ' слот - Успешно', clBlue, polLogRichMain);


      FUpdFS.Free;
      Synchronize(GaugeDownMeterPO_Sync);
    end;
    if not FlagDownSetup then begin
      ModeRegSett := [polStatus];
      FlagDownMeterPO := False;
    end;

  except
    on e:exception do begin
      AddStatusKPA('THRD.FileDownMeterPO. ' + e.Message, clRed, polLogList);
      ClosePort;//Synchronize(ClosePort);
    end;
  end;
end;



function TMyThread.Send_ByteArr( var BArr: TArray<Byte>; WaitResive: Boolean = True): string;
var
  BArrClrRead : TArray<Byte>;
  i, j : Integer;
  ElapsedTime, OutCnt  : Integer;
begin
try
  if not FlagStopThread then begin
    if WaitResive then
      FParsEndCMD := True
    else
      FParsEndCMD := False; // Если ждем завршения команды, парсить ОК или другую концовку ответа
    FTmpRxStr := string.Empty;   //Возвращаемый ответ из порта
    FParsing := False;                //Выставляем общий флаг парсинга, чтобы далее им манипулировать


    ComP.BCP.Write( BArr[ 0 ], Length( BArr ) );
  //  OutCnt := 20;
    j := 0;
    if WaitResive then begin
      while (FParsEndCMD) do
      begin
        sleep(3);
        Application.ProcessMessages;
  //      SetLength( BArrClrRead, OutCnt );
  //      ComP.BCP.Read( BArrClrRead[ 0 ], OutCnt );
  //      if BArrClrRead[ 0 ] <> 0 then begin
  //        for i := 0 to length(BArrClrRead) do begin
  //          FTmpRxStr := FTmpRxStr + HexToStr(ByteToHex(BArrClrRead[ i ]));
  //        end;
  //        FParsEndCMD := False;
  //      end;

        if (FTmpRxStr.IsEmpty) then begin
          if ((FTmpRxStr.IsEmpty) and (j >= Round(TimeOut / 10))) or
            ((FTmpRxStr.IsEmpty) and (FlagStopThread)) then  begin
            AddStatusKPA('Данных нет или время ожидания истекло!', clRed, polLogRichMain);
            Break;
          end;
          Inc(j);
          ElapsedTime := j;
        end;
      end;
      Result := FTmpRxStr;
    end
    else                         // Если не ждем ответ на команду
     Result := string.Empty;
  end;
  FTmpRxStr := string.Empty;
except
  on e:exception do begin
//    showmessage(e.Message);
    AddStatusKPA('THRD.ReciveAnswer. Ошибка ' + e.Message, clRed, polLogList);
    ClosePort;//Synchronize(ClosePort);
  end;
end;


end;

function TMyThread.ReciveAnswer(Command: string; WaitResive: Boolean = True): string;
var
  j: Integer;
  ElapsedTime  : Integer;
begin
try
//  Synchronize(Stop_Sync);
  if not FlagStopThread then begin
//  begin
//    if ComP.BCP = nil then
//    if not ComP.BCP.Connected then begin
//      AddStatusKPA('Отключение COM' + ComP.BCP.Port, clRed, polStatusRichKPA);
//      Synchronize(ClosePort);
////        ModeRegSett := [];
//      Exit;
//    end;
    if ComP.BCP.InBufCount = 0 then
    begin                                           // Если в буфере приема пусто
      if WaitResive then
        FParsEndCMD := True
      else
        FParsEndCMD := False; // Если ждем завршения команды, парсить ОК или другую концовку ответа
      FTmpRxStr := string.Empty;   //Возвращаемый ответ из порта
      FParsing := False;                //Выставляем общий флаг парсинга, чтобы далее им манипулировать.
//      {$IFDEF DEBUG}
//      if (ModeRegSett <> [polStatus]) or (ModeRegSett <> [polGetStatusScript]) then
//        AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogRichMain);
//      {$ENDIF}
//      {$IFDEF RELEASE}
//      if (ModeRegSett <> [polStatus]) or (ModeRegSett <> [polGetStatusScript]) then
//        AddStatusKPA('Запрос: ' + Trim(Command), clBlue, polLogList);
//      {$ENDIF}

      ComP.BCP.WriteStr(Command);
//      ElapsedTime := 0;                                   // Если ждем завршения команды,
      j := 0;
      if WaitResive then begin
        while (FParsEndCMD) do
        begin
          sleep(3);
          Application.ProcessMessages;
          if (FTmpRxStr.IsEmpty) then begin
            if ((FTmpRxStr.IsEmpty) and (j >= Round(TimeOut / 10))) or
              ((FTmpRxStr.IsEmpty) and (FlagStopThread)) then  begin
              AddStatusKPA('Данных нет или время ожидания истекло!', clRed, polLogRichMain);
              Break;
            end;
            Inc(j);
            ElapsedTime := j;
          end;
        end;
        Result := FTmpRxStr;
      end
      else                         // Если не ждем ответ на команду
       Result := string.Empty;
    end;
  end;
  FTmpRxStr := string.Empty;
except
  on e:exception do begin
//    showmessage(e.Message);
    AddStatusKPA('THRD.ReciveAnswer.' + e.Message, clRed, polLogList);
//    Synchronize(DestoyThread_Sync);
    {if e.Message = 'Ошибка записи в порт' then  }
    ClosePort;//Synchronize(ClosePort);

  end;
end;
end;

procedure TMyThread.BCPRxChar(Sender: TObject; Count: Integer);
var
  Answer : AnsiString;
begin
  if not Application.Terminated then begin
    ComP.BCP.ReadStr(Answer, Count);
//    {$IFDEF DEBUG}
//      if (ModeRegSett <> [polStatus]) or (ModeRegSett <> [polGetStatusScript]) then
//        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogRichMain);
//    {$ENDIF}
//    {$IFDEF RELEASE}
//      if (ModeRegSett <> [polStatus]) or (ModeRegSett <> [polGetStatusScript]) then
//        AddStatusKPA('Ответ: ' + Trim(Answer), clBlue, polLogList);
//    {$ENDIF}
    ComP.FBuffStr := ComP.FBuffStr + Answer;
    if Copy(ComP.FBuffStr, Length(ComP.FBuffStr) - 1, 2) = CR_LF then
    begin
//    polKPA:  {"KPA-1","1.05.04","5","04.01.2000,00:51:50","49560","0",{"7BFFFFC3F","1","1","","","","","","1"}}
//    polParam:  '"0"'#$D#$A
//    polKpaStart:  '{"7F9FFFCFF","1","1","NUMBER_BOARD2=Q100;01;2206;0024;01.02;92","HW_VERSION=0206","","","","0"}'#$D#$A
//    polKpaStart:  'OK'#$D#$A
//    polGetStatusScript:  '";;"7 Сопр.R52 Клапана  ;0 Диапазон настр. от:820 до:1100 Измерено:2982.202;Неверное значен."'#$D#$A
//    polGetModemInfo:  '"";"";"";""'#$D#$A           “IMEI”;”CCID 1 SIM”;”CCID 2 SIM”;”CCID 3 SIM”;
      ComP.BCP.ClearBuffer(True,true);
      FTmpRxStr := ComP.FBuffStr;
      FParsEndCMD := False;
      Delete(ComP.FBuffStr, 1, Length(ComP.FBuffStr));
      ComP.FBuffStr := string.Empty;
//      AddStatusKPA('[ОЧИСТКА] ComP.FBuffStr: ' + ComP.FBuffStr + 'Count: ' + IntToStr(Count), clBlue, polLogList);
    end;
  end;
end;

end.



