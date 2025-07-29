unit KPAFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton, System.Types,
  sMemo, sLabel, sEdit, Vcl.Mask, sMaskEdit, sCustomComboEdit, sComboBox,
  sGroupBox, BCPort, Common, MyThread, Vcl.ComCtrls, sRichEdit, Vcl.ExtCtrls, Utilits;

type
  TframeKPA = class(TFrame)
    grpKPA: TGroupBox;
    cbbPort: TComboBox;
    Label1: TLabel;
    edtSerialChip: TEdit;
    Label2: TLabel;
    lblStatus: TLabel;
    redtComment: TRichEdit;
    btnRepeat: TButton;
    Shape1: TShape;
    procedure btnRepeatClick(Sender: TObject);
    procedure cbbPortChange(Sender: TObject);
    procedure OpenComPortThread;
  strict private
    { Private declarations }
    FMeterIndex: Integer;
    HeightRichComment : Integer;
    procedure SetMeterIndex(const Value: Integer);
  public
    { Public declarations }
    VersionKPA, SerialKPA : string;

    BCP: TBComPort;
    Thread : TMyThread;
    CommandParam : string;
    ActualPortIndex : Integer;
    ActualPort : string;

//    DownPOMeterKPAFrame : boolean;
//    PollingSet : TPollingSet;
    property MeterIndex: Integer read FMeterIndex write SetMeterIndex;
    constructor Create( AOwner: TComponent; const meter_index: integer );
    destructor  Destroy; override;
    procedure SendSetupKPA(CommandFile : string);
    procedure SendMeterPO(NameFile : string; NumCell : integer);
    procedure ThreadStop;
  end;

var
  frmKPAFrame  : TframeKPA;

  function CreateMeterFrame( const index: Integer; const owner: TComponent ): TframeKPA;

implementation

{$R *.dfm}

uses
  MainForm, Setup;



// Создание Frame на вкладке
function CreateMeterFrame( const index: Integer; const owner: TComponent ): TframeKPA;
begin
  Result := TframeKPA.Create( owner, index );
end;

// Создание фрейма (конструктор)
procedure TframeKPA.btnRepeatClick(Sender: TObject);
begin
  if cbbPort.ItemIndex = -1 then Exit;

  if frmMainForm.CheckOpenComPort(cbbPort.Text) then begin
    OpenComPortThread;
  end
  else begin
    lblStatus.Font.Color := clRed;
    lblStatus.Caption := 'СОМ порт занят';
  end;
end;

procedure TframeKPA.cbbPortChange(Sender: TObject);
begin
  if frmMainForm.SelectPort(FMeterIndex) then begin
    lblStatus.Font.Color := clBlack;
    lblStatus.Caption := 'Статус КПА и порта';
    ThreadStop;
  end;

  if cbbPort.ItemIndex = -1 then begin
//    cbbPort.Text := ActualPort;
    cbbPort.ItemIndex := ActualPortIndex;
  end;

end;



constructor TframeKPA.Create( AOwner: TComponent; const meter_index: integer );
var
  i: Integer;
//cc: TControlCanvas;
begin
  try
    inherited Create(AOwner);

    if ( AOwner is TWinControl ) then
      Self.Parent := TWinControl( AOwner );
//    BCP := TBComPort.Create(Self);
//    sl_PortsList := TStringList.Create;               // Создание список доступных Com-портов
//    EnumComPorts(sl_PortsList);                       // Наполняем список портов
//    cbbPort.Items := sl_PortsList;                    // Заполняем комбо списком доступных портов
    ActualPortIndex := -1;
    SetMeterIndex(meter_index);
    HeightRichComment := redtComment.Height;
    Shape1.Pen.Color := clGray;
  except
    on e:exception do begin
      frmMainForm.AddLogRichMain('Ошибка ' + e.Message, clRed);
//      showmessage(e.Message);
      FrmLog.SendToLog('TframeKPA.Create.[' + IntToStr(meter_index) + '] Ошибка ' + e.Message, logError);
    end;
  end;
end;


destructor TframeKPA.Destroy;
begin
//  FControl.Free;
  inherited Destroy;

end;

procedure TframeKPA.SetMeterIndex(const Value: Integer);
begin
  FMeterIndex := Value;
end;



procedure TframeKPA.OpenComPortThread;
begin
  try
    cfg_params.ports[MeterIndex] := cbbPort.Text;
    ActualPort := cbbPort.Text;
    ActualPortIndex := cbbPort.ItemIndex;
    Thread := TMyThread.Create(true);
    Thread.FreeOnTerminate := false;
    Thread.Priority := tpLower;
    Thread.Port := cbbPort.Text;
    Thread.BaudRate := TBaudRate(frmSetup.cbxBaudRate.ItemIndex); // Определили скорость обмена
    Thread.NumKPA := FMeterIndex;
    Thread.TimeOut := frmSetup.speReadTimeOut.Value;
    Thread.FlagDownSetup := false;
    Thread.FlagDownMeterPO := false;
//    DownPOMeterKPAFrame := false;
    Thread.Resume();
//    HeightRichComment := redtComment.Height;     //  108;
    btnRepeat.Visible := false;
    btnRepeat.Enabled := false;
    redtComment.Height := HeightRichComment{redtComment.Height} + btnRepeat.Height;
    Shape1.Height := HeightRichComment{redtComment.Height} + btnRepeat.Height + Shape1.Pen.Width*2;
    lblStatus.Font.Color := clBlack;
    lblStatus.Caption := 'Статус КПА и порта';
  except
    on e:exception do begin
      frmMainForm.AddLogRichMain('Ошибка ' + e.Message, clRed);
//      showmessage(e.Message);
      FrmLog.SendToLog('TframeKPA.OpenComPortThread.[' + IntToStr(FMeterIndex) + '] Ошибка ' + e.Message, logError);
    end;
  end;
end;

procedure TframeKPA.ThreadStop;
begin
  try
    if Thread <> nil then
    begin
      Thread.Terminate;
      Thread := nil;
    end;
    btnRepeat.Visible := True;
    btnRepeat.Enabled := True;
    redtComment.Height := HeightRichComment;//redtComment.Height - btnRepeat.Height;
    Shape1.Height := HeightRichComment + Shape1.Pen.Width*2;;
//    grpKPA.Caption := 'Версия ПО КПА и его серийный номер';
    edtSerialChip.Text := EmptyStr;
//    lblStatus.Caption := 'Статус КПА и порта';
    redtComment.Lines.Clear;
    Shape1.Pen.Color := clGray;
  except
    on e:exception do begin
      frmMainForm.AddLogRichMain('Ошибка ' + e.Message, clRed);
//      showmessage(e.Message);
      FrmLog.SendToLog('TframeKPA.OpenComPortThread.[' + IntToStr(FMeterIndex) + '] Ошибка ' + e.Message, logError);
    end;
  end;
end;


procedure TframeKPA.SendMeterPO(NameFile : string; NumCell : integer);
begin
  Thread.FileMeterPO := NameFile;
  Thread.NumCellMeterPO := NumCell;
  Thread.FlagDownMeterPO := true;
//  DownPOMeterKPAFrame := True;
end;

procedure TframeKPA.SendSetupKPA(CommandFile : string);
begin
  Thread.FileSetupKPA := CommandFile;
  Thread.FlagDownSetup := true;
end;

end.

