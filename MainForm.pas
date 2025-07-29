unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton,
  DataModel, DB, Vcl.ExtCtrls, Authorization, Vcl.ComCtrls, BCPort, System.MaskUtils,
  sStatusBar, Utils, sMemo, sLabel, sEdit, Vcl.DBCtrls, sPanel, DBGridEh, CRCFunc,
  Vcl.Mask, DBCtrlsEh, DBLookupEh, sDBLookupComboBox, sMaskEdit, Common, Utilits,
  sCustomComboEdit, sComboBox, sGroupBox, KPAFrame, sPageControl, sSplitter,
  sRichEdit, System.SyncObjs, FirebirdUtils, acArcControls, Vcl.ActnMan, System.Generics.Collections,
  Vcl.ActnCtrls, System.Actions, Vcl.ActnList, Vcl.ToolWin, Vcl.Menus, MeterInfo;

type

  TfrmMainForm = class(TForm)
    tmrLog: TTimer;
    pnlTop: TPanel;
    edtFocusSerial: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    spnlCenter: TPanel;
    sPanel1: TPanel;
    sPanel2: TPanel;
    sPanel3: TPanel;
    sPanel4: TPanel;
    sPanel5: TPanel;
    sPanel6: TPanel;
    Splitter1: TSplitter;
    spnlBottom: TPanel;
    redtLog: TRichEdit;
    sStatusBar1: TStatusBar;
    Label3: TLabel;
    ToolBar1: TToolBar;
    btnSetup: TToolButton;
    btnDownSetup: TToolButton;
    btnDownMeterPO: TToolButton;
    cbbPreset: TDBLookupComboboxEh;
    btnAutoHW: TToolButton;
    tmrWriteSerial: TTimer;
    Timer1: TTimer;

    procedure btnSetupClick(Sender: TObject);
    procedure tmrLogTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DestroyThread(NumThread : Integer);
    procedure AddNameKPA(num_kpa_log : integer);
    procedure AddRich(num_kpa_log : integer);
    procedure AddRichFromMain(num_kpa_log : integer; Str: string; Color : TColor; Status: TPollingStatus);
    procedure AddStatusKPA(num_kpa : integer; log_text : string; color : Tcolor);
    procedure AddCommentKPA(num_kpa : integer; log_text : string; color : Tcolor);
    procedure AddLogRichMain(log_text : string; color : Tcolor);
    procedure SaveBDModem(NumKpa : Integer);
    function CheckMaskSerial(num_kpa : Integer; Serial : string): Boolean;
    procedure SaveBD(NumKpa : Integer);
    procedure StartThreadKPA;
    procedure btnDownSetupClick(Sender: TObject);
    procedure btnDownMeterPOClick(Sender: TObject);
    procedure cbbPresetCloseUp(Sender: TObject; Accept: Boolean);
    procedure btnAutoHWClick(Sender: TObject);
    function CreateCommandKpaParam(num_kpa : Integer; SerialQR : string): Boolean;
    function SaveBoardTestResultsToDB(num_kpa : integer; out MsgStr : string ) : Boolean;
    procedure edtFocusSerialChange(Sender: TObject);
    procedure redtLogClick(Sender: TObject);
    procedure spnlBottomClick(Sender: TObject);
    procedure tmrWriteSerialTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    OldSerialQR :string;

  public
    { Public declarations }
    KPAFrame: array[0..MAX_SENSOR_COUNT-1] of TframeKPA;
    function SelectPort(meter_index : Integer): boolean;
    function CheckOpenComPort(Port: string): Boolean;
    procedure DeleteSerial(NumKPA : Integer);
    procedure ReadSerialQR;

  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

uses Setup, DownloadSetup, DownloadMeterPO;


procedure TfrmMainForm.btnAutoHWClick(Sender: TObject);
var i : Integer;
begin
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    if(KPAFrame[i].VersionKPA <> '') and (KPAFrame[i].SerialKPA <> '') then begin
      KPAFrame[i].Thread.FlagAutoFirmware := True;
    end

  end;
end;

procedure TfrmMainForm.btnDownMeterPOClick(Sender: TObject);
begin
  frmDownloadMeterPO.Show;
end;

procedure TfrmMainForm.btnDownSetupClick(Sender: TObject);
begin
  frmDownloadSetup.Show;
end;

procedure TfrmMainForm.btnSetupClick(Sender: TObject);
begin
//  frmMainForm.Hide;
  frmSetup.Show;
end;

procedure TfrmMainForm.cbbPresetCloseUp(Sender: TObject; Accept: Boolean);
begin
  cfg_params.id_preset := cbbPreset.KeyValue;
  if ( Assigned( cfg_file ) ) then begin
    cfg_file.WriteInteger('PRESET', 'id', cfg_params.id_preset);

  end;
  AddLogRichMain('Выбранный пресет: ' + cbbPreset.Text, clBlue);
  FrmLog.SendToLog('Выбранный пресет: ' + cbbPreset.Text, logMain);
end;

procedure TfrmMainForm.edtFocusSerialChange(Sender: TObject);
begin
  if edtFocusSerial.Text = '' then Exit;
  EnterSerial := true;
  TimeEnterSerial := Now;
  tmrWriteSerial.Enabled := true;
