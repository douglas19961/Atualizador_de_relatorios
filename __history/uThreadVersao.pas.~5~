unit uThreadVersao;

interface

uses
  System.Classes, Uni, SysUtils, Forms, Winapi.Windows, Vcl.StdCtrls;

type
  ThreadVersao = class(TThread)
  private
    FCxClient: TUniConnection;
    FConexaoModulo: TUniConnection;
    FMemo: TMemo;
    FIEmpresa: string;
    FLogMessage: string;
    procedure ExecutarConsulta;
    procedure ExecutarConsultaValidade;
    procedure AtualizarMemo;
  protected
    procedure Execute; override;
  public
    constructor Create(ACxClient, AConexaoModulo: TUniConnection; AMemo: TMemo; AEdtEmpresa: TEdit);
  end;

implementation

{ ThreadVersao }

constructor ThreadVersao.Create(ACxClient, AConexaoModulo: TUniConnection; AMemo: TMemo; AEdtEmpresa: TEdit);
begin
  inherited Create(False); // Inicia automaticamente
  FreeOnTerminate := True;
  FCxClient := ACxClient;
  FConexaoModulo := AConexaoModulo;
  FMemo := AMemo;

  // Captura o texto do Edit para a variável FIEmpresa
  if Assigned(AEdtEmpresa) then
    FIEmpresa := Trim(AEdtEmpresa.Text) // Remove espaços extras
  else
    FIEmpresa := ''; // Se o Edit não for passado, assume vazio
end;

procedure ThreadVersao.Execute;
begin
  try
    ExecutarConsulta;
    ExecutarConsultaValidade;
  except
    on E: Exception do
    begin
      FLogMessage := 'Erro na ThreadVersao: ' + E.Message;
      Synchronize(AtualizarMemo);
    end;
  end;
end;

procedure ThreadVersao.ExecutarConsulta;
var
  extractedValue: string;
  QryPostgres, QryMySQL: TUniQuery;
  EmpresaExiste: Boolean;
begin
  extractedValue := '';

  // Garantir que a conexão com PostgreSQL está ativa
  if not FCxClient.Connected then
    FCxClient.Connect;

  // Criar query para PostgreSQL
  QryPostgres := TUniQuery.Create(nil);
  try
    QryPostgres.Connection := FCxClient;
    QryPostgres.SQL.Text :=
      'SELECT regexp_replace(application_id, ''^.*\((.*?)\).*$'', ''\1'') AS extracted_value ' +
      'FROM _db_updates ' +
      'WHERE schema_name = ''public'' ' +
      'ORDER BY date_time DESC ' +
      'LIMIT 1';
    QryPostgres.Open;

    if not QryPostgres.IsEmpty then
      extractedValue := QryPostgres.FieldByName('extracted_value').AsString;
  finally
    QryPostgres.Free;
  end;

  if extractedValue = '' then
  begin
    FLogMessage := 'Nenhuma versão encontrada no PostgreSQL.';
    Synchronize(AtualizarMemo);
    Exit;
  end;

  // Garantir que a conexão com MySQL está ativa
  if not FConexaoModulo.Connected then
    FConexaoModulo.Connect;

  // Verificar se a empresa já existe na tabela Versao_Sistema
  EmpresaExiste := False;
  QryMySQL := TUniQuery.Create(nil);
  try
    QryMySQL.Connection := FConexaoModulo;
    QryMySQL.SQL.Text := 'SELECT COUNT(*) AS Existe FROM versao_sistema WHERE id_empresa_help = :Empresa';
    QryMySQL.ParamByName('Empresa').AsString := FIEmpresa;
    QryMySQL.Open;

    EmpresaExiste := QryMySQL.FieldByName('Existe').AsInteger > 0;
  finally
    QryMySQL.Free;
  end;

  // Se a empresa já existir, atualizar a versão. Senão, inserir um novo registro.
  QryMySQL := TUniQuery.Create(nil);
  try
    QryMySQL.Connection := FConexaoModulo;

    if EmpresaExiste then
    begin
      QryMySQL.SQL.Text := 'UPDATE versao_sistema SET Versao = :Value WHERE id_empresa_help = :id_empresa_help';
      FLogMessage := 'Versão atualizada para "' + extractedValue + '" na empresa: ' + FIEmpresa;
    end
    else
    begin
      QryMySQL.SQL.Text := 'INSERT INTO versao_sistema (Versao, id_empresa_help) VALUES (:Value, :id_empresa_help)';
      FLogMessage := 'Versão "' + extractedValue + '" inserida no MySQL para Empresa: ' + FIEmpresa;
    end;

    QryMySQL.ParamByName('Value').AsString := extractedValue;
    QryMySQL.ParamByName('id_empresa_help').AsString := FIEmpresa;
    QryMySQL.ExecSQL;
  finally
    QryMySQL.Free;
  end;

  Synchronize(AtualizarMemo);
