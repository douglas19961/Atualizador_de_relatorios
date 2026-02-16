unit uTransferenciaServerThread;

interface

uses
  System.Classes, Data.DB, Uni, FireDAC.Comp.Client, System.SysUtils, UntPrincipal,Vcl.StdCtrls;

type
  TConnectionParams = record
    ProviderName, Server, Database, Username, Password: string;
    Port: Integer;
  end;

  TTransferenciaServerThread = class(TThread)
  private
    FConexaoOrigem: TUniConnection;
    FConexaoDestino: TUniConnection;
    FMemoLog: TMemo; // Para registrar logs (Opcional)
    FParamsOrigem: TConnectionParams;
    FParamsDestino: TConnectionParams;
    procedure Log(const Msg: string);
    procedure ObterParametrosConexao; // Executado na thread principal via Synchronize
  protected
    procedure Execute; override;
  public
    constructor Create(AConexaoOrigem, AConexaoDestino: TUniConnection; AMemoLog: TMemo);
  end;

implementation

constructor TTransferenciaServerThread.Create(AConexaoOrigem, AConexaoDestino: TUniConnection; AMemoLog: TMemo);
begin
  inherited Create(False); // Criar e iniciar imediatamente
  FreeOnTerminate := True; // Liberar a thread automaticamente ao terminar
  FConexaoOrigem := AConexaoOrigem;
  FConexaoDestino := AConexaoDestino;
  FMemoLog := AMemoLog;
end;

procedure TTransferenciaServerThread.Log(const Msg: string);
begin
  if Assigned(FMemoLog) then
  begin
    TThread.Synchronize(nil,
      procedure
      begin
        FMemoLog.Lines.Add(Msg);
      end);
  end;
  // Também escreve no log formatado
  FrmPrincipal.WriteLogFormatted('INFO', '122', Msg);
end;

procedure TTransferenciaServerThread.ObterParametrosConexao;
begin
  if Assigned(FConexaoOrigem) then
  begin
    FParamsOrigem.ProviderName := FConexaoOrigem.ProviderName;
    FParamsOrigem.Server := FConexaoOrigem.Server;
    FParamsOrigem.Database := FConexaoOrigem.Database;
    FParamsOrigem.Username := FConexaoOrigem.Username;
    FParamsOrigem.Password := FConexaoOrigem.Password;
    FParamsOrigem.Port := FConexaoOrigem.Port;
  end;
  if Assigned(FConexaoDestino) then
  begin
    FParamsDestino.ProviderName := FConexaoDestino.ProviderName;
    FParamsDestino.Server := FConexaoDestino.Server;
    FParamsDestino.Database := FConexaoDestino.Database;
    FParamsDestino.Username := FConexaoDestino.Username;
    FParamsDestino.Password := FConexaoDestino.Password;
    FParamsDestino.Port := FConexaoDestino.Port;
  end;
end;

procedure TTransferenciaServerThread.Execute;
var
  QueryOrigem, QueryDestino, QueryVerifica: TUniQuery;
  ConexaoOrigemLocal, ConexaoDestinoLocal: TUniConnection;
  RecordCount, MaxCodRelatorio: Integer;
  NeedsUpdate: Boolean;