//  FrmLog.SendToLog('Введенный Qr-код: ' + edtFocusSerial.Text +
//                '. Фиксированное время: ' + DateTimeToStr(TimeEnterSerial), logMain);
end;

procedure TfrmMainForm.ReadSerialQR;
var i, j : Integer;
SerialQR : string;
CheckWaitSerial : Boolean;
begin
  if edtFocusSerial.Text = '' then Exit;

  SerialQR := edtFocusSerial.Text;
 // Q100012410202246622902001030011
  if SerialQR.Contains('$Q') then
    Delete(SerialQR, 1, Pos('$Q',SerialQR));
//  kpa_param.Serial := Trim(SerialQR);
  
  CheckWaitSerial := False;
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    if (meter_board[i].FlagWaitBoard = true) and (KPAFrame[i].edtSerialChip.Text = '') then begin
      AddRichFromMain(i, 'Проверяемый Qr-код: ' + edtFocusSerial.Text, clBlue, polLogRichMain);
      for j := 0 to MAX_SENSOR_COUNT-1 do begin
        if KPAFrame[j].edtSerialChip.Text = SerialQR then begin
          AddRichFromMain(i, 'Плата с номером ' + SerialQR + ' уже используется в КПА-' + IntToStr(j+1) + '.', clRed, polStatusRichKPA);
          edtFocusSerial.Text := '';
          EnterSerial := false;
          meter_board[i].FlagWaitBoard := False;
          Exit;
        end;
      end;
      if not CheckMaskSerial(i, SerialQR) then begin    //проверяем серийник на маску и нормальность
        edtFocusSerial.Text := '';
        EnterSerial := false;
        meter_board[i].FlagWaitBoard := False;
        Exit;
      end
      else if not CreateCommandKpaParam(i, SerialQR) then begin
        edtFocusSerial.Text := '';
        EnterSerial := false;
        meter_board[i].FlagWaitBoard := False;
        Exit;
      end
//        else begin
//          KPAFrame[i].cbbPort.Enabled := False;
//        end;
    end;
  end;
end;





function TfrmMainForm.CheckMaskSerial(num_kpa : Integer; Serial : string): Boolean;
const MaskStr : array [0..3] of string = ({'00000000000;1;x',}
                                          '0000000000000;1;x',
                                          'Q000\;00\;0000\;0000\;00.00;1;x',
                                          'Q000\;00\;0000\;0000\;00.00\;AA;1;x',
                                          'Q0000000000000000000000000000AA;1;x');
var MaskSerial : string;
i : Integer;
CheckWaitSerial : Boolean;
CRCStr, CRCHex : string;
NumPrefixBD, FactPrefix : integer;
NumMask : Integer;
Dec_Characteristic : string;
Dec_Regnumber, Dec_Advmodification : Integer;
begin
  Result := False;

  for i := 0 to High(MaskStr) do begin
    MaskSerial := FormatMaskText(MaskStr[i],Serial);
    if MaskSerial = Serial then begin
      NumMask := i;
      Result := true;
      Break;
    end;
  end;
  if not Result then begin
    AddRichFromMain(num_kpa, 'Введен неверный децимальный номер.', clRed, polStatusRichKPA);
  end;

  if (Result) and (cfg_params.id_preset = 0) then begin
    AddRichFromMain(num_kpa, 'Не выбран пресет.', clRed, polStatusRichKPA);
    Exit(False);
  end;

  if Result then begin
    if Serial.Contains(BOARD_SERIAL_PREFIX) then FactPrefix := StrToInt(Copy(Serial, 2, 3))
    else FactPrefix := StrToInt(Copy(Serial, 1, 3));

    if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
    NumPrefixBD := GetQueryAloneValue(datamod.IBDatabase1,'select prefix3 from BOARDTYPEDICT, METERBOARDDICT, CVE1SETTINGS ' +
                                                          'where BOARDTYPEDICT.id = METERBOARDDICT.boardtypenameid and ' +
                                                          'METERBOARDDICT.id = CVE1SETTINGS.boardtypeid and CVE1SETTINGS.id = :pPreset',
                                                          [cfg_params.id_preset], 0);
    FrmLog.SendToLog('[SQL][' + Serial + '] ' + IntToStr(NumPrefixBD)+ ': select prefix3 from BOARDTYPEDICT, METERBOARDDICT, CVE1SETTINGS ' +
                                  'where BOARDTYPEDICT.id = METERBOARDDICT.boardtypenameid and ' +
                                  'METERBOARDDICT.id = CVE1SETTINGS.boardtypeid and CVE1SETTINGS.id = ' + IntToStr(cfg_params.id_preset), logMain);
    if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;
    if FactPrefix <> NumPrefixBD then begin
      AddRichFromMain(num_kpa, 'Выбранный пресет не соответствует типу платы.', clRed, polStatusRichKPA);
      Exit(False);
    end;
  end;
  if Serial.Length = BRDLENGTH_31 then begin
    Dec_Characteristic := Copy(Serial, 15, 6);
    if Dec_Characteristic <> '466229' then begin
      AddRichFromMain(num_kpa, 'Введен неверный децимальный номер.', clRed, polStatusRichKPA);
      Exit(False);
    end;
    Dec_Regnumber := StrToInt(Copy(Serial, 21, 3));
    if Dec_Regnumber >= 19 then begin
      Dec_Advmodification := StrToInt(Copy(Serial, 26, 2));
      if not Dec_Advmodification in [1,2,3] then begin
        AddRichFromMain(num_kpa, 'Не верное дополнительное исполнение сборки.', clRed, polStatusRichKPA);
        Exit(False);
      end;
    end;
  end;

  if Result then if (NumMask in [2, 3]) then  begin //проверить контрольную сумму
    CRCHex := Copy(Serial, Length(Serial)- 1, 2);
    CRCStr := Copy(Serial, 1, Length(Serial)- 2);
    var kost := IntToHex(CRC8(CRCStr));
    if IntToHex(CRC8(CRCStr)) <> CRCHex then begin
      AddRichFromMain(num_kpa, 'Введен неверный децимальный номер.', clRed, polStatusRichKPA);
      Exit(False);
    end;
  end;