end;

procedure ThreadVersao.ExecutarConsultaValidade;
var
  extractedValue: string;
  QryPostgres, QryMySQL: TUniQuery;
  EmpresaExiste: Boolean;
begin
  extractedValue := '';

  // Garantir que a conexão com PostgreSQL está ativa
  if not FCxClient.Connected then
    FCxClient.Connect;

  // Criar query para PostgreSQL
  QryPostgres := TUniQuery.Create(nil);
  try
    QryPostgres.Connection := FCxClient;
    QryPostgres.SQL.Text :=
    'SELECT a.data_vencimento AS validade ' +
    'FROM autorizacoes a ' +
    'INNER JOIN pessoas p ON a.cod_pessoa = p.cod_pessoa ' +
    'WHERE p.reg_desativado IS FALSE ' +
    'AND a.data_vencimento IS NOT NULL ' +
    'ORDER BY a.data_vencimento DESC ' +
    'LIMIT 1;';


    QryPostgres.Open;

    if not QryPostgres.IsEmpty then
      extractedValue := QryPostgres.FieldByName('validade').AsString;
  finally
    QryPostgres.Free;
  end;

  if extractedValue = '' then
  begin
    FLogMessage := 'Nenhuma validade encontrada no PostgreSQL.';
    Synchronize(AtualizarMemo);
    Exit;
  end;

  // Garantir que a conexão com MySQL está ativa
  if not FConexaoModulo.Connected then
    FConexaoModulo.Connect;

  // Verificar se a empresa já existe na tabela Versao_Sistema
  EmpresaExiste := False;
  QryMySQL := TUniQuery.Create(nil);
  try
    QryMySQL.Connection := FConexaoModulo;
    QryMySQL.SQL.Text := 'SELECT COUNT(*) AS Existe FROM versao_sistema WHERE id_empresa_help = :Empresa';
    QryMySQL.ParamByName('Empresa').AsString := FIEmpresa;
    QryMySQL.Open;

    EmpresaExiste := QryMySQL.FieldByName('Existe').AsInteger > 0;
  finally
    QryMySQL.Free;
  end;

  // Se a empresa já existir, atualizar a validade. Senão, inserir um novo registro.
  QryMySQL := TUniQuery.Create(nil);
  try
    QryMySQL.Connection := FConexaoModulo;

    if EmpresaExiste then
    begin
      QryMySQL.SQL.Text := 'UPDATE versao_sistema SET vencimentos = :Value WHERE id_empresa_help = :id_empresa_help';
      FLogMessage := 'validade atualizada para "' + extractedValue + '" na empresa: ' + FIEmpresa;
    end
    else
    begin
      QryMySQL.SQL.Text := 'INSERT INTO versao_sistema (vencimentos, id_empresa_help) VALUES (:Value, :id_empresa_help)';
      FLogMessage := 'validade "' + extractedValue + '" inserida no MySQL para Empresa: ' + FIEmpresa;
    end;

    QryMySQL.ParamByName('Value').AsString := extractedValue;
    QryMySQL.ParamByName('id_empresa_help').AsString := FIEmpresa;
    QryMySQL.ExecSQL;
  finally
    QryMySQL.Free;
  end;

  Synchronize(AtualizarMemo);
end;



procedure ThreadVersao.AtualizarMemo;
begin
  if Assigned(FMemo) then
    FMemo.Lines.Add(FLogMessage);
end;

end.

