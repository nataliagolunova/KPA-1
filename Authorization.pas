unit Authorization;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton, sEdit, Vcl.Mask, Common,
  sMaskEdit, sCustomComboEdit, sComboBox, sLabel, Vcl.Buttons, sBitBtn, DataModel, DB, FirebirdUtils,
  DBGridEh, DBCtrlsEh, DBLookupEh, Vcl.DBCtrls, sDBEdit, sDBLookupComboBox, CRCFunc;

type
  TfrmAutor = class(TForm)
    sbtbtnSignIn: TsBitBtn;
    sbtbtnSignOut: TsBitBtn;
    edtPassword: TsEdit;
    cbbLoginSecuser: TDBLookupComboboxEh;
    procedure FormShow(Sender: TObject);
    procedure sbtbtnSignInClick(Sender: TObject);
    procedure sbtbtnSignOutClick(Sender: TObject);
  private
    { Private declarations }
    FlagMsg : Boolean;
  public
    { Public declarations }
  end;

var
  frmAutor: TfrmAutor;

implementation

{$R *.dfm}

procedure TfrmAutor.FormShow(Sender: TObject);
begin
  ModalResult := mrNone;
//  FlagMsg := false;
  if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
  try
    DataMod.mteSecuser.Open;
    cbbLoginSecuser.KeyValue := cfg_params.user_ID;
    Caption := 'KPA-1. Авторизация. Версия ПО: ' + AppVersion.StrVer + '.';
    edtPassword.SetFocus;
  finally
    if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;
  end;

end;

procedure TfrmAutor.sbtbtnSignInClick(Sender: TObject);
begin
  if (edtPassword.Text = '')  then exit;

//  FlagMsg := false;
  dataMod.IBTransaction1.StartTransaction;
  cfg_params.user_role := GetQueryAloneValue(datamod.IBDatabase1,'Select ROLE from SECUSER where STANDID = '#39'21'#39' and SAMACCOUNTNAME = :psAMAccountName ',[cbbLoginSecuser.Text],0);
  cfg_params.user_role_name := GetQueryAloneValue(datamod.IBDatabase1,'Select ROLENAME from USERROLESDICT where ID = :pID', [cfg_params.user_role], 0);
  dataMod.IBTransaction1.Commit;


  if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
  if md5(edtPassword.Text) = DataMod.mteSecuserHESHPASS.Value then begin
    cfg_params.user_ID := cbbLoginSecuser.KeyValue;
    cfg_params.user_name := cbbLoginSecuser.Text;
    cfg_params.user_password := md5(edtPassword.Text);
    ModalResult := mrOk;
  end
  else begin
    ErrStr := 'Пароль введен не верно!';
    FrmLog.SendToLog( ErrStr , logMain);
//    FlagMsg := True;
    var buttonSelected := MessageDlg( ErrStr, mtWarning, [ mbOK ], 0, mbOK );
    if buttonSelected = mrOK then edtPassword.Text := EmptyStr;

  end;
  if dataMod.IBTransaction1.Active then dataMod.IBTransaction1.Commit;

end;

procedure TfrmAutor.sbtbtnSignOutClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;

end.