end;

function TfrmMainForm.CreateCommandKpaParam(num_kpa : Integer; SerialQR : string): Boolean;
var
BoardID : Cardinal;
MetBrdTypeID : integer;
BrdTypeID : Word;
begin
  try
    edtFocusSerial.Enabled := False;
    sStatusBar1.Panels[0].Text := '';
    meters_info[ num_kpa ].Clear;
    SerialQR := StringReplace(SerialQR,';',',',[rfReplaceAll]);
    meters_info[num_kpa].BoardSerial := SerialQR;
    if SerialQR.Length = BRDLENGTH_13 then begin
      if not dataMod.IBTransaction1.Active then dataMod.IBTransaction1.StartTransaction;
      meters_info[ num_kpa ].HWVerStr := GetQueryAloneValue(datamod.IBDatabase1,'select METERBOARDDICT."VERSION" from METERBOARDDICT, CVE1SETTINGS '+
                                                                         'where (CVE1SETTINGS.boardtypeid = METERBOARDDICT.id) and (CVE1SETTINGS.id = :pID)', [cbbPreset.keyvalue], '');
      FrmLog.SendToLog('[SQL] ' + meters_info[ num_kpa ].HWVerStr + ': select METERBOARDDICT."VERSION" from METERBOARDDICT, CVE1SETTINGS '+
                                                            'where (CVE1SETTINGS.boardtypeid = METERBOARDDICT.id) and (CVE1SETTINGS.id = ' + IntToStr(cbbPreset.keyvalue), logMain);
      if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;
    end;

  //  mtr_info[num_kpa].DeviceInfo.BoardSerial := ;

    BoardID := meters_info[ num_kpa ].SearchOrAddBoard( datamod.IBDatabase1, MetBrdTypeID, BrdTypeID, ErrStr );
  //  if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;

    if ( BoardID = 0 ) or ( ErrStr.Contains( 'ОШИБКА' )) then begin
      AddRichFromMain(num_kpa, ErrStr, clRed, polStatusRichKPA);
  //    AddCommentKPA(num_kpa, ErrStr, clRed);
      edtFocusSerial.Enabled := True;
      Exit(false);
    end;


    //получаем маску из пресета
    if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
    var ScriptsMask := GetQueryAloneValue(datamod.IBDatabase1,'select CVE1SETTINGS.enable_script from CVE1SETTINGS '+
                                                                         'where(CVE1SETTINGS.id = :pID)', [cbbPreset.keyvalue], 0);
    FrmLog.SendToLog('[SQL] ' + IntToStr(ScriptsMask) + ': select CVE1SETTINGS.enable_script from CVE1SETTINGS '+
                                                            'where(CVE1SETTINGS.id = ' + IntToStr(cbbPreset.keyvalue), logMain);
    if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;

    kpa_param.ExecScriptsMask := '"' + IntToHex({StrToUInt64(}ScriptsMask{)}) + '"';

    //номер прошивки
    case BrdTypeID of
      1..4 : kpa_param.FirmwareReleaseIndex := '"1"';
      5..6 : kpa_param.FirmwareReleaseIndex := '"2"';
      7..8 : kpa_param.FirmwareReleaseIndex := '"3"';
    end;
    //значения по умолчанию
    kpa_param.RamCommand3 := '""';
    kpa_param.RamCommand4 := '""';
    if SerialQR.length = BRDLENGTH_31 then begin
  //  неверное доп.исполнение сборки
      if meters_info[ num_kpa ].DeviceInfo.BoardDecimalNum.dnRegNumber >= 19 then
        case meters_info[ num_kpa ].DeviceInfo.BoardDecimalNum.dnAdvModification of
          2: kpa_param.RamCommand3 := '"SIM3=1:1"';
          3: begin
            kpa_param.RamCommand3 := '"SIM3=1:1"';
            kpa_param.RamCommand4 := '"SIM2=1:1"';
          end;
        end;
    end;
    //итог
  //  kpa_param.ExecScriptsMask := '"' + kpa_param.ExecScriptsMask + '"';
    kpa_param.FirmwareEepromDataIndex := '"1"';
    kpa_param.RamCommand1 := '"NUMBER_BOARD2=' + meters_info[num_kpa].BoardSerial + '"';
    kpa_param.RamCommand2 := '"HW_VERSION=' + StringReplace(meters_info[num_kpa].HWVerStr,'.','',[rfReplaceAll]) + '"';
    kpa_param.RamCommand5 := '""';
    kpa_param.UsbReConnect := '"1"';   //1

    KPAFrame[num_kpa].Thread.CommandParam := kpa_param.ExecScriptsMask + ',' +
                  kpa_param.FirmwareReleaseIndex + ',' +
                  kpa_param.FirmwareEepromDataIndex + ',' +
                  kpa_param.RamCommand1 + ',' +
                  kpa_param.RamCommand2 + ',' +
                  kpa_param.RamCommand3 + ',' +
                  kpa_param.RamCommand4 + ',' +
                  kpa_param.RamCommand5 + ',' +
                  kpa_param.UsbReConnect;
    KPAFrame[num_kpa].edtSerialChip.Text :=  meters_info[num_kpa].BoardSerial;
    edtFocusSerial.Text := '';
    edtFocusSerial.Enabled := True;
    Result := True;
    ToolBar1.Enabled := false;
    edtFocusSerial.SetFocus;
  except
    on e:exception do begin
      edtFocusSerial.Enabled := True;
      AddLogRichMain('Ошибка ' + e.Message, clRed);
      FrmLog.SendToLog('frmMainForm.CreateCommandKpaParam. Ошибка ' + e.Message, logError);
    end;
  end;