begin
  FrmPrincipal.WriteLogFormatted('INFO', '122', 'Iniciando transferência de relatórios do servidor');

  TThread.Synchronize(nil, ObterParametrosConexao);

  ConexaoOrigemLocal := TUniConnection.Create(nil);
  ConexaoDestinoLocal := TUniConnection.Create(nil);
  QueryOrigem := TUniQuery.Create(nil);
  QueryDestino := TUniQuery.Create(nil);
  QueryVerifica := TUniQuery.Create(nil);

  try
      // Configurar conex�es
    ConexaoOrigemLocal.ProviderName := FParamsOrigem.ProviderName;
    ConexaoOrigemLocal.Server := FParamsOrigem.Server;
    ConexaoOrigemLocal.Database := FParamsOrigem.Database;
    ConexaoOrigemLocal.Username := FParamsOrigem.Username;
    ConexaoOrigemLocal.Password := FParamsOrigem.Password;
    ConexaoOrigemLocal.Port := FParamsOrigem.Port;
    ConexaoOrigemLocal.LoginPrompt := False;

    ConexaoDestinoLocal.ProviderName := FParamsDestino.ProviderName;
    ConexaoDestinoLocal.Server := FParamsDestino.Server;
    ConexaoDestinoLocal.Database := FParamsDestino.Database;
    ConexaoDestinoLocal.Username := FParamsDestino.Username;
    ConexaoDestinoLocal.Password := FParamsDestino.Password;
    ConexaoDestinoLocal.Port := FParamsDestino.Port;
    ConexaoDestinoLocal.LoginPrompt := False;

    ConexaoOrigemLocal.Connected := True;
    ConexaoDestinoLocal.Connected := True;

    QueryOrigem.Connection := ConexaoOrigemLocal;
    QueryDestino.Connection := ConexaoDestinoLocal;
    QueryVerifica.Connection := ConexaoDestinoLocal;

    try
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Conexões configuradas para transferência de relatórios');

      // Preparar query de sele��o na origem
      QueryOrigem.SQL.Text :=
        'SELECT cod_relatorio, categoria, subcategoria, descricao, relatorio, ' +
        '       exibir, nome, uso_interno, relatorio_pai, relatorio_sistema, ' +
        '       data_inclusao, data_alteracao ' +
        'FROM relatorios where cod_relatorio >= ''450'' ';
      QueryOrigem.Open;
      
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', Format('Consulta executada. Registros encontrados: %d', [QueryOrigem.RecordCount]));

      // Contador de registros
      RecordCount := 0;

      // Iniciar transa��o
      QueryDestino.Connection.StartTransaction;
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Transação iniciada para transferência de relatórios');


      // Iterar sobre os registros e inserir ou atualizar
      while not QueryOrigem.Eof do
      begin
        // Verificar se o relat�rio j� existe no destino
        QueryVerifica.Close;
        QueryVerifica.SQL.Text :=
          'SELECT * FROM relatorios WHERE cod_relatorio = :cod_relatorio';
        QueryVerifica.ParamByName('cod_relatorio').AsInteger :=
          QueryOrigem.FieldByName('cod_relatorio').AsInteger;
        QueryVerifica.Open;

        if QueryVerifica.IsEmpty then
        begin
          // Preparar query de inser��o no destino
          QueryDestino.SQL.Text :=
            'INSERT INTO relatorios (' +
            '  cod_relatorio, categoria, subcategoria, descricao, relatorio, ' +
            '  exibir, nome, uso_interno, relatorio_pai, relatorio_sistema, ' +
            '  data_inclusao, data_alteracao ' +
            ') VALUES (' +
            '  :cod_relatorio, :categoria, :subcategoria, :descricao, :relatorio, ' +
            '  :exibir, :nome, :uso_interno, :relatorio_pai, :relatorio_sistema, ' +
            '  :data_inclusao, :data_alteracao ' +
            ')';

          // Inserir novos registros
          QueryDestino.ParamByName('cod_relatorio').AsInteger := QueryOrigem.FieldByName('cod_relatorio').AsInteger;
          QueryDestino.ParamByName('categoria').AsString := QueryOrigem.FieldByName('categoria').AsString;
          QueryDestino.ParamByName('subcategoria').AsString := QueryOrigem.FieldByName('subcategoria').AsString;
          QueryDestino.ParamByName('descricao').AsString := QueryOrigem.FieldByName('descricao').AsString;
          QueryDestino.ParamByName('relatorio').AsString := QueryOrigem.FieldByName('relatorio').AsString;
          QueryDestino.ParamByName('exibir').AsInteger := QueryOrigem.FieldByName('exibir').AsInteger;
          QueryDestino.ParamByName('nome').AsString := QueryOrigem.FieldByName('nome').AsString;
          QueryDestino.ParamByName('uso_interno').AsBoolean := QueryOrigem.FieldByName('uso_interno').AsBoolean;

          // Tratar campos que podem ser nulos
          if QueryOrigem.FieldByName('relatorio_pai').IsNull then
            QueryDestino.ParamByName('relatorio_pai').Clear
          else
            QueryDestino.ParamByName('relatorio_pai').AsInteger :=  QueryOrigem.FieldByName('relatorio_pai').AsInteger;
          QueryDestino.ParamByName('relatorio_sistema').AsBoolean := QueryOrigem.FieldByName('relatorio_sistema').AsBoolean;
          QueryDestino.ParamByName('data_inclusao').AsDateTime := QueryOrigem.FieldByName('data_inclusao').AsDateTime;

          if QueryOrigem.FieldByName('data_alteracao').IsNull then
            QueryDestino.ParamByName('data_alteracao').Clear
          else
            QueryDestino.ParamByName('data_alteracao').AsDateTime := QueryOrigem.FieldByName('data_alteracao').AsDateTime;


          // Executar inser��o
          QueryDestino.ExecSQL;

          Log('Inserido: ' + QueryOrigem.FieldByName('cod_relatorio').AsString);
          Inc(RecordCount);
        end
        else
        begin
          // Verificar se h� necessidade de atualiza��o
          NeedsUpdate := False;

          // Compara��es de cada campo
          if (QueryVerifica.FieldByName('descricao').AsString <> QueryOrigem.FieldByName('descricao').AsString) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('relatorio').AsString <> QueryOrigem.FieldByName('relatorio').AsString) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('categoria').AsString <> QueryOrigem.FieldByName('categoria').AsString) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('subcategoria').AsString <> QueryOrigem.FieldByName('subcategoria').AsString) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('exibir').AsInteger <> QueryOrigem.FieldByName('exibir').AsInteger) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('nome').AsString <> QueryOrigem.FieldByName('nome').AsString) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('uso_interno').AsBoolean <> QueryOrigem.FieldByName('uso_interno').AsBoolean) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('relatorio_pai').AsInteger <> QueryOrigem.FieldByName('relatorio_pai').AsInteger) then
            NeedsUpdate := True;

          if (QueryVerifica.FieldByName('relatorio_sistema').AsBoolean <> QueryOrigem.FieldByName('relatorio_sistema').AsBoolean) then
            NeedsUpdate := True;

          // Formatar as datas antes da compara��o
          var DataInclusaoOrigem := FormatDateTime('yyyy-mm-dd hh:nn:ss', QueryOrigem.FieldByName('data_inclusao').AsDateTime);
          var DataInclusaoDestino := FormatDateTime('yyyy-mm-dd hh:nn:ss', QueryVerifica.FieldByName('data_inclusao').AsDateTime);

          if DataInclusaoOrigem <> DataInclusaoDestino then
            NeedsUpdate := True;

          var DataAlteracaoOrigem := FormatDateTime('yyyy-mm-dd hh:nn:ss', QueryOrigem.FieldByName('data_alteracao').AsDateTime);
          var DataAlteracaoDestino := FormatDateTime('yyyy-mm-dd hh:nn:ss', QueryVerifica.FieldByName('data_alteracao').AsDateTime);

          if DataAlteracaoOrigem <> DataAlteracaoDestino then
            NeedsUpdate := True;


          // Se houver altera��es, executar a atualiza��o
          if NeedsUpdate then
          begin
            QueryDestino.SQL.Text :=
              'UPDATE relatorios SET ' +
              '  categoria = :categoria, ' +
              '  subcategoria = :subcategoria, ' +
              '  descricao = :descricao, ' +
              '  relatorio = :relatorio, ' +
              '  exibir = :exibir, ' +
              '  nome = :nome, ' +
              '  uso_interno = :uso_interno, ' +
              '  relatorio_pai = :relatorio_pai, ' +
              '  relatorio_sistema = :relatorio_sistema, ' +
              '  data_inclusao = :data_inclusao, ' +
              '  data_alteracao = :data_alteracao ' +

              'WHERE cod_relatorio = :cod_relatorio';

            // Atribuir valores para a consulta de atualiza��o
            QueryDestino.ParamByName('cod_relatorio').AsInteger := QueryOrigem.FieldByName('cod_relatorio').AsInteger;
            QueryDestino.ParamByName('categoria').AsString := QueryOrigem.FieldByName('categoria').AsString;
            QueryDestino.ParamByName('subcategoria').AsString := QueryOrigem.FieldByName('subcategoria').AsString;
            QueryDestino.ParamByName('descricao').AsString := QueryOrigem.FieldByName('descricao').AsString;
            QueryDestino.ParamByName('relatorio').AsString := QueryOrigem.FieldByName('relatorio').AsString;
            QueryDestino.ParamByName('exibir').AsInteger := QueryOrigem.FieldByName('exibir').AsInteger;
            QueryDestino.ParamByName('nome').AsString := QueryOrigem.FieldByName('nome').AsString;
            QueryDestino.ParamByName('uso_interno').AsBoolean := QueryOrigem.FieldByName('uso_interno').AsBoolean;

            // Tratar campos que podem ser nulos
            if QueryOrigem.FieldByName('relatorio_pai').IsNull then
              QueryDestino.ParamByName('relatorio_pai').Clear
            else
              QueryDestino.ParamByName('relatorio_pai').AsInteger := QueryOrigem.FieldByName('relatorio_pai').AsInteger;

            QueryDestino.ParamByName('relatorio_sistema').AsBoolean := QueryOrigem.FieldByName('relatorio_sistema').AsBoolean;

            QueryDestino.ParamByName('data_inclusao').AsDateTime := QueryOrigem.FieldByName('data_inclusao').AsDateTime;

            if QueryOrigem.FieldByName('data_alteracao').IsNull then
              QueryDestino.ParamByName('data_alteracao').Clear
            else
              QueryDestino.ParamByName('data_alteracao').AsDateTime := QueryOrigem.FieldByName('data_alteracao').AsDateTime;


            // Executar atualiza��o
            QueryDestino.ExecSQL;

            Log('Atualizado: ' + QueryOrigem.FieldByName('cod_relatorio').AsString);
            Inc(RecordCount);
          end;
        end;

        // Avan�ar para o pr�ximo registro
        if QueryOrigem.FieldByName('cod_relatorio').AsInteger > MaxCodRelatorio then
          MaxCodRelatorio := QueryOrigem.FieldByName('cod_relatorio').AsInteger;
        QueryOrigem.Next;
      end;

      // Verificar e remover relatórios que não existem mais na origem (>= 450)
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Verificando relatórios para exclusão no destino');
      
      
        if MaxCodRelatorio > 0 then      
      
      begin
        // Apaga os registros da tabela de destino com cod_relatorio maior que o m�ximo da origem
        QueryDestino.Close;
        QueryDestino.SQL.Text := 'DELETE FROM relatorios WHERE cod_relatorio > :MaxCod';
        QueryDestino.ParamByName('MaxCod').AsInteger := MaxCodRelatorio;
        QueryDestino.ExecSQL;
        
        FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Registros antigos removidos com sucesso');
      end;
      
      // Nova lógica: Remover relatórios que não existem mais na origem (>= 450)
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Verificando relatórios excluídos da origem');
      
      // Primeiro: buscar todos os códigos que existem na origem (>= 450)
      QueryOrigem.Close;
      QueryOrigem.SQL.Text := 'SELECT cod_relatorio FROM relatorios WHERE cod_relatorio >= 450 ORDER BY cod_relatorio';
      QueryOrigem.Open;
      
      // Criar string com códigos da origem separados por vírgula
      var CodigosOrigem: string := '';
      while not QueryOrigem.Eof do
      begin
        if CodigosOrigem <> '' then
          CodigosOrigem := CodigosOrigem + ',';
        CodigosOrigem := CodigosOrigem + QueryOrigem.FieldByName('cod_relatorio').AsString;
        QueryOrigem.Next;
      end;
      
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', Format('Códigos encontrados na origem: %s', [CodigosOrigem]));
      
      // Segundo: verificar quais relatórios serão excluídos antes de remover
      QueryDestino.Close;
      QueryDestino.SQL.Text := 'SELECT cod_relatorio FROM relatorios WHERE cod_relatorio >= 450';
      QueryDestino.Open;
      
      var CodigosParaExcluir: string := '';
      while not QueryDestino.Eof do
      begin
        var CodigoAtual: string := QueryDestino.FieldByName('cod_relatorio').AsString;
        
        // Verificar se este código não está na origem
        if (CodigosOrigem = '') or (Pos(',' + CodigoAtual + ',', ',' + CodigosOrigem + ',') = 0) then
        begin
          if CodigosParaExcluir <> '' then
            CodigosParaExcluir := CodigosParaExcluir + ',';
          CodigosParaExcluir := CodigosParaExcluir + CodigoAtual;
        end;
        
        QueryDestino.Next;
      end;
      
      // Log dos códigos que serão excluídos
      if CodigosParaExcluir <> '' then
      begin
        FrmPrincipal.WriteLogFormatted('INFO', '122', Format('EXCLUSÃO: Relatórios que serão removidos do destino: %s', [CodigosParaExcluir]));
        
        // Executar a exclusão
        QueryDestino.Close;
        QueryDestino.SQL.Text := 
          'DELETE FROM relatorios WHERE cod_relatorio >= 450 AND cod_relatorio NOT IN (' + CodigosOrigem + ')';
        QueryDestino.ExecSQL;
        
        FrmPrincipal.WriteLogFormatted('INFO', '122', Format('EXCLUSÃO CONCLUÍDA: %d relatórios removidos com sucesso', [QueryDestino.RowsAffected]));
      end
      else
      begin
        FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Nenhum relatório precisa ser excluído - destino já está sincronizado');
      end;


      // Confirmar transa��o
      QueryDestino.Connection.Commit;
      FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Transação confirmada com sucesso');

      // Log de conclus�o
      Log('Transfer�ncia conclu�da com sucesso!');
      Log('Total de registros transferidos: ' + IntToStr(RecordCount));

    except
      on E: Exception do
      begin
        // Reverter transa��o em caso de erro
        if QueryDestino.Connection.InTransaction then
        begin
          QueryDestino.Connection.Rollback;
          FrmPrincipal.WriteLogFormatted('DEBUG', '122', 'Transação revertida devido a erro');
        end;

        // Log de erro
        FrmPrincipal.WriteLogFormatted('ERRO', '122', Format('Erro na transferência de relatórios: %s', [E.Message]));
        Log('Erro na transfer�nciaServer: ' + E.Message);
      end;
    end;
  finally
    QueryOrigem.Free;
    QueryDestino.Free;
    QueryVerifica.Free;
    if Assigned(ConexaoOrigemLocal) then
    begin
      if ConexaoOrigemLocal.Connected then
        ConexaoOrigemLocal.Connected := False;
      ConexaoOrigemLocal.Free;
    end;
    if Assigned(ConexaoDestinoLocal) then
    begin
      if ConexaoDestinoLocal.Connected then
        ConexaoDestinoLocal.Connected := False;
      ConexaoDestinoLocal.Free;
    end;
  end;

  FrmPrincipal.WriteLogFormatted('INFO', '122', 'Transferência de relatórios do servidor finalizada');
end;

end.


