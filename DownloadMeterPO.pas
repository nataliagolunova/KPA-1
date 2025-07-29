unit DownloadMeterPO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.DBCtrls,
  Vcl.Buttons, Common, MainForm, Vcl.ExtDlgs, Vcl.Samples.Gauges, Utilits, CRCFunc,
  Vcl.ExtCtrls, MeterInfo;

type
  TfrmDownloadMeterPO = class(TForm)
    Label1: TLabel;
    edtFilePO: TEdit;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    DBLookupComboBox1: TDBLookupComboBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    BitBtn2: TBitBtn;
    Gauge1: TGauge;
    Gauge2: TGauge;
    Gauge3: TGauge;
    Gauge4: TGauge;
    Gauge5: TGauge;
    Gauge6: TGauge;
    dlgFileMeterPO: TFileOpenDialog;
    cbbCell: TComboBox;
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
  frmDownloadMeterPO: TfrmDownloadMeterPO;

implementation

{$R *.dfm}

procedure TfrmDownloadMeterPO.BitBtn1Click(Sender: TObject);
begin
  try
   if dlgFileMeterPO.Execute then
      edtFilePO.Text := dlgFileMeterPO.FileName;
//   dlgFileMeterPO.Free;
    FrmLog.SendToLog('Выбранный файл: ' + edtFilePO.Text, logMain);
    frmMainForm.redtLog.SelLength := 0;
    frmMainForm.redtLog.SelAttributes.Color := clBlue;
    frmMainForm.redtLog.Lines.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[main] Выбранный файл: ' + edtFilePO.Text);
  except
    on e:Exception do MessageBox ( Application.Handle, PChar(e.Message), 'Ошибка.',MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmDownloadMeterPO.BitBtn2Click(Sender: TObject);
var i: Integer;
CompCheck: TComponent;
Comp: TComponent;
begin
  if edtFilePO.Text = '' then begin
    ShowMessage('Не выбран файл настроек.');
    Exit;
  end;
//  for i := 0 to MAX_SENSOR_COUNT-1 do begin
//    CompCheck := FindComponent('CheckBox' + IntToStr(i+1));
//    TCheckBox(CompCheck).State := cbChecked;
//    Comp := FindComponent('Gauge' + IntToStr(i+1));
//    TGauge(Comp).Progress := 0;
//    TGauge(Comp).ForeColor := clBlack;
//  end;
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    CompCheck := FindComponent('CheckBox' + IntToStr(i+1));
    if (TCheckBox(CompCheck).State = cbChecked) and
          (frmMainForm.KPAFrame[i].VersionKPA <> '') and (frmMainForm.KPAFrame[i].SerialKPA <> '') then begin

      FrmLog.SendToLog('Файл отправлен на запись в КПА-' + IntToStr(i), logMain);
      frmMainForm.KPAFrame[i].SendMeterPO(edtFilePO.Text, cbbCell.ItemIndex);

    end
    else if (TCheckBox(CompCheck).State = cbChecked) and
     ((frmMainForm.KPAFrame[i].VersionKPA = '') or (frmMainForm.KPAFrame[i].SerialKPA = '')) then begin
      TCheckBox(CompCheck).State := cbGrayed;
    end;

  end;
end;

procedure TfrmDownloadMeterPO.FormShow(Sender: TObject);
var i : integer;
CompCheck: TComponent;
Comp: TComponent;
begin
  frmMainForm.redtLog.SelLength := 0;
  frmMainForm.redtLog.SelAttributes.Color := clblue;
  frmMainForm.redtLog.Lines.Add(FormatDateTime('[dd.mm.yyyy hh:nn:ss.zzz]', Now(), fmt_cfg ) + '[main] Открытие окна загрузка ПО для счётчиков');
  FrmLog.SendToLog('Открытие формы DownloadMeterPO.', logMain);
  for i := 0 to MAX_SENSOR_COUNT-1 do begin
    CompCheck := FindComponent('CheckBox' + IntToStr(i+1));
    TCheckBox(CompCheck).State := cbChecked;
    Comp := FindComponent('Gauge' + IntToStr(i+1));
    TGauge(Comp).Progress := 0;
    TGauge(Comp).ForeColor := clBlack;
  end;
end;

procedure TfrmDownloadMeterPO.IncGauge(ProgressDown : TProgressDown);
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