end;


procedure TfrmMainForm.DeleteSerial(NumKPA : Integer);
begin
//  FrmLog.SendToLog('Вытащили плату ' + KPAFrame[NumKPA].edtSerialChip.Text, logMain);
//  if KPAFrame[NumKPA].edtSerialChip.Text <> '' then begin
    KPAFrame[NumKPA].edtSerialChip.Text := '';
    KPAFrame[NumKPA].redtComment.Lines.Clear;
  //  meters_info[NumKPA].BoardState := sUnknown;
    KPAFrame[NumKPA].Shape1.Pen.Color := clGray;
//  end;
end;


procedure TfrmMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var i: Integer;
begin
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    if KPAFrame[i].cbbPort.Text <> 'Выберите порт' then cfg_params.ports[i] := KPAFrame[i].cbbPort.Text
    else cfg_params.ports[i] := '';
  end;
  SaveParam;
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    KPAFrame[i].Destroy;
    FrmLog.SendToLog('Уничтожение фрейма номер - ' + IntToStr(i) + ' - успешно!', logMain);

  end;
  for i := 0 to MAX_SENSOR_COUNT - 1 do begin
    meters_info.Remove( mtr_info[ i ] );
  end;
  meters_info.Destroy;
end;

procedure TfrmMainForm.FormShow(Sender: TObject);
var i, j : Integer;
MsgError : string;
username : string;
begin
  try

  //DBLookupComboboxEh1.DropDownBox.Options.dlgAutoFitRowHeightEh - делает строку в списке в два ряда.
//    if not frmSetup.Showing then begin
      edtFocusSerial.SetFocus;
      redtLog.HideSelection := False;
      if CheckUpdateVersion(UpdateVersion, AppVersion) = GreaterThanValue then
        sStatusBar1.Panels[0].Text := 'Доступна новая версия ПО: ' + UpdateVersion.StrVer;

      username := GetQueryAloneValue(datamod.IBDatabase1,'Select fullname from SECUSER where ID = :pID ', [cfg_params.user_ID], '');
      Caption := Application.Title + ': ' + username + '. Версия ПО: ' + AppVersion.StrVer + '.';
      FrmLog.SendToLog('Старт программы ' + Caption + 'Роль: ' + IntToStr(cfg_params.user_role) + '-' + username, logMain);

      if cfg_params.user_role = ROLEADMIN then ToolBar1.Visible := true
      else ToolBar1.Visible := False;

      if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
      try
        dataMod.mteCV1Settings.Open;
        cbbPreset.KeyValue := cfg_params.id_preset;
      finally
        if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;
      end;
      AddLogRichMain('Выбранный пресет: ' + cbbPreset.Text, clBlue);
      FrmLog.SendToLog('Выбранный пресет: ' + cbbPreset.Text, logMain);
      sl_PortsList := TStringList.Create;               // Создание список доступных Com-портов
      EnumComPorts(sl_PortsList);                       // Наполняем список портов
      meters_info := TObjectList<TMeterInfo>.Create; // список объектов класса TMeterInfo, хранящих инфу о счетчике
      meters_info.OwnsObjects := True;   // чтоб потом автоматом освобождались объекты при удалении их из списка
      {Динамически присваиваем каждой панели свой фрейм.
      панели обозначены, как spnlCenter.Controls[i+1], i+1 - потому что первый компонент сплитер}
      for i := 0 to MAX_SENSOR_COUNT-1 do begin
//        if KPAFrame[i] = nil then begin      //костыль, при открытии другой формы. главная форма обновляется
          mtr_info[ i ] := TMeterInfo.Create;
          meters_info.Add( mtr_info[ i ] );
          KPAFrame[i] := CreateMeterFrame(i, TsPanel(spnlCenter.Controls[i+1]));
          KPAFrame[i].Parent := TsPanel(spnlCenter.Controls[i+1]);
          KPAFrame[i].cbbPort.Items := sl_PortsList;                    // Заполняем комбо списком доступных портов
          FrmLog.SendToLog('Создание фрейма номер - ' + IntToStr(i) + ' - успешно!', logMain);
//        end;
      end;
      Application.ProcessMessages;

      StartThreadKPA;
