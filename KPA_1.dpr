program KPA_1;

uses
  Vcl.Forms,
  System.SysUtils,
  System.IniFiles,
  System.Classes,
  Winapi.ShellAPI,
  System.Types,
  Winapi.Windows,
  Vcl.Dialogs,
  System.UITypes,
  System.IOUtils,
  System.NetEncoding,
  MainForm in 'MainForm.pas' {frmMainForm},
  Authorization in 'Authorization.pas' {frmAutor},
  Common in 'Common.pas',
  Setup in 'Setup.pas' {frmSetup},
  DataModel in 'DataModel.pas' {DataMod: TDataModule},
  FirebirdUtils in '..\LR_LIBS\FirebirdUtils.pas',
  TCPIP_Utils in '..\LR_LIBS\TCPIP_Utils.pas',
  Utilits in '..\LR_LIBS\Utilits.pas',
  Utils in '..\LR_LIBS\Utils.pas',
  ActiveDs_TLB in '..\LR_LIBS\AD\ActiveDs_TLB.pas',
  adshlp in '..\LR_LIBS\AD\adshlp.pas',
  CRCFunc in '..\LR_LIBS\CRCFunc.pas',
  KPAFrame in 'KPAFrame.pas' {frameKPA: TFrame},
  MyThread in 'MyThread.pas',
  DownloadMeterPO in 'DownloadMeterPO.pas' {frmDownloadMeterPO},
  DownloadSetup in 'DownloadSetup.pas' {frmDownloadSetup},
  MeterInfo in '..\LR_LIBS\MeterInfo.pas',
  LKGUtils in '..\LR_LIBS\LKG\LKGUtils.pas',
  Sense4Dev in '..\LR_LIBS\LKG\LIB_DCU\Sense4Dev.pas',
  senselock in '..\LR_LIBS\LKG\senselock.pas',
  AllNeededFunctions in '..\LR_LIBS\LKG\AllNeededFunctions.pas',
  SODEK6cryptRegDB in '..\LR_LIBS\LKG\SODEK6cryptRegDB.pas';

var
  file_idx : Integer;
  ErrStr, LocalFile : string;
  Hndl: THandle;
  init_res : TModalResult;
  files: TStringDynArray; //��� TStringDynArray �������� � System.Types
  IsUpdated : Boolean;  // ���� ����� ������������� ����������
  BDUpdateChek : string;
  BDUpdatePath : string;
  acName, cmpName, domName : string;

{$R *.res}

