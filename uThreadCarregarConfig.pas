unit uThreadCarregarConfig;

interface

uses
  System.Classes, Uni, DB, SysUtils, Dialogs, Forms, StdCtrls, JvEdit;

type
  TThreadCarregarConfig = class(TThread)
  private
    FConexao: TUniConnection;
    FFormDestino: TForm;
    FEditNomeDBServerCliente, FEditIPDBServerCliente, FEditUsuarioDBServerCliente,
    FEditPortaDBServerCliente, FEditSenhaDBServerCliente: TJvEdit;

    FEditNomeDBServer, FEditIPDBServer, FEditUsuarioDBServer,
    FEditPortaDBServer, FEditSenhaDBServer: TJvEdit;

    FComboBoxIDServer: TComboBox;

    FQuery: TUniQuery;
  protected
    procedure Execute; override;
    procedure AtualizarComponentes;
  public
    constructor Create(AConexao: TUniConnection; AFormDestino: TForm;
      AEditNomeDBServerCliente, AEditIPDBServerCliente, AEditUsuarioDBServerCliente,
      AEditPortaDBServerCliente, AEditSenhaDBServerCliente: TJvEdit;
      AEditNomeDBServer, AEditIPDBServer, AEditUsuarioDBServer,
      AEditPortaDBServer, AEditSenhaDBServer: TJvEdit;
      AComboBoxIDServer: TComboBox);
    destructor Destroy; override;
  end;

implementation

uses
  UntPrincipal;

constructor TThreadCarregarConfig.Create(AConexao: TUniConnection; AFormDestino: TForm;
  AEditNomeDBServerCliente, AEditIPDBServerCliente, AEditUsuarioDBServerCliente,
  AEditPortaDBServerCliente, AEditSenhaDBServerCliente: TJvEdit;
  AEditNomeDBServer, AEditIPDBServer, AEditUsuarioDBServer,
  AEditPortaDBServer, AEditSenhaDBServer: TJvEdit;
  AComboBoxIDServer: TComboBox);
begin
  inherited Create(False); // Inicia a thread automaticamente
  FreeOnTerminate := True; // Libera a mem�ria ao finalizar
  FConexao := AConexao;
  FFormDestino := AFormDestino;

  // Atribui os edits e combobox ao contexto da thread
  FEditNomeDBServerCliente := AEditNomeDBServerCliente;
  FEditIPDBServerCliente := AEditIPDBServerCliente;
  FEditUsuarioDBServerCliente := AEditUsuarioDBServerCliente;
  FEditPortaDBServerCliente := AEditPortaDBServerCliente;
  FEditSenhaDBServerCliente := AEditSenhaDBServerCliente;

  FEditNomeDBServer := AEditNomeDBServer;
  FEditIPDBServer := AEditIPDBServer;
  FEditUsuarioDBServer := AEditUsuarioDBServer;
  FEditPortaDBServer := AEditPortaDBServer;
  FEditSenhaDBServer := AEditSenhaDBServer;

  FComboBoxIDServer := AComboBoxIDServer;

  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := FConexao;
end;

destructor TThreadCarregarConfig.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TThreadCarregarConfig.Execute;
begin
  try
    if not FConexao.Connected then
      FConexao.Connect; // Certifique-se de que a conex�o est� ativa

    FQuery.SQL.Text := 'SELECT * FROM config_server_dtc LIMIT 1'; // Pega apenas um registro
    FQuery.Open;

    if not FQuery.IsEmpty then
    begin
      Synchronize(AtualizarComponentes); // Atualiza os edits e combobox na main thread
    end;
  except
    on E: Exception do
      Synchronize(
        procedure
        begin
        if Mensagem then
        begin
          ShowMessage('Erro ao carregar dados: ' + E.Message);
        end;
        FrmPrincipal.WriteLogFormatted('ERRO', '1', '[SERVER SALVAR CONFIG] Erro ao carregar dados: ' + E.Message);
        end);
  end;
end;

procedure TThreadCarregarConfig.AtualizarComponentes;
begin
  if Assigned(FFormDestino) and not FFormDestino.Visible then Exit;

  // Atualiza os TJvEdits
  FEditNomeDBServerCliente.Text := FQuery.FieldByName('Nome_DB_Server_Cliente').AsString;
  FEditIPDBServerCliente.Text := FQuery.FieldByName('IP_DB_Server_Cliente').AsString;
  FEditUsuarioDBServerCliente.Text := FQuery.FieldByName('Usuario_DB_Server_Cliente').AsString;
  FEditPortaDBServerCliente.Text := FQuery.FieldByName('Porta_DB_Server_Cliente').AsString;
  FEditSenhaDBServerCliente.Text := FQuery.FieldByName('Senha_DB_Server_Cliente').AsString;

  FEditNomeDBServer.Text := FQuery.FieldByName('Nome_DB_Server').AsString;
  FEditIPDBServer.Text := FQuery.FieldByName('IP_DB_Server').AsString;
  FEditUsuarioDBServer.Text := FQuery.FieldByName('Usuario_DB_Server').AsString;
  FEditPortaDBServer.Text := FQuery.FieldByName('Porta_DB_Server').AsString;
  FEditSenhaDBServer.Text := FQuery.FieldByName('Senha_DB_Server').AsString;

  // Atualiza o ComboBox
  FComboBoxIDServer.Items.Clear;
  FComboBoxIDServer.Items.Add(FQuery.FieldByName('ID_Server').AsString);
  FComboBoxIDServer.ItemIndex := 0; // Seleciona o primeiro item
end;

end.