//      Timer1.Enabled := True;
//    end;
  except
    on e:exception do begin
      AddLogRichMain('Ошибка ' + e.Message, clRed);
      FrmLog.SendToLog('frmMainForm.FormShow. Ошибка ' + e.Message, logError);
    end;
  end;
end;

procedure TfrmMainForm.StartThreadKPA;
var i, j : Integer;
work_port : array [0..MAX_SENSOR_COUNT-1] of integer;
kost : string;
begin
  for j := 0 to MAX_SENSOR_COUNT-1 do begin
    for i := 0 to sl_PortsList.Count-1 do begin
      kost := Copy(sl_PortsList[i], Pos('COM', sl_PortsList[i]), Pos(#0, sl_PortsList[i]) - 1);
      if kost = cfg_params.ports[j] then begin
        work_port[j] := i;
        Break;
      end
      else work_port[j] := -1;
    end;
  end;
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    if KPAFrame[i] <> nil then begin      //костыль, при открытии другой формы. главная форма обновляется
      if work_port[i] <> -1 then begin
        KPAFrame[i].cbbPort.ItemIndex := work_port[i];
        if CheckOpenComPort(KPAFrame[i].cbbPort.Text) then begin
          KPAFrame[i].OpenComPortThread;
        end
        else AddStatusKPA(i, 'СОМ порт занят', clRed);
      end;
//      else KPAFrame[i].cbbPort.Text := 'Выберите порт'
    end;
  end;
end;

procedure TfrmMainForm.Timer1Timer(Sender: TObject);
begin
//  if edtFocusSerial.Text = '' then
    edtFocusSerial.SetFocus;
end;

function TfrmMainForm.CheckOpenComPort(Port: string): Boolean;
var BCPort : TBComPort;
begin
  Result := True;
  try
    BCPort := TBComPort.Create(nil);
    BCPort.Port := Port;  // Определили порт
    BCPort.BaudRate := TBaudRate(frmSetup.cbxBaudRate.ItemIndex);
    BCPort.InBufSize := 1024;
    if BCPort.Connected then
      BCPort.Close;
    if BCPort.Open then
      BCPort.Close;
    BCPort.Destroy;

  except
    on e:Exception do begin
      AddLogRichMain('Порт ' + Port + ' занят другой программой!', clRed);
      FrmLog.SendToLog('Ошибка отркытия порта ' + e.Message, logError);
      Result := False;
      BCPort.Destroy;
    end;
  end;
end;


function TfrmMainForm.SelectPort(meter_index : Integer): boolean;
var i, j: integer;
    Port1, Port2 : String;
begin
  try
    Result := True;
    Port1 := KPAFrame[meter_index].cbbPort.Text;
    if KPAFrame[meter_index].ActualPort = Port1 then
      Exit(false);
    for i := 0 to  MAX_SENSOR_COUNT-1 do begin
      if i = meter_index then Continue;
      if KPAFrame[i] <> nil then begin
        Port2 := KPAFrame[i].cbbPort.Text;
        if Port1 = Port2 then begin
          KPAFrame[meter_index].cbbPort.ItemIndex := -1;
          KPAFrame[meter_index].cbbPort.Text := 'Выберите порт';
          Result := false;
          Break;
        end;
      end;
    end;
    FrmLog.SendToLog('SelectPort - Сортировка портов', logMain);
  except
    on e:exception do begin
      AddLogRichMain('Ошибка ' + e.Message, clRed);
      FrmLog.SendToLog('frmMainForm. SelectPort. Ошибка ' + e.Message, logError);
    end;
  end;
end;





procedure TfrmMainForm.AddNameKPA(num_kpa_log : integer);
begin
  KPAFrame[num_kpa_log].grpKPA.Caption := 'Ver: ' + meter_board[num_kpa_log].VersionKPA + ' | Serial: ' +  meter_board[num_kpa_log].SerialKPA;
  Delete( meter_board[num_kpa_log].SerialKPA, 1, 1);
  Delete( meter_board[num_kpa_log].SerialKPA, Length( meter_board[num_kpa_log].SerialKPA), 1);

  if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
  meter_board[num_kpa_log].StandID := GetQueryAloneValue(datamod.IBDatabase1,'select STANDID from STAND where STANDNUM = :pNum', [ meter_board[num_kpa_log].SerialKPA], 0);
  FrmLog.SendToLog('[SQL] ' + IntToStr(meter_board[num_kpa_log].StandID)+ ': select STANDID from STAND where STANDNUM = ' +  meter_board[num_kpa_log].SerialKPA, logMain);
  if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;

  
  KPAFrame[num_kpa_log].VersionKPA :=  meter_board[num_kpa_log].VersionKPA;
  KPAFrame[num_kpa_log].SerialKPA :=  meter_board[num_kpa_log].SerialKPA;

end;

//Вывод текста
procedure TfrmMainForm.AddRich(num_kpa_log : integer);
var
i  : integer;
begin
  try
    with meter_board[num_kpa_log] do begin
      case  ThrLogStatus of
        polStatusLabelKPA: begin
          AddStatusKPA(num_kpa_log, THRLogStr, Color);
        end;
        polStatusRichKPA: begin
          AddCommentKPA(num_kpa_log, THRLogStr, Color);
        end;
      end;
      if KPAFrame[num_kpa_log].Thread.FlagDownSetup or KPAFrame[num_kpa_log].Thread.FlagDownMeterPO then
        AddLogRichMain('[' + KPAFrame[num_kpa_log].cbbPort.Text + '][]: ' + THRLogStr, Color)
      else if ThrLogStatus <> polLogList then
        AddLogRichMain('[' + KPAFrame[num_kpa_log].cbbPort.Text + '][' + KPAFrame[num_kpa_log].edtSerialChip.Text + ']: ' + THRLogStr, Color);
      case Color of
        clRed: FrmLog.SendToLog('[' +  KPAFrame[num_kpa_log].cbbPort.Text + '][' +  KPAFrame[num_kpa_log].edtSerialChip.Text + ']: ' + THRLogStr, logError);
        clGreen: FrmLog.SendToLog('[' +  KPAFrame[num_kpa_log].cbbPort.Text + '][' +  KPAFrame[num_kpa_log].edtSerialChip.Text + ']:' + THRLogStr, logSuccess);
        clBlue: FrmLog.SendToLog('[' +  KPAFrame[num_kpa_log].cbbPort.Text + '][' +  KPAFrame[num_kpa_log].edtSerialChip.Text + ']:' + THRLogStr, logMain);
      end;
    end;

  except
    on e:exception do begin
      AddLogRichMain('Ошибка ' + e.Message, clRed);
      FrmLog.SendToLog('frmMainForm. AddRich. Вкладка:' + IntToStr(num_kpa_log) + ': Ошибка ' + e.Message, logError);
    end;
  end;
end;

procedure TfrmMainForm.AddRichFromMain(num_kpa_log : integer; Str: string; Color : TColor; Status: TPollingStatus);
//отвечает за lblStatus, дублируя инфу в rich и логфайл
var a : TPollingStatus;
begin
  meter_board[num_kpa_log].ThrLogStr := Str;
  meter_board[num_kpa_log].ThrLogStatus := Status;
  meter_board[num_kpa_log].Color := Color;
  AddRich(num_kpa_log);
end;

procedure TfrmMainForm.AddStatusKPA(num_kpa : integer; log_text : string; color : Tcolor);
var i : Integer;
begin
  KPAFrame[num_kpa].lblStatus.Font.Color := color;
  KPAFrame[num_kpa].lblStatus.Caption := log_text;
  for i := 0 to High(KPAStatusShort) do
    if (log_text = KPAStatusShort[i]) and (i in [2..5]) then begin
      KPAFrame[num_kpa].cbbPort.Enabled := False;
      Exit;
    end
    else KPAFrame[num_kpa].cbbPort.Enabled := True;
  if (log_text = 'ГОДЕН') or (log_text = 'НЕ ГОДЕН') then KPAFrame[num_kpa].Shape1.Pen.Color := color
  else KPAFrame[num_kpa].Shape1.Pen.Color := clGray;
end;
procedure TfrmMainForm.AddCommentKPA(num_kpa : integer; log_text : string; color : Tcolor);
begin
  KPAFrame[num_kpa].redtComment.Lines.Clear;
  KPAFrame[num_kpa].redtComment.SelAttributes.Color := color;
  KPAFrame[num_kpa].redtComment.Lines.Add(log_text);
end;
procedure TfrmMainForm.AddLogRichMain(log_text : string; color : Tcolor);
begin
  redtLog.SelAttributes.Color := color;
  redtLog.Lines.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + log_text);
//  if redtLog. then redtLog.HideSelection := True
//  else redtLog.HideSelection := False;
end;

procedure TfrmMainForm.redtLogClick(Sender: TObject);
begin
  redtLog.HideSelection := True;
end;
procedure TfrmMainForm.spnlBottomClick(Sender: TObject);
begin
  redtLog.HideSelection := False;
end;

procedure TfrmMainForm.SaveBDModem(NumKpa : Integer);
var
Comment : Boolean;
BoardID : Cardinal;
MetBrdTypeID : integer;
BrdTypeID : Word;
begin
//'861292059039157;;897010201290304683ff;897010201290304675ff'
//  TRY
//    SaveBoardTestResultsToDB
  FrmLog.SendToLog('[Вводные данные] Данные в плате: IMEI = ' + varToStr(meters_info[NumKpa].IMEI) +
  ', SIMID_1 = ' + meters_info[NumKpa].SIMInfo[1].GSMData.ICCID +
  ', SIMID_2 = ' + meters_info[NumKpa].SIMInfo[2].GSMData.ICCID +
  ', SIMID_3 = ' + meters_info[NumKpa].SIMInfo[3].GSMData.ICCID, logMain);

  if not SaveBoardTestResultsToDB(NumKpa, ErrStr ) then  // Если не вышло сохранить результат в БД
  begin
    meters_info[ NumKpa ].BoardState := sUnfit;                     // то делаем негодным
    meter_board[NumKpa].Comment := ErrStr;
//    meter_board[NumKpa].LateScript := ErrStr;
    AddRichFromMain(NumKpa, ErrStr, clRed, polStatusRichKPA);               // и говорим оператору почему не удалось
  end
  else begin           // иначе - удалось сохранить
    meters_info[ NumKpa ].BoardState := sFit;
    AddRichFromMain(NumKpa, ErrStr, clBlue, polLogRichMain);
  end;

  if meters_info[ NumKpa ].BoardState = sUnfit then begin
//      KPAFrame[NumKpa].Shape1.Pen.Color := clRed;
    AddRichFromMain(NumKpa, '~~~ Параметризация и проверка платы завершена не упешно ~~~', clRed, polLogRichMain);
    ToolBar1.Enabled := True;
  end
  else begin
    AddRichFromMain(NumKpa, '~~~ Параметризация и проверка платы завершена упешно ~~~', clGreen, polLogRichMain);
  end;


end;

function TfrmMainForm.SaveBoardTestResultsToDB(num_kpa : integer; out MsgStr : string ) : Boolean;
// Запись результатов проверки и параметризации платы
var i : byte;
  BoardID : Cardinal;
  MetBrdTypeID : integer;
  BrdTypeID : Word;
  Msg :string;
  CRCStr, CRCHex : string;
  Kost : Integer;
begin
  if meters_info[ num_kpa ].BoardSerial.IsEmpty then begin
    MsgStr :=  Format( 'Не возможно сохранить результаты тестирования и '
      + 'параметризации платы в БД, отсутствует серийный номер платы %d!'
      , [ num_kpa + 1 ]);
    Exit( False );
  end
  else begin

    // Поиск или добавление (если не найдена) платы в БД
    BoardID := meters_info[ num_kpa ].SearchOrAddBoard( datamod.IBDatabase1, MetBrdTypeID, BrdTypeID, MsgStr );

    if ( BoardID = 0 ) or ( MsgStr.Contains( 'ОШИБКА' )) then begin
//      meters_info[ NumKpa ].BoardState := sUnfit;    // 0 - Годна (sFit), 1 - Не годна (sUnfit)
      Exit( False );
    end;

    Result := True;
    {Для варианта децимальный номер сборки 01, а так же при вариантах серийных номеров 1-4 в ответе от КПА на команду GetModemInfo CCID допускаются пустые.
Для варианта децимальный номер сборки 02 в ответе от КПА на команду GetModemInfo CCID допускаются пустые только от 1 и 2 сим карт
Для варианта децимальный номер сборки 03 в ответе от КПА на команду GetModemInfo CCID допускаются пустые только от первой сим карты.
}
// Q100012410202246622902001030011

    for i := 1 to MAX_SIM_COUNT do
      if Trim(meters_info[num_kpa].SIMInfo[i].GSMData.ICCID) = '' then
        meters_info[num_kpa].SIMInfo[i].Enable := false
      else meters_info[num_kpa].SIMInfo[i].Enable := True;

    if meters_info[num_kpa].DeviceInfo.BoardDecimalNum.dnRegNumber >= 19 then begin
      case meters_info[num_kpa].DeviceInfo.BoardDecimalNum.dnAdvModification of
        1: begin
          if (meters_info[num_kpa].SIMInfo[2].Enable = true) or
            (meters_info[num_kpa].SIMInfo[3].Enable = True) then begin
            MsgStr :=  Format( 'ОШИБКА! Количество СИМ карт не совпадает с вариантом сборки платы %d!'
              , [ num_kpa + 1 ]);
            Exit( False );
          end;
        end;
        2: begin
          if {(meters_info[num_kpa].SIMInfo[1].Enable = true) or}
            (meters_info[num_kpa].SIMInfo[2].Enable = True) then begin
            MsgStr :=  Format( 'ОШИБКА! Количество СИМ карт не совпадает с вариантом сборки платы %d!'
              , [ num_kpa + 1 ]);
            Exit( False );
          end;
          if meters_info[num_kpa].SIMInfo[3].Enable = false  then begin
            MsgStr :=  Format( 'ОШИБКА! Не возможно сохранить результаты тестирования и '
              + 'параметризации платы в БД, отсутствует третий номер сим карты платы %d!'
              , [ num_kpa + 1 ]);
            Exit( False );
          end;
        end;
        3: begin
//          if (meters_info[num_kpa].SIMInfo[1].Enable = true) then begin
//            MsgStr :=  Format( 'ОШИБКА! Количество СИМ карт не совпадает с вариантом сборки платы %d!'
//              , [ num_kpa + 1 ]);
//            Exit( False );
//          end;
          if (meters_info[num_kpa].SIMInfo[2].Enable = false) or
            (meters_info[num_kpa].SIMInfo[3].Enable = false) then begin
            MsgStr :=  Format( 'ОШИБКА! Не возможно сохранить результаты тестирования и '
              + 'параметризации платы в БД, отсутствует второй и третий номер сим карты платы %d!'
              , [ num_kpa + 1 ]);
            Exit( False );
          end;
        end;
      end;
    end
    else begin
      if (meters_info[num_kpa].SIMInfo[2].Enable = true) or
        (meters_info[num_kpa].SIMInfo[3].Enable = True) then begin
        MsgStr :=  Format( 'ОШИБКА! Количество СИМ карт не совпадает с вариантом сборки платы %d!'
          , [ num_kpa + 1 ]);
        Exit( False );
      end;
    end;

    // Привязка SIM-чипов к плате
    for i := 2 to MAX_SIM_COUNT do begin  // Приязывать будем только SIM-чипы, они начинаются со 2-го
      if meters_info[ num_kpa ].SIMInfo[ i ].Enable // Если сборка не содержит или даже не должна содержать SIM-чипы, то тут должно быть False
        and not meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID.IsEmpty then begin  // или если не определен ICCID SIM, то тоже False
        CRCHex := Copy(meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID, Length(meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID)- 1, 2);
//        CRCStr := Copy(meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID, 1, Length(meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID)- 2);
        Kost := HexToInt(CRCHex);
        if (HexToInt(CRCHex) = 0) or
          (meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID.Length < 18) or
          (meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID.Length > 20) then begin
          MsgStr := Format( 'ОШИБКА! Некорректный ответ от КПА-%d, некорректный номер SIM%u : %s',
           [ num_kpa+1, i , meters_info[ num_kpa ].SIMInfo[ i ].GSMData.ICCID]);
          Result := False;
        end
        else if not meters_info[ num_kpa ].AddOrCheckBoardSIM( datamod.IBDatabase1
          , BoardID, cfg_params.user_ID, cfg_params.stand_id, i, Msg ) then begin
          MsgStr := Format( 'ОШИБКА при привязки SIM%u к плате в БД: %s', [ i, Msg ]);
          Result := False;
          meter_board[ num_kpa ].FBoardStateID := 83;
        end
        else
          MsgStr := Format( '%s%s %s', [ MsgStr, #13#10, Msg ]);
      end;
    end;
    if not Result then
      meters_info[ num_kpa ].BoardState := sUnfit;   // 0 - Годна (sFit), 1 - Не годна (sUnfit)
  end;
end;

procedure TfrmMainForm.SaveBD(NumKpa : Integer);
var
  BoardID : Cardinal;
  MetBrdTypeID : integer;
  BrdTypeID : Word;
begin
  try
    if meters_info[ NumKpa ].BoardSerial.IsEmpty then begin
      ErrStr :=  Format( 'Не возможно сохранить результаты тестирования и '
        + 'параметризации платы в БД, отсутствует серийный номер платы %d!'
        , [ NumKpa + 1 ]);
      meter_board[NumKpa].Comment := ErrStr;
//      meter_board[NumKpa].LateScript := ErrStr;
      AddRichFromMain(NumKpa, ErrStr, clRed, polLogRichMain);
      meter_board[NumKpa].FlagSaveBD := True;
      ToolBar1.Enabled := True;
      Exit;
    end
    else begin

      // Поиск или добавление (если не найдена) платы в БД
      BoardID := meters_info[ NumKpa ].SearchOrAddBoard( datamod.IBDatabase1, MetBrdTypeID, BrdTypeID, ErrStr );
      if ( BoardID = 0 ) or ( ErrStr.Contains( 'ОШИБКА' )) then begin
         meters_info[ NumKpa ].BoardState := sUnfit;    // 0 - Годна (sFit), 1 - Не годна (sUnfit)
        meter_board[NumKpa].Comment := ErrStr;
//        meter_board[NumKpa].LateScript := ErrStr;
        AddRichFromMain(NumKpa, ErrStr, clRed, polLogRichMain);
        meter_board[NumKpa].FlagSaveBD := True;
        ToolBar1.Enabled := True;
        Exit;
      end;
      // Добавление результатов тестирования платы в БД
      if not datamod.AddBoardProbe( datamod.IBDatabase1, cfg_params.user_ID,  meter_board[ NumKpa ].StandID,
          BoardID, meters_info[ NumKpa ], NumKpa, Now, meter_board[ NumKpa ].Comment, meter_board[ NumKpa ].FBoardStateID, ErrStr )
      then begin
        ErrStr := ErrStr + #13#10 + 'ОШИБКА! Не удалось записать в базу результаты '
          + 'тестирования и параметризации платы #'
          + meters_info[ NumKpa ].BoardSerial;
        meters_info[ NumKpa ].BoardState := sUnfit;
        meter_board[NumKpa].FlagSaveBD := True;
        meter_board[NumKpa].Comment := ErrStr;
//        meter_board[NumKpa].LateScript := ErrStr;
        AddRichFromMain(NumKpa, ErrStr, clRed, polLogRichMain);
        ToolBar1.Enabled := True;
        Exit;
      end
      else begin
        ErrStr := ErrStr + #13#10 + 'Рультаты тестирования и параметризации платы № '
          + meters_info[ NumKpa ].BoardSerial + ' сохранены в БД';
        AddRichFromMain(NumKpa, ErrStr, clBlue, polLogRichMain);
      end;
      meter_board[NumKpa].FlagSaveBD := True;
      if meters_info[ NumKpa ].BoardState = sFit then begin
        KPAFrame[NumKpa].edtSerialChip.Text := EmptyStr;
      end;
      ToolBar1.Enabled := True;
    end;

  except
    on e:exception do begin
      AddLogRichMain('Ошибка ' + e.Message, clRed);
      FrmLog.SendToLog('frmMainForm. SaveBD. Ошибка ' + e.Message, logError);
    end;
  end;
end;

procedure TfrmMainForm.DestroyThread(NumThread : Integer);
begin
  KPAFrame[NumThread].ThreadStop;
end;





procedure TfrmMainForm.tmrLogTimer(Sender: TObject);
begin
  SaveLogList;
end;




procedure TfrmMainForm.tmrWriteSerialTimer(Sender: TObject);
begin
  FrmLog.SendToLog('Введенный Qr-код: ' + edtFocusSerial.Text +
                '. Фиксированное время: ' + DateTimeToStr(TimeEnterSerial), logMain);
  tmrWriteSerial.Enabled := False;
end;

end.
