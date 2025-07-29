unit DownloadSetup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Samples.Gauges, MainForm, Common, Setup, Vcl.ExtCtrls, Vcl.CheckLst, BCPort,
  Vcl.ExtDlgs, MeterInfo;

type
  TfrmDownloadSetup = class(TForm)
    Label1: TLabel;
    edtSetupKPA: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckListBox1: TCheckListBox;
    Panel1: TPanel;
    Gauge1: TGauge;
    Gauge2: TGauge;
    Gauge3: TGauge;
    Gauge4: TGauge;
    Gauge5: TGauge;
    Gauge6: TGauge;
    dlgFileSetupKPA: TFileOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure IncGauge(ProgressDown : TProgressDown);
  end;

var
  frmDownloadSetup: TfrmDownloadSetup;

implementation

{$R *.dfm}

procedure TfrmDownloadSetup.BitBtn1Click(Sender: TObject);
begin
  try
   if dlgFileSetupKPA.Execute then
      edtSetupKPA.Text := dlgFileSetupKPA.FileName;
//   dlgFileSetupKPA.Free;
    FrmLog.SendToLog('Выбранный файл: ' + edtSetupKPA.Text, logMain);
    frmMainForm.redtLog.SelLength := 0;
    frmMainForm.redtLog.SelAttributes.Color := clBlue;
    frmMainForm.redtLog.Lines.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[main] Выбранный файл: ' + edtSetupKPA.Text);

  except
    on e:Exception do MessageBox ( Application.Handle, PChar(e.Message), 'Ошибка.',MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmDownloadSetup.BitBtn2Click(Sender: TObject);
var i, j : Integer;
StrLst : TStringList;
Comp: TComponent;
CommandFile : string;
begin
  if edtSetupKPA.Text = '' then begin
    ShowMessage('Не выбран файл настроек.');
    Exit;
  end;

//  for i := 0 to MAX_SENSOR_COUNT-1 do begin
//    CheckListBox1.State[i] := cbChecked;
//    Comp := FindComponent('Gauge' + IntToStr(i+1));
//    TGauge(Comp).Progress := 0;
//    TGauge(Comp).ForeColor := clBlack;
//  end;
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    if (CheckListBox1.State[i] = cbChecked) and
      (frmMainForm.KPAFrame[i].VersionKPA <> '') and (frmMainForm.KPAFrame[i].SerialKPA <> '') then begin
      Comp := FindComponent('Gauge' + IntToStr(i+1));
      StrLst := TStringList.Create;
      StrLst.LoadFromFile(edtSetupKPA.Text);
      TGauge(Comp).MaxValue := StrLst.Count-1;
      CommandFile := '';

      for j := 0 to StrLst.Count-1 do begin
        CommandFile := CommandFile + StringReplace(StrLst[j],'=',':',[rfReplaceAll]) + CR_LF;
      end;
      StrLst.Free;
      FrmLog.SendToLog('Данные файла отправлены на запись в КПА-' + IntToStr(i), logMain);
      frmMainForm.KPAFrame[i].SendSetupKPA(CommandFile);

    end
    else if (CheckListBox1.State[i] = cbChecked) and
     ((frmMainForm.KPAFrame[i].VersionKPA = '') or (frmMainForm.KPAFrame[i].SerialKPA = '')) then begin
      CheckListBox1.State[i] := cbGrayed;
    end;

  end;
//  StrLst.Free;
end;

procedure TfrmDownloadSetup.FormShow(Sender: TObject);
var i : integer;
Comp: TComponent;
begin
  for i := 0 to 5 do begin
    CheckListBox1.State[i] := cbChecked;
    Comp := FindComponent('Gauge' + IntToStr(i+1));
    TGauge(Comp).Progress := 0;
    TGauge(Comp).ForeColor := clBlack;
  end;
  FrmLog.SendToLog('Открытие формы DownloadSetup.', logMain);
  frmMainForm.AddLogRichMain('[main] Открытие окна загрузки настроек КПА', clblue);
end;

procedure TfrmDownloadSetup.IncGauge(ProgressDown : TProgressDown);
var Comp: TComponent;
begin
  Comp := FindComponent('Gauge' + IntToStr(ProgressDown.NumPanelKPA+1));
  TGauge(Comp).MaxValue := ProgressDown.MaxValue;
  TGauge(Comp).Progress := ProgressDown.Value;
  if TGauge(Comp).MaxValue = TGauge(Comp).Progress then begin
    TGauge(Comp).ForeColor := clGreen;
//    frmMainForm.KPAFrame[ProgressDown.NumPanelKPA].DownPOMeterKPAFrame := False;
  end;
  if (frmMainForm.KPAFrame[ProgressDown.NumPanelKPA].Thread = nil)
    and (TGauge(Comp).MaxValue > TGauge(Comp).Progress) then
    TGauge(Comp).ForeColor := clRed;
  Application.ProcessMessages;

end;

end.
