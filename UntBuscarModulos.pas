unit UntBuscarModulos;

interface

uses
  System.Classes, Uni, SysUtils, Forms, DB, UniProvider, MySQLUniProvider,PostgreSQLUniProvider,MidasLib,
  Dialogs, Grids, DBGrids, DBClient;

type
  TBuscarModulosThread = class(TThread)
  private
    FID_Empresa: string;
    FDataSource: TUniDataSource;
    FDBGrid: TDBGrid;
    procedure AtualizarUI;
  protected
    procedure Execute; override;
  public
    constructor Create(const ID_Empresa: string; DataSource: TUniDataSource; DBGrid: TDBGrid);
    destructor Destroy; override;
  end;

implementation

uses
  UntPrincipal;

constructor TBuscarModulosThread.Create(const ID_Empresa: string; DataSource: TUniDataSource; DBGrid: TDBGrid);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FID_Empresa := ID_Empresa;
  FDataSource := DataSource;
  FDBGrid := DBGrid;
end;

destructor TBuscarModulosThread.Destroy;
begin
  inherited;
end;

procedure TBuscarModulosThread.Execute;
var
  ConexaoServer: TUniConnection;
  Query: TUniQuery;
  ClientDataSet: TClientDataSet;
begin
 // ConexaoServer := TUniConnection.Create(nil);
  Query := TUniQuery.Create(nil);
  ClientDataSet := TClientDataSet.Create(nil);
  try
    try
      // Configuração da conexão
      FrmPrincipal.ConexaoModulo.ProviderName := 'PostgreSQL';
      FrmPrincipal.ConexaoModulo.Server := FrmPrincipal.IP_DB_cliente.Text;
      FrmPrincipal.ConexaoModulo.Database := FrmPrincipal.Nome_DB_cliente.Text;
      FrmPrincipal.ConexaoModulo.Username := FrmPrincipal.Usuario_DB_cliente.Text;
      FrmPrincipal.ConexaoModulo.Password := FrmPrincipal.Senha_DB_cliente.Text;
      FrmPrincipal.ConexaoModulo.Port := StrToIntDef(FrmPrincipal.Porta_DB_cliente.Text, 8001);


      FrmPrincipal.ConexaoModulo.SpecificOptions.Values['UseUnicode'] := 'True';
      FrmPrincipal.ConexaoModulo.LoginPrompt := False;
      FrmPrincipal.ConexaoModulo.Connected := True;

      if not FrmPrincipal.ConexaoModulo.Connected then
        raise Exception.Create('Erro ao conectar no banco de dados!');

      // Consulta SQL para trazer todos os módulos, marcando como "Sim" ou "Não" os módulos ativos
      Query.Connection := FrmPrincipal.ConexaoModulo;
      Query.SQL.Text :=
        'SELECT ' +
        '   CASE WHEN c.id_empresa_Help = :id THEN ''Sim'' ELSE ''Não'' END AS Ativos, ' +
        '  m.nome_modulo ' +
        'FROM cadastro_modulos m ' +

        'LEFT JOIN controle_sistema c ON c.id_modulo = m.id_modulo AND c.id_empresa_Help = :id ' +
        'where c.id_empresa_help = :id '+
        'ORDER BY m.nome_modulo';
      Query.ParamByName('id').AsString := FID_Empresa;
      Query.Open;

      // Prepara o ClientDataSet para armazenar os dados
      ClientDataSet.FieldDefs.Add('Ativos', ftString, 6);  // Tamanho suficiente para "Sim" ou "Não"
      ClientDataSet.FieldDefs.Add('nome_modulo', ftString, 60);
      ClientDataSet.CreateDataSet;

      // Adiciona os registros ao ClientDataSet
      while not Query.Eof do
      begin
        ClientDataSet.Append;
        ClientDataSet.FieldByName('Ativos').AsString := Query.FieldByName('Ativos').AsString;
        ClientDataSet.FieldByName('nome_modulo').AsString := Query.FieldByName('nome_modulo').AsString;
        ClientDataSet.Post;
        Query.Next;
      end;

      // Vincula o DataSource ao ClientDataSet
      FDataSource.DataSet := ClientDataSet;

      // Vincula o DBGrid ao DataSource
      Synchronize(AtualizarUI);  // Atualiza a interface de usuário com os dados no DBGrid
    except
      on E: Exception do
//        ShowMessage('Erro ao buscar módulos: ' + E.Message);

    FrmPrincipal.WriteLogFormatted('ERRO DE CONEXÃO', '1', 'Conexão Puxar os bancos disponiveis1: ' + E.Message);
    end;
  finally
    Query.Free;
    FrmPrincipal.ConexaoModulo.Free;
  end;
end;

procedure TBuscarModulosThread.AtualizarUI;
begin
  // Atualiza a interface do usuário com os dados no DBGrid
  FDBGrid.DataSource := FDataSource;
  FDBGrid.Refresh;  // Força o refresh do DBGrid para exibir os dados
end;

end.

