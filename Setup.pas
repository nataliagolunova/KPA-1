unit Setup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, sDialogs, sSkinProvider, Vcl.Mask,
  sMaskEdit, sCustomComboEdit, sComboBox, sComboBoxes, Vcl.StdCtrls, sCheckBox,
  Vcl.Buttons, sBitBtn, sEdit, sGroupBox, Common, DataModel, DB, sLabel,
  System.ImageList, Vcl.ImgList, acAlphaImageList, sSpinEdit, Vcl.Samples.Spin;

type
  TfrmSetup = class(TForm)
    fodDatabase: TFileOpenDialog;
    fodUpdate: TFileOpenDialog;
    flpndlgLog: TFileOpenDialog;
    GroupBox1: TGroupBox;
    speReadTimeOut: TSpinEdit;
    cbxBaudRate: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    sLabel1: TLabel;
    edtSrvStr: TEdit;
    edtFBDStr: TEdit;
    edtConnectionStr: TEdit;
    sbtbtnOpenBase: TBitBtn;
    GroupBox3: TGroupBox;
    cbxAutoUpdate: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    edtUpdatePath: TEdit;
    edtLogPath: TEdit;
    btnUpdPath: TBitBtn;
    sbtbtnLogPath: TBitBtn;
    sbtbtnSave: TBitBtn;
    sbtbtnSignOut: TBitBtn;
    chkExtendedLog: TCheckBox;
    procedure edtSrvStrChange(Sender: TObject);
    procedure edtFBDStrChange(Sender: TObject);
    procedure sbtbtnOpenBaseClick(Sender: TObject);
    procedure cbxAutoUpdateClick(Sender: TObject);
    procedure btnUpdPathClick(Sender: TObject);
    procedure sbtbtnSaveClick(Sender: TObject);
    procedure sbtbtnSignOutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplyParams;
    procedure sbtbtnLogPathClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSetup: TfrmSetup;

implementation

{$R *.dfm}

procedure TfrmSetup.btnUpdPathClick(Sender: TObject);
begin
try
   if fodUpdate.Execute then
      edtUpdatePath.Text := fodUpdate.FileName + PathDelim;
  except
    on e:Exception do MessageBox ( Application.Handle, PChar(e.Message), 'Ошибка.',MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmSetup.cbxAutoUpdateClick(Sender: TObject);
begin
  cfg_params.search_update := cbxAutoUpdate.Checked;
end;

procedure TfrmSetup.edtFBDStrChange(Sender: TObject);
begin
  if Trim (edtSrvStr.Text) <> '' then edtConnectionStr.Text := Trim (edtSrvStr.Text) + ':' + Trim(edtFBDStr.Text)
  else edtConnectionStr.Text := Trim(edtFBDStr.Text);
end;

procedure TfrmSetup.edtSrvStrChange(Sender: TObject);
begin
  if Trim (edtSrvStr.Text) <> '' then edtConnectionStr.Text := Trim (edtSrvStr.Text) + ':' + Trim(edtFBDStr.Text)
  else edtConnectionStr.Text := Trim(edtFBDStr.Text);
end;


procedure TfrmSetup.FormCreate(Sender: TObject);
begin
  ApplyParams;
end;

procedure TfrmSetup.FormShow(Sender: TObject);
begin
  ModalResult := mrNone;
  if InterbaseDatabaseExists(cfg_params.connection_db, DB_USER, DB_PASSWORD)='OK'
    then sLabel1.Caption := 'Соединение с базой: установлено'
    else sLabel1.Caption := 'Соединение с базой: отсутствует';
end;

procedure TfrmSetup.sbtbtnSignOutClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSetup.sbtbtnSaveClick(Sender: TObject);
begin
  with cfg_params do begin
    timeout := speReadTimeOut.Value;
    speed := cbxBaudRate.ItemIndex;

    srv_name_db := edtSrvStr.Text;
    filepath_db := edtFBDStr.Text;
    connection_db := edtConnectionStr.Text;

    search_update := cbxAutoUpdate.Checked;
    update_exe_path := edtUpdatePath.Text;
    log_path := edtLogPath.Text;
    log_extended := chkExtendedLog.Checked;
//    CVE1_update := cbxAutoUpdate.Checked;
//    CVE1_update_path := edtUpdatePath.Text;

  end;

  sLabel1.Caption := 'Соединение с базой...';
//  Application.ProcessMessages;


  if InterbaseDatabaseExists(edtConnectionStr.Text, DB_USER, DB_PASSWORD)='OK' then begin
    cfg_params.connection_db := edtConnectionStr.Text;
    if DataMod.IBDatabase1.Databasename <> cfg_params.connection_db then
      DataMod.IBDatabase1.Close;
    DataMod.IBDatabase1.Databasename := cfg_params.connection_db;
    ModalResult := idOK;
    Application.ProcessMessages;
    if not DataMod.IBDatabase1.Connected then DataMod.IBDatabase1.Open;
    sleep(2000);
    sLabel1.Caption := 'Соединение с базой: установлено';
    SaveParam;
//    frmSetup.CloseModal;          // Закрываем форму, все нормально     вот эта строка под вопросом, при смене имени бд, тут ломается все
  end else begin                      // А тут не дадим закрыть форму, нет соединения с базой
    sLabel1.Color := clRed;
    sLabel1.Caption := 'Соединение с базой: отсутствует';
    Application.ProcessMessages;
    DataMod.IBDatabase1.Close;
  end;
  ShowMessage('Сохранено');
  Close;
end;

procedure TfrmSetup.sbtbtnLogPathClick(Sender: TObject);
begin
  try
    if flpndlgLog.Execute then
      edtLogPath.Text := flpndlgLog.FileName + PathDelim;
  except
    on e:Exception do MessageBox ( Application.Handle, PChar(e.Message), 'Ошибка.',MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmSetup.sbtbtnOpenBaseClick(Sender: TObject);
begin
  try
   if fodDataBase.Execute then
      edtFBDStr.Text := fodDataBase.FileName;
  except
    on e:Exception do MessageBox ( Application.Handle, PChar(e.Message), 'Ошибка.',MB_OK + MB_ICONINFORMATION);
  end;
end;


procedure TfrmSetup.ApplyParams;
 begin
  // ------------- Применяем параметры  ----------------
    with cfg_params do begin
//      edtSrvStr.Text := srv_name_db;
//      {$IFDEF DEBUG}
//      edtSrvStr.Text := 'localhost';
//      {$ENDIF}
//      {$IFDEF RELEASE}
      edtSrvStr.Text := srv_name_db;
//      {$ENDIF}

      speReadTimeOut.Value := timeout;
      cbxBaudRate.ItemIndex := speed;
      edtFBDStr.Text := filepath_db;
//      connection_db := edtSrvStr.Text + ':' + filepath_db;
      edtConnectionStr.Text := connection_db;

      cbxAutoUpdate.Checked := search_update;
      edtUpdatePath.Text := update_exe_path;
      edtLogPath.Text := log_path;
      chkExtendedLog.Checked := log_extended;
//      cbxAutoUpdate.Checked := CVE1_update;
//      edtUpdatePath.Text := CVE1_update_path;
    end;
 end;

end.
