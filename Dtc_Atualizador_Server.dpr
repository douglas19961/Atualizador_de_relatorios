program Dtc_Atualizador_Server;

uses
 Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  UntPrincipal in 'UntPrincipal.pas' {FrmPrincipal},
  uTransferenciaThread in 'uTransferenciaThread.pas',
  uTransferenciaServerThread in 'uTransferenciaServerThread.pas',
  UntConexaoCliente in 'UntConexaoCliente.pas',
  UntBuscarBanco in 'UntBuscarBanco.pas',
  UntBuscarModulos in 'UntBuscarModulos.pas',
  UntSalvarConfig in 'UntSalvarConfig.pas',
  UntSalvarServerConfig in 'UntSalvarServerConfig.pas',
  UntInserirModulos in 'UntInserirModulos.pas',
  uThreadCarregarConfig in 'uThreadCarregarConfig.pas',
  UntInserirModulosClient in 'UntInserirModulosClient.pas',
  uThreadCarregarConfigClient in 'uThreadCarregarConfigClient.pas',
  uThreadmonitorDeOcorrencia in 'uThreadmonitorDeOcorrencia.pas',
  UntLogs in 'UntLogs.pas' {FrmLogs},
  uThreadmonitorDeOcorrenciaSERVER in 'uThreadmonitorDeOcorrenciaSERVER.pas';

{$R *.res}

var
  hMutex: THandle;

begin
  // Verifica se j� existe uma inst�ncia do programa em execu��o
  hMutex := CreateMutex(nil, True, 'Global\dtc_atualizador_server_SingleInstance');
  if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    if hMutex <> 0 then
      CloseHandle(hMutex);
      exit
  end;

  try
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmLogs, FrmLogs);
  Application.Run;
    finally
    if hMutex <> 0 then
      CloseHandle(hMutex);
  end;
end.