begin
  fmt_cfg.Create();
  fmt_cfg.DecimalSeparator := '.';
  fmt_cfg.DateSeparator := '.';
  fmt_cfg.TimeSeparator := ':';
  app_filename := ExtractFileName( Application.ExeName );
  app_folder := IncludeTrailingPathDelimiter( ExtractFilePath( Application.ExeName ) );

  init_res := mrNone;
  if not GetUserDetail( acName, cmpName, domName ) then begin
    init_res := mrCancel;
    ErrStr := Format( '������ ��� ��������� ������ ������� ������ �������� ������!%s��������� ����� ���������.', [ #13#10 ]);
    MessageDlg( ErrStr, mtError, [ mbOK ], 0, mbOK );
  end;

  cfg_file_name := Format( '%sSettings.ini', [ app_folder ] );
  cfg_file := TIniFile.Create( cfg_file_name );
  LoadParams;

  LogList := TStringList.Create;
  if UpperCase( domName ).Equals( 'TEHNOMER' ) then
    log_folder := Format( '%s%s%s', [ cfg_params.log_path, cmpName, PathDelim ] );
  if not UpperCase( domName ).Equals( 'TEHNOMER' )
    or not ForceDirectories( log_folder ) then
  begin
    log_folder := Format( '%sLogs%s', [ app_folder, PathDelim ], fmt_cfg );
    log_folder := StringReplace( log_folder, PathDelim + PathDelim, PathDelim, [ rfReplaceAll ] );
    ForceDirectories( log_folder );
  end;
  FLogFileName := log_folder + 'Log_' + DateToStr(Now) + '.log';

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'KPA-1';
  AppVersion := GetMyVersion;

  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmSetup, frmSetup);
  Application.CreateForm(TDataMod, DataMod);
  

  IsUpdated := False;  // ���� ����� ������������� ����������
   if cfg_params.search_update then begin

    if TDirectory.Exists( cfg_params.update_exe_path, False ) then begin

      // �������� ������ ���� ������ �� ���� ���������� (������ ������ ����������)
      files := TDirectory.GetFiles( cfg_params.update_exe_path, '*.*'
        , TSearchOption.soTopDirectoryOnly );

      // � ������ �� ������ ���������� ������
      for file_idx := 0 to Length( files ) - 1 do begin

        if FileExists( files[ file_idx ])
          and ( not UpperCase( ExtractFileName( files[ file_idx ])).Equals( 'SETTINGS.INI' )) then
        begin

          // ������� ������ ������ �����
          UpdateVersion := TranslateStrToVersion( GetFileVersion( files[ file_idx ]));

          LocalFile := app_folder + ExtractFileName( files[ file_idx ]);

          // ���� ��� ������ ����� � ��������� ����������
          if not FileExists( LocalFile ) then begin
            // �� ������ �������� ��� � ��������� ����������
            TFile.Copy( files[ file_idx ], LocalFile );
            IsUpdated := True;
          end
          else begin // ���� ����, ���� �������� ������ ���������� � ������ ������

            // ������� ������ ���������� �����
            AppVersion := TranslateStrToVersion( GetFileVersion( LocalFile ));

            if CheckUpdateVersion( UpdateVersion, AppVersion ) = GreaterThanValue then begin
              // ���� ��� ������ ������, ��� ������ ���������� �����

              IsUpdated := True;
              if not ExtractFileName( files[ file_idx ]).Equals( app_filename ) then
              // ���� ��� �� �������� ���� EXE, �� �������� � �����������
                {$IFDEF RELEASE}
                  TFile.Copy( files[ file_idx ], LocalFile, True );
                {$ENDIF}
            end;
          end;
        end;
      end;
    end
    else begin
      ErrStr := Format( '�������������� ���������� ��������, �� ���� � ����� ���������� ��������� %s%s%0:s �� ������������!'
        , [ #13#10, cfg_params.update_exe_path ]);
      FrmLog.SendToLog( ErrStr , logMain);
      MessageDlg( ErrStr, mtWarning, [ mbOK ], 0, mbOK );
    end;

    if IsUpdated then begin // ���� ���� ������������� ����������
      // �� �������� EXE ���� ��������� � ���������������
//      {$IFDEF RELEASE}
        if RunUpdate( app_filename, cfg_params.update_exe_path, app_folder, ErrStr ) then begin // ��������� ����������
          Application.Terminate;
        end
        else begin
          IsUpdated := False;
          ShowMessage( ErrStr );
        end;
//      {$ENDIF}
    end;

  end;
//    // ���� � ���������� �� ����� ����� "��������� ������" ,�� ���������� ���� �� ���������� ��� �� ����, �� ������ ����� ������
//    if not cfg_params.CVE1_update and FileExists(cfg_params.CVE1_update_path + app_filename) then
//      UpdateVersion := TranslateStrToVersion(GetFileVersion(cfg_params.CVE1_update_path + app_filename));
//
//      // ���� � ���������� ����� ����� "��������� ������" � ���������� ���� �� ���������� ��� �� ����
//    if cfg_params.CVE1_update and FileExists(cfg_params.CVE1_update_path + app_filename) then begin
//
//      UpdateVersion := TranslateStrToVersion(GetFileVersion(cfg_params.CVE1_update_path + app_filename));
//
//      if CheckUpdateVersion(UpdateVersion, AppVersion) = GreaterThanValue then begin
//
//        if RunUpdate (app_filename,cfg_params.CVE1_update_path, app_folder, ErrStr) then // ��������� ����������
//        begin
//          // ��� ���� ������� ��������� �� ������ ErrStr
//          // � ��������� ������
//          Application.Terminate;
//        end
//        else begin
//          ShellExecute(Hndl, 'open', PWideChar(app_folder + app_filename), nil, nil, SW_SHOWNORMAL) ;
//          Application.Terminate;
//        end;
//      end;
//    end;
//  if not Application.Terminated and not IsUpdated then begin
//
    Application.CreateForm(TfrmDownloadMeterPO, frmDownloadMeterPO);
    Application.CreateForm(TfrmDownloadSetup, frmDownloadSetup);
//




    if not DataMod.IBDatabase1.Connected then begin
      init_res := 0;
      Application.ProcessMessages;

      if InterbaseDatabaseExists(cfg_params.connection_db, DB_USER, DB_PASSWORD)<>'OK' then begin

        MessageDlg('�� ���������� ���� ������ ��� ����������� ������ � ���, ������� �������������� ��� ����� � ������ ���� ������!',mtError, [mbOK], 0, mbOK);
        init_res := frmSetup.ShowModal;
        if init_res = mrCancel then begin
          MessageDlg('����������� ������ ��� ����������� � ���� ������ �� ��������, ������ ���������� ����� ���������!',mtError, [mbOK], 0, mbOK);
          Application.Terminate;
        end;
      end;

      if not (init_res = mrCancel) then begin
        DataMod.IBDatabase1.DatabaseName := cfg_params.connection_db;   // ������ ���������� � �� ����� �� ����������
        DataMod.IBDatabase1.Open;                      // ��������� ��
      end;

      if not datamod.GetCVE2Settings( ErrStr ) then     //�������� �������������� ���������
        MessageDlg( '��� ������ �������� ��������� �� �� ��������� ������: ' + ErrStr, mtError, [mbOK], 0, mbOK);
    end;


//    if not ErrStr.IsEmpty then begin
//      ShowMessage('������ ��� ��������� ������ �������� ������������: ' + ErrStr + #13#10 + '��������� ����� ���������.');
//      Application.Terminate;
//    end;
//    if not Application.Terminated then begin   // ���� ���������� �� ������������� �����
//      // ���� �� ������ ID ������������ � ����
//      if dataMod.IBTransaction1.Active = false then dataMod.IBTransaction1.StartTransaction;
//  //     username:= cfg_params.current_AD_user.Get('sAMAccountName');
//      cfg_params.user_ID := GetQueryAloneValue(datamod.IBDatabase1,'Select ID from SECUSER where STANDID = :pStandID and SAMACCOUNTNAME = :psAMAccountName ',
//                                                                  [cfg_params.stand_id, acName],0);
//      if cfg_params.user_ID  = 0 then begin
//        dataMod.IBTransaction1.Rollback;
//        ShowMessage('������� ������������ �� ��������� � �� � �� ����������� ��� ����������.');
//
//        Application.Terminate;
//      end
//      else begin // ���� ������
//        // �������� ��� ����
//        cfg_params.access := GetQueryAloneValue(datamod.IBDatabase1,'Select ENABLED from SECUSER where ID = :pID', [cfg_params.user_ID], 0);
//        if cfg_params.access = 0 then begin
//          dataMod.IBTransaction1.Rollback;
//          ShowMessage('������� ������������ �� ����� ������ � ���������!');
//        end
//        else begin
//          cfg_params.user_role := GetQueryAloneValue(datamod.IBDatabase1,'Select ROLE from SECUSER where STANDID = :pStandID and SAMACCOUNTNAME = :psAMAccountName ',
//                                                                  [cfg_params.stand_id, acName],0);
//          cfg_params.user_role_name := GetQueryAloneValue(datamod.IBDatabase1,'Select ROLENAME from USERROLESDICT where ID = :pID', [cfg_params.user_role], 0);
//    //      frmMain.Caption := Application.Title + ' - ' + cfg_params.current_AD_user.FullName + ' - ' + cfg_params.user_role_name;
//
//          dataMod.IBTransaction1.Commit;
//        end;
//      end;
//    end;
    //    �������� � ������ �����������
    Application.CreateForm(TfrmAutor, frmAutor);
//    frmAutor := TfrmAutor.Create(Application);
    if frmAutor.ShowModal <> mrOk then begin
      init_res := mrCancel;
    end;
    frmAutor.Destroy;
   if init_res <> mrCancel then Application.Run;
   if init_res = mrCancel then Application.Terminate;
end.
