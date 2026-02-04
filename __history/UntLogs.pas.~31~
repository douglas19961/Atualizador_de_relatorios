unit UntLogs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Vcl.Buttons, System.IOUtils, System.IniFiles,
  Vcl.Mask, Vcl.Samples.Spin, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  System.DateUtils, Vcl.Menus, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.Net.HttpClientComponent, System.NetEncoding,
  IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders, IdGlobal, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP,
  IdFTPCommon, System.Zip, ShellAPI, ComObj, ShlObj, ActiveX, Registry,
  Vcl.WinXCtrls,  JvMenus,  Vcl.DBCtrls, JvExStdCtrls,
  JvEdit, JvListBox,   FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.DBClient,
  JvFullColorSpaces, JvFullColorCtrls, IdSMTP, IdMessage, IdText,
  IdHTTPServer, IdContext, IdCustomHTTPServer,  IdCustomTCPServer,
  System.Threading, System.Generics.Collections;

type
  TLogEntry = class
    Data: string;
    Hora: string;
    Nivel: string;
    Tipo: string;
    CodigoTipo: string;
    Mensagem: string;
    ArquivoOrigem: string;
  end;

  TArquivoLogInfo = class
    NomeArquivo: string;
    DataModificacao: TDateTime;
    constructor Create(const ANome: string; AData: TDateTime);
  end;

  TFrmLogs = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    lblDiretorio: TLabel;
    edtDiretorio: TEdit;
    lblArquivosLog: TLabel;
    lstArquivosLog: TListBox;
    btnAtualizar: TButton;
    btnMostrarLogs: TButton;
    btnRelatarLog: TButton;
    lblLogManual: TLabel;
    memLogManual: TMemo;
    btnAdicionar: TButton;
    pgcLogs: TPageControl;
    tsAtualizarMonitor: TTabSheet;
    tsAnalisarLogs: TTabSheet;
    tsLogManual: TTabSheet;
    tsRelatarLog: TTabSheet;
    pnlControles: TPanel;
    chkAtualizarAutomatico: TCheckBox;
    lblIntervalo: TLabel;
    spnIntervalo: TSpinEdit;
    lblSegundos: TLabel;
    lblMaxRegistros: TLabel;
    spnMaxRegistros: TSpinEdit;
    pnlGrid: TPanel;
    grdLogs: TStringGrid;
    pnlFiltro: TPanel;
    lblFiltroStatus: TLabel;
    btnPrimeiro: TButton;
    btnAnterior: TButton;
    btnPlayPause: TButton;
    btnProximo: TButton;
    btnUltimo: TButton;
    btnAtualizarGrid: TButton;
    btnFiltro: TButton;
    btnCustomizar: TButton;
    memMensagemSelecionada: TMemo;
    lblMensagemSelecionada: TLabel;
    tmrAtualizacao: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnMostrarLogsClick(Sender: TObject);
    procedure btnRelatarLogClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure lstArquivosLogClick(Sender: TObject);
    procedure lstArquivosLogDblClick(Sender: TObject);
    procedure grdLogsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure grdLogsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure btnPrimeiroClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnProximoClick(Sender: TObject);
    procedure btnUltimoClick(Sender: TObject);
    procedure btnAtualizarGridClick(Sender: TObject);
    procedure btnFiltroClick(Sender: TObject);
    procedure btnCustomizarClick(Sender: TObject);
    procedure chkAtualizarAutomaticoClick(Sender: TObject);
    procedure tmrAtualizacaoTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spnIntervaloChange(Sender: TObject);
    procedure spnMaxRegistrosChange(Sender: TObject);
  private
    FLogEntries: TObjectList<TLogEntry>;
    FArquivoAtual: string;
    FIndiceAtual: Integer;
    FAtualizacaoAutomatica: Boolean;
    FMaxRegistros: Integer;
    FIntervaloAtualizacao: Integer;
    FDiretorioLogs: string;
    FDiretorioLogsHistoricos: string;
    
    procedure ConfigurarGrid;
    procedure CarregarArquivosLog;
    procedure CarregarLogArquivo(const Arquivo: string);
    procedure AtualizarGrid;
    procedure AplicarFiltros;
    procedure SalvarLogManual(const Mensagem: string);
    procedure ConfigurarTimer;
    function ParseLogLine(const Linha: string; const ArquivoOrigem: string): TLogEntry;
    procedure LimparGrid;
    procedure AtualizarStatusFiltro;
    procedure ConfigurarDiretorios;
         function EncontrarArquivoLogMaisRecente: string;
         function ObterNomeTipoPorCodigo(const Codigo: string): string;
         procedure ProcessarTipoEMensagem(const MensagemCompleta: string; out CodigoTipo: string; out Mensagem: string; out NivelExtraido: string);
    function ObterCorNivel(const Nivel: string): TColor;

  public
    { Public declarations }
  end;

var
  FrmLogs: TFrmLogs;

implementation

uses
  System.Types, System.Math;

// Função global para comparação de arquivos por data
function CompararArquivosPorDataGlobal(List: TStringList; Index1, Index2: Integer): Integer;
var
  ArquivoInfo1, ArquivoInfo2: TArquivoLogInfo;
begin
  // Obter os objetos de informação dos arquivos
  ArquivoInfo1 := TArquivoLogInfo(List.Objects[Index1]);
  ArquivoInfo2 := TArquivoLogInfo(List.Objects[Index2]);
  
  // Ordenar do mais novo para o mais antigo (ordem decrescente)
  if ArquivoInfo1.DataModificacao > ArquivoInfo2.DataModificacao then
    Result := -1  // Index1 vem primeiro (mais novo)
  else if ArquivoInfo1.DataModificacao < ArquivoInfo2.DataModificacao then
    Result := 1   // Index2 vem primeiro (mais novo)
  else
    Result := 0;  // Mesma data
end;

{$R *.dfm}

constructor TArquivoLogInfo.Create(const ANome: string; AData: TDateTime);
begin
  inherited Create;
  NomeArquivo := ANome;
  DataModificacao := AData;
end;

procedure TFrmLogs.FormCreate(Sender: TObject);
begin
  FLogEntries := TObjectList<TLogEntry>.Create(True);
  FIndiceAtual := 0;
  FAtualizacaoAutomatica := False;
  FMaxRegistros := 50;
  FIntervaloAtualizacao := 10;
  
  ConfigurarDiretorios;
  ConfigurarGrid;
  ConfigurarTimer;
end;

procedure TFrmLogs.FormDestroy(Sender: TObject);
begin
  FLogEntries.Free;
end;

procedure TFrmLogs.FormShow(Sender: TObject);
begin
  CarregarArquivosLog;
  pgcLogs.ActivePage := tsAnalisarLogs;
end;

procedure TFrmLogs.ConfigurarDiretorios;
begin
  // Diretório raiz (logs atuais)
  FDiretorioLogs := ExtractFilePath(ParamStr(0));
  
  // Diretório de logs históricos
  FDiretorioLogsHistoricos := IncludeTrailingPathDelimiter(FDiretorioLogs) + 'logs\';
  
  edtDiretorio.Text := FDiretorioLogs;
end;

procedure TFrmLogs.ConfigurarGrid;
begin
  with grdLogs do
  begin
    ColCount := 5;
    RowCount := 2;
    
    // Configurar cabeçalhos
    Cells[0, 0] := 'Data';
    Cells[1, 0] := 'Hora';
    Cells[2, 0] := 'Nível';
    Cells[3, 0] := 'Tipo';
    Cells[4, 0] := 'Mensagem';
    
    // Configurar larguras das colunas
    ColWidths[0] := 80;   // Data
    ColWidths[1] := 70;   // Hora
    ColWidths[2] := 50;   // Nível
    ColWidths[3] := 70;  // Tipo
    ColWidths[4] := 500;  // Mensagem
    
    // Configurar propriedades
    FixedRows := 1;
    Options := Options + [goRowSelect, goColSizing];
    // Manter desenho padrão; customizamos apenas a coluna Nível no OnDrawCell
    DefaultDrawing := True;
  end;
  
  spnMaxRegistros.Value := FMaxRegistros;
  spnIntervalo.Value := FIntervaloAtualizacao;
end;

procedure TFrmLogs.ConfigurarTimer;
begin
  tmrAtualizacao.Interval := FIntervaloAtualizacao * 1000;
  tmrAtualizacao.Enabled := FAtualizacaoAutomatica;
  
  // Configurar valores dos controles
  spnIntervalo.Value := FIntervaloAtualizacao;
  spnMaxRegistros.Value := FMaxRegistros;
  chkAtualizarAutomatico.Checked := FAtualizacaoAutomatica;
end;

procedure TFrmLogs.CarregarArquivosLog;
var
  Arquivos: TStringDynArray;
  i: Integer;
  NomeArquivo: string;
  ListaArquivos: TStringList;
  CaminhoCompleto: string;
  DataArquivo: TDateTime;
  ArquivoInfo: TArquivoLogInfo;
begin
  lstArquivosLog.Clear;
  
  // Carregar logs atuais (raiz)
  if DirectoryExists(FDiretorioLogs) then
  begin
    Arquivos := TDirectory.GetFiles(FDiretorioLogs, '*.txt');
    for i := 0 to High(Arquivos) do
    begin
      NomeArquivo := ExtractFileName(Arquivos[i]);
      // Excluir config.txt dos logs
      if LowerCase(NomeArquivo) <> 'config.txt' then
        lstArquivosLog.Items.Add('[ATUAL] ' + NomeArquivo);
    end;
    
    Arquivos := TDirectory.GetFiles(FDiretorioLogs, '*.log');
    for i := 0 to High(Arquivos) do
    begin
      NomeArquivo := ExtractFileName(Arquivos[i]);
      lstArquivosLog.Items.Add('[ATUAL] ' + NomeArquivo);
    end;
  end;
  
  // Carregar logs históricos ordenados por data (mais novos primeiro)
  if DirectoryExists(FDiretorioLogsHistoricos) then
  begin
    ListaArquivos := TStringList.Create;
    try
      // Adicionar arquivos .txt
      Arquivos := TDirectory.GetFiles(FDiretorioLogsHistoricos, '*.txt');
      for i := 0 to High(Arquivos) do
      begin
        NomeArquivo := ExtractFileName(Arquivos[i]);
        // Excluir config.txt dos logs
        if LowerCase(NomeArquivo) <> 'config.txt' then
        begin
          CaminhoCompleto := FDiretorioLogsHistoricos + NomeArquivo;
          DataArquivo := TFile.GetLastWriteTime(CaminhoCompleto);
          ArquivoInfo := TArquivoLogInfo.Create(NomeArquivo, DataArquivo);
          ListaArquivos.AddObject('[HISTÓRICO] ' + NomeArquivo, ArquivoInfo);
        end;
      end;
      
      // Adicionar arquivos .log
      Arquivos := TDirectory.GetFiles(FDiretorioLogsHistoricos, '*.log');
      for i := 0 to High(Arquivos) do
      begin
        NomeArquivo := ExtractFileName(Arquivos[i]);
        CaminhoCompleto := FDiretorioLogsHistoricos + NomeArquivo;
        DataArquivo := TFile.GetLastWriteTime(CaminhoCompleto);
        ArquivoInfo := TArquivoLogInfo.Create(NomeArquivo, DataArquivo);
        ListaArquivos.AddObject('[HISTÓRICO] ' + NomeArquivo, ArquivoInfo);
      end;
      
             // Ordenar por data de modificação (mais novos primeiro)
       ListaArquivos.CustomSort(CompararArquivosPorDataGlobal);
      
      // Adicionar à lista de arquivos
      for i := 0 to ListaArquivos.Count - 1 do
        lstArquivosLog.Items.Add(ListaArquivos[i]);
        
    finally
      // Liberar objetos criados
      for i := 0 to ListaArquivos.Count - 1 do
        if ListaArquivos.Objects[i] <> nil then
          ListaArquivos.Objects[i].Free;
      ListaArquivos.Free;
    end;
  end;
end;

procedure TFrmLogs.CarregarLogArquivo(const Arquivo: string);
var
  Lista: TStringList;
  i: Integer;
  LogEntry: TLogEntry;
  CaminhoCompleto: string;
  EhLogAtual: Boolean;
  RegistrosCarregados: Integer;
begin
  FLogEntries.Clear;
  
  if FileExists(Arquivo) then
  begin
    CaminhoCompleto := Arquivo;
  end
  else if FileExists(FDiretorioLogs + Arquivo) then
  begin
    CaminhoCompleto := FDiretorioLogs + Arquivo;
  end
  else if FileExists(FDiretorioLogsHistoricos + Arquivo) then
  begin
    CaminhoCompleto := FDiretorioLogsHistoricos + Arquivo;
  end
  else
  begin
    ShowMessage('Arquivo não encontrado: ' + Arquivo);
    Exit;
  end;
  
  // Verificar se é log atual (arquivo na raiz)
  EhLogAtual := FileExists(FDiretorioLogs + ExtractFileName(Arquivo));
  
  Lista := TStringList.Create;
  try
    // Carregar arquivo com codificação UTF-8 para evitar problemas com caracteres especiais
    try
      Lista.LoadFromFile(CaminhoCompleto, TEncoding.UTF8);
    except
      // Se falhar com UTF-8, tentar com ANSI
      try
        Lista.LoadFromFile(CaminhoCompleto, TEncoding.Default);
      except
        // Última tentativa com ASCII
        Lista.LoadFromFile(CaminhoCompleto, TEncoding.ASCII);
      end;
    end;
    
    RegistrosCarregados := 0;
    
    for i := 0 to Lista.Count - 1 do
    begin
      if Trim(Lista[i]) <> '' then
      begin
        LogEntry := ParseLogLine(Lista[i], ExtractFileName(Arquivo));
        if LogEntry <> nil then
        begin
          FLogEntries.Add(LogEntry);
          Inc(RegistrosCarregados);
          
          // Se for log histórico, limitar pelo número máximo configurado
          if not EhLogAtual and (RegistrosCarregados >= FMaxRegistros) then
            Break;
        end;
      end;
    end;
    
    FArquivoAtual := Arquivo;
    AtualizarGrid;
    
  finally
    Lista.Free;
  end;
end;

function TFrmLogs.ParseLogLine(const Linha: string; const ArquivoOrigem: string): TLogEntry;
var
  Partes: TArray<string>;
  DataHora: string;
  Resto: string;
  PosPipe: Integer;
  CodigoTipo: string;
  MensagemCompleta: string;
  PosInicioMensagem: Integer;
  HoraCompleta: string;
  PosPonto: Integer;
  LinhaProcessada: Boolean;
begin
  Result := TLogEntry.Create;
  Result.ArquivoOrigem := ArquivoOrigem;
  LinhaProcessada := False;
  
  try
    // Tentar diferentes formatos de log
    if Pos('|', Linha) > 0 then
    begin
      // Formato: Data Hora | Nível | Tipo | ThreadID | Mensagem
      Partes := Linha.Split(['|']);
      if Length(Partes) >= 5 then
      begin
        DataHora := Trim(Partes[0]);
        if Pos(' ', DataHora) > 0 then
        begin
          Result.Data := Copy(DataHora, 1, Pos(' ', DataHora) - 1);
          HoraCompleta := Copy(DataHora, Pos(' ', DataHora) + 1, Length(DataHora));
          
          // Formatar hora para hh:mm:ss (remover milissegundos)
          PosPonto := Pos('.', HoraCompleta);
          if PosPonto > 0 then
            Result.Hora := Copy(HoraCompleta, 1, PosPonto - 1)
          else
            Result.Hora := HoraCompleta;
        end
        else
        begin
          Result.Data := DataHora;
          Result.Hora := '';
        end;
        
        Result.Nivel := Trim(Partes[1]);
        MensagemCompleta := Trim(Partes[4]);
        
        // Extrair código do tipo e processar mensagem
        ProcessarTipoEMensagem(MensagemCompleta, CodigoTipo, Result.Mensagem, Result.Nivel);
        Result.CodigoTipo := CodigoTipo;
        Result.Tipo := ObterNomeTipoPorCodigo(CodigoTipo);
        LinhaProcessada := True;
      end;
    end
    else if Pos(' - ', Linha) > 0 then
    begin
      // Formato: Data Hora - Nível - Tipo - ThreadID - Mensagem
      Partes := Linha.Split([' - ']);
      if Length(Partes) >= 5 then
      begin
        DataHora := Trim(Partes[0]);
        if Pos(' ', DataHora) > 0 then
        begin
          Result.Data := Copy(DataHora, 1, Pos(' ', DataHora) - 1);
          HoraCompleta := Copy(DataHora, Pos(' ', DataHora) + 1, Length(DataHora));
          
          // Formatar hora para hh:mm:ss (remover milissegundos)
          PosPonto := Pos('.', HoraCompleta);
          if PosPonto > 0 then
            Result.Hora := Copy(HoraCompleta, 1, PosPonto - 1)
          else
            Result.Hora := HoraCompleta;
        end
        else
        begin
          Result.Data := DataHora;
          Result.Hora := '';
        end;
        
        Result.Nivel := Trim(Partes[1]);
        MensagemCompleta := Trim(Partes[4]);
        
        // Extrair código do tipo e processar mensagem
        ProcessarTipoEMensagem(MensagemCompleta, CodigoTipo, Result.Mensagem, Result.Nivel);
        Result.CodigoTipo := CodigoTipo;
        Result.Tipo := ObterNomeTipoPorCodigo(CodigoTipo);
        LinhaProcessada := True;
      end;
    end
    else
    begin
      // Formato simples: Data Hora Mensagem
      if Pos(' ', Linha) > 0 then
      begin
        DataHora := Copy(Linha, 1, Pos(' ', Linha) - 1);
        Resto := Copy(Linha, Pos(' ', Linha) + 1, Length(Linha));
        
        if Pos(' ', Resto) > 0 then
        begin
          Result.Data := DataHora;
          HoraCompleta := Copy(Resto, 1, Pos(' ', Resto) - 1);
          
          // Formatar hora para hh:mm:ss (remover milissegundos)
          PosPonto := Pos('.', HoraCompleta);
          if PosPonto > 0 then
            Result.Hora := Copy(HoraCompleta, 1, PosPonto - 1)
          else
            Result.Hora := HoraCompleta;
            
          MensagemCompleta := Copy(Resto, Pos(' ', Resto) + 1, Length(Resto));
          
          // Extrair código do tipo e processar mensagem
          ProcessarTipoEMensagem(MensagemCompleta, CodigoTipo, Result.Mensagem, Result.Nivel);
          Result.CodigoTipo := CodigoTipo;
          Result.Tipo := ObterNomeTipoPorCodigo(CodigoTipo);
          LinhaProcessada := True;
        end
        else
        begin
          Result.Data := DataHora;
          HoraCompleta := Resto;
          
          // Formatar hora para hh:mm:ss (remover milissegundos)
          PosPonto := Pos('.', HoraCompleta);
          if PosPonto > 0 then
            Result.Hora := Copy(HoraCompleta, 1, PosPonto - 1)
          else
            Result.Hora := HoraCompleta;
            
          Result.Mensagem := '';
          Result.CodigoTipo := '0';
          Result.Tipo := 'Sistema';
          Result.Nivel := 'INFO';
          LinhaProcessada := True;
        end;
      end;
    end;
    
    // Se não conseguiu processar nenhum formato, criar log desconhecido
    if not LinhaProcessada then
    begin
      Result.Data := FormatDateTime('dd/mm/yyyy', Now);
      Result.Hora := FormatDateTime('hh:nn:ss', Now);
      Result.Nivel := 'DESCONHECIDO';
      Result.Tipo := 'LOG NÃO RECONHECIDO';
      Result.CodigoTipo := '999';
      Result.Mensagem := 'MSG: ' + Linha;
    end;
    
  except
    Result.Free;
    Result := nil;
  end;
end;

procedure TFrmLogs.AtualizarGrid;
var
  i, LinhaGrid: Integer;
  LogEntry: TLogEntry;
  MaxLarguraData, MaxLarguraHora, MaxLarguraNivel, MaxLarguraTipo: Integer;
  Canvas: TCanvas;
  EhLogAtual: Boolean;
  PosicaoScrollAnterior: Integer;
  DeveManterPosicao: Boolean;
begin
  // Verificar se deve manter a posição da barra de rolagem
  DeveManterPosicao := FAtualizacaoAutomatica and (FArquivoAtual <> '');
  if DeveManterPosicao then
    PosicaoScrollAnterior := grdLogs.TopRow;
  
  LimparGrid;
  
  if FLogEntries.Count = 0 then
  begin
    grdLogs.Cells[0, 1] := '<Nenhum registro para exibir>';
    grdLogs.RowCount := 2; // Apenas cabeçalho + 1 linha vazia
    Exit;
  end;
  
  // Verificar se é log atual (arquivo na raiz)
  EhLogAtual := FileExists(FDiretorioLogs + FArquivoAtual);
  
  // Ajustar RowCount dinamicamente para evitar espaços em branco
  grdLogs.RowCount := FLogEntries.Count + 1; // +1 para cabeçalho
  
  // Inicializar larguras máximas
  MaxLarguraData := 0;
  MaxLarguraHora := 0;
  MaxLarguraNivel := 0;
  MaxLarguraTipo := 0;
  
  Canvas := grdLogs.Canvas;
  Canvas.Font := grdLogs.Font;
  
  for i := 0 to FLogEntries.Count - 1 do
  begin
    LogEntry := FLogEntries[i];
    LinhaGrid := i + 1; // +1 para pular cabeçalho
    
    grdLogs.Cells[0, LinhaGrid] := LogEntry.Data;
    grdLogs.Cells[1, LinhaGrid] := LogEntry.Hora;
    grdLogs.Cells[2, LinhaGrid] := LogEntry.Nivel;
    grdLogs.Cells[3, LinhaGrid] := LogEntry.Tipo;
    grdLogs.Cells[4, LinhaGrid] := LogEntry.Mensagem;
    
    // Calcular larguras máximas
    MaxLarguraData := Max(MaxLarguraData, Canvas.TextWidth(LogEntry.Data) + 20);
    MaxLarguraHora := Max(MaxLarguraHora, Canvas.TextWidth(LogEntry.Hora) + 20);
    MaxLarguraNivel := Max(MaxLarguraNivel, Canvas.TextWidth(LogEntry.Nivel) + 20);
    MaxLarguraTipo := Max(MaxLarguraTipo, Canvas.TextWidth(LogEntry.Tipo) + 20);
  end;
  
  // Ajustar larguras das colunas
  grdLogs.ColWidths[0] := Max(80, MaxLarguraData);   // Data
  grdLogs.ColWidths[1] := Max(70, MaxLarguraHora);   // Hora
  grdLogs.ColWidths[2] := Max(50, MaxLarguraNivel);  // Nível
  grdLogs.ColWidths[3] := Max(150, MaxLarguraTipo);  // Tipo
  // Mensagem mantém largura fixa ou ajusta automaticamente
  
  // Restaurar posição da barra de rolagem se necessário
  if DeveManterPosicao then
  begin
    // Se for log atual, ir para o final (últimos registros)
    if EhLogAtual then
      grdLogs.TopRow := grdLogs.RowCount - grdLogs.VisibleRowCount
    else
      grdLogs.TopRow := PosicaoScrollAnterior;
  end;
  
  AtualizarStatusFiltro;
end;

procedure TFrmLogs.LimparGrid;
var
  i: Integer;
begin
  for i := 1 to grdLogs.RowCount - 1 do
  begin
    grdLogs.Cells[0, i] := '';
    grdLogs.Cells[1, i] := '';
    grdLogs.Cells[2, i] := '';
    grdLogs.Cells[3, i] := '';
    grdLogs.Cells[4, i] := '';
  end;
end;

procedure TFrmLogs.AtualizarStatusFiltro;
begin
  lblFiltroStatus.Caption := '<Filtro Vazio>';
end;

procedure TFrmLogs.AplicarFiltros;
begin
  // Implementar filtros aqui
  AtualizarGrid;
end;

procedure TFrmLogs.SalvarLogManual(const Mensagem: string);
var
  ArquivoLog: string;
  Lista: TStringList;
  DataHora: string;
begin
  if Trim(Mensagem) = '' then
  begin
    ShowMessage('Digite uma mensagem para o log manual.');
    Exit;
  end;
  
  // Encontrar o arquivo de log mais recente
  ArquivoLog := EncontrarArquivoLogMaisRecente;
  
  if ArquivoLog = '' then
  begin
    ShowMessage('Nenhum arquivo de log encontrado para adicionar o registro manual.');
    Exit;
  end;
  
  Lista := TStringList.Create;
  try
    if FileExists(ArquivoLog) then
    begin
      // Carregar arquivo com codificação UTF-8 para evitar problemas com caracteres especiais
      try
        Lista.LoadFromFile(ArquivoLog, TEncoding.UTF8);
      except
        // Se falhar com UTF-8, tentar com ANSI
        try
          Lista.LoadFromFile(ArquivoLog, TEncoding.Default);
        except
          // Última tentativa com ASCII
          Lista.LoadFromFile(ArquivoLog, TEncoding.ASCII);
        end;
      end;
    end;
    
    DataHora := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
    Lista.Add(Format('%s - INFO - INFO(1)] %s', [DataHora, Mensagem]));
    
    Lista.SaveToFile(ArquivoLog, TEncoding.UTF8);
    ShowMessage('Log manual adicionado com sucesso!');
    
    // Recarregar o arquivo se estiver sendo exibido
    if FArquivoAtual = ExtractFileName(ArquivoLog) then
      CarregarLogArquivo(FArquivoAtual);
      
  finally
    Lista.Free;
  end;
end;

function TFrmLogs.EncontrarArquivoLogMaisRecente: string;
var
  Arquivos: TStringDynArray;
  i: Integer;
  DataArquivo, DataMaisRecente: TDateTime;
  ArquivoMaisRecente: string;
  NomeArquivo: string;
begin
  Result := '';
  DataMaisRecente := 0;
  ArquivoMaisRecente := '';
  
  // Verificar na raiz
  if DirectoryExists(FDiretorioLogs) then
  begin
    Arquivos := TDirectory.GetFiles(FDiretorioLogs, '*.txt');
    for i := 0 to High(Arquivos) do
    begin
      NomeArquivo := ExtractFileName(Arquivos[i]);
      // Excluir config.txt
      if LowerCase(NomeArquivo) <> 'config.txt' then
      begin
        DataArquivo := TFile.GetLastWriteTime(Arquivos[i]);
        if DataArquivo > DataMaisRecente then
        begin
          DataMaisRecente := DataArquivo;
          ArquivoMaisRecente := Arquivos[i];
        end;
      end;
    end;
    
    Arquivos := TDirectory.GetFiles(FDiretorioLogs, '*.log');
    for i := 0 to High(Arquivos) do
    begin
      DataArquivo := TFile.GetLastWriteTime(Arquivos[i]);
      if DataArquivo > DataMaisRecente then
      begin
        DataMaisRecente := DataArquivo;
        ArquivoMaisRecente := Arquivos[i];
      end;
    end;
  end;
  
  Result := ArquivoMaisRecente;
end;



procedure TFrmLogs.ProcessarTipoEMensagem(const MensagemCompleta: string; out CodigoTipo: string; out Mensagem: string; out NivelExtraido: string);
var
  PosInicio, PosFim: Integer;
  Codigo: string;
  NiveisLog: array[0..4] of string;
  i: Integer;
  PosColchete: Integer;
begin
  // Array com os níveis de log possíveis
  NiveisLog[0] := 'INFO(';
  NiveisLog[1] := 'DEBUG(';
  NiveisLog[2] := 'ERROR(';
  NiveisLog[3] := 'WARNING(';
  NiveisLog[4] := 'FATAL(';
  
  // Primeiro, verificar se a mensagem começa com '[' (formato WriteLogFormatted)
  if (Length(MensagemCompleta) > 0) and (MensagemCompleta[1] = '[') then
  begin
    // Formato: [28/08/2025 14:53:06.123 DEBUG(112)] [CONSULTA VERSÃO DTCSYNC] Versão "1.0.7" salva para empresa 111
    // Procurar pelo segundo ']' que fecha o cabeçalho
    PosColchete := Pos(']', MensagemCompleta);
    if PosColchete > 0 then
    begin
      // Extrair a parte após o segundo ']' como mensagem
      Mensagem := Trim(Copy(MensagemCompleta, PosColchete + 1, Length(MensagemCompleta)));
      
      // Procurar o código na parte do cabeçalho
      for i := 0 to High(NiveisLog) do
      begin
        PosInicio := Pos(NiveisLog[i], MensagemCompleta);
        if PosInicio > 0 then
        begin
          // Encontrar o fechamento do parêntese
          PosFim := Pos(')', MensagemCompleta);
          if (PosFim > PosInicio) and (PosFim < PosColchete) then
          begin
            // Extrair o código
            Codigo := Copy(MensagemCompleta, PosInicio + Length(NiveisLog[i]), PosFim - PosInicio - Length(NiveisLog[i]));
            CodigoTipo := Codigo;
            
            // Extrair o nível (remover o '(' do final)
            NivelExtraido := Copy(NiveisLog[i], 1, Length(NiveisLog[i]) - 1);
            Exit; // Encontrou o padrão, sair do loop
          end;
        end;
      end;
    end;
  end;
  
  // Procurar por qualquer padrão de nível(código) na mensagem (formato antigo)
  for i := 0 to High(NiveisLog) do
  begin
    PosInicio := Pos(NiveisLog[i], MensagemCompleta);
    if PosInicio > 0 then
    begin
      // Encontrar o fechamento do parêntese
      PosFim := Pos(')', MensagemCompleta);
      if (PosFim > PosInicio) then
      begin
        // Extrair o código (remover o prefixo do nível)
        Codigo := Copy(MensagemCompleta, PosInicio + Length(NiveisLog[i]), PosFim - PosInicio - Length(NiveisLog[i]));
        CodigoTipo := Codigo;
        
        // Extrair o nível (remover o '(' do final)
        NivelExtraido := Copy(NiveisLog[i], 1, Length(NiveisLog[i]) - 1);
        
        // Extrair a mensagem (tudo após o fechamento do parêntese)
        Mensagem := Trim(Copy(MensagemCompleta, PosFim + 1, Length(MensagemCompleta)));
        
        // Se a mensagem começa com ']', removê-lo
        if (Length(Mensagem) > 0) and (Mensagem[1] = ']') then
          Mensagem := Trim(Copy(Mensagem, 2, Length(Mensagem)));
        
        Exit; // Encontrou o padrão, sair do loop
      end;
    end;
  end;
  
  // Se não encontrar nenhum padrão de nível(código), usar padrão
  CodigoTipo := '0';
  Mensagem := MensagemCompleta;
  NivelExtraido := 'INFO';
end;

function TFrmLogs.ObterCorNivel(const Nivel: string): TColor;
begin
  // Função para determinar a cor baseada no nível do log
  // Você pode alimentar esta função com as cores desejadas
  if UpperCase(Nivel) = 'INFO' then
    Result := RGB(175,238,238)  // Verde fraco
  else if UpperCase(Nivel) = 'ERRO' then
    Result := RGB(255, 200, 200)  // Vermelho fraco
  else if UpperCase(Nivel) = 'WARNING' then
    Result := RGB(255, 255, 200)  // Amarelo fraco
  else if UpperCase(Nivel) = 'DEBUG' then
    Result := RGB(102, 255, 102)  // Azul fraco
  else if UpperCase(Nivel) = 'FATAL' then
    Result := RGB(255, 150, 150)  // Vermelho mais forte
  else if UpperCase(Nivel) = 'DESCONHECIDO' then
    Result := RGB(255,255,0)  // Vermelho fraco para desconhecido
  else
    Result := clWhite;  // Cor padrão para outros níveis
end;

function TFrmLogs.ObterNomeTipoPorCodigo(const Codigo: string): string;
begin
  // Legenda de códigos de tipo
  if Codigo = '1' then
    Result := 'SISTEMA'
  else if Codigo = '2' then
    Result := 'CONEXÃO ROTINA'
  else if Codigo = '3' then
    Result := 'INSERIR MODULOS'
  else if Codigo = '4' then
    Result := 'DEL INICIALIZADOR'


  else if Codigo = '101' then
    Result := 'PRODUÇÃO'
  else if Codigo = '102' then
    Result := 'CNPJ'
  else if Codigo = '103' then
    Result := 'NFC-e DIVERGENCIA'
  else if Codigo = '104' then
    Result := 'NF-e DIVERGENCIA'
  else if Codigo = '105' then
    Result := 'VALIDADE'
  else if Codigo = '106' then
    Result := 'DATA HORA'
  else if Codigo = '107' then
    Result := 'DATA E HORA'
  else if Codigo = '108' then
    Result := 'INTEGRAÇÃO ESTRADA'
  else if Codigo = '109' then
    Result := 'CONEXÃO LOCAL'
  else if Codigo = '110' then
    Result := 'ENCERRANTES SIG'
  else if Codigo = '111' then
    Result := 'CERTIFICADOS WINDOWNS'
  else if Codigo = '112' then
    Result := 'VERSÃO DTCSYNC'
  else if Codigo = '113' then
    Result := 'DOCUMENTOS FISCAIS'
  else if Codigo = '114' then
    Result := 'REPLICAS CLIENTES'
  else if Codigo = '115' then
    Result := 'DTCSYNC'
  else if Codigo = '116' then
    Result := 'BACKUP-DOS'
  else if Codigo = '117' then
    Result := 'ENCERRANTES FROTA'
  else if Codigo = '120' then
    Result := 'THREAD MONITOR OCORRENCIAS'
    else if Codigo = '121' then
    Result := 'VERSÃO SIGILO CLIENTE'
  else if Codigo = '122' then
    Result := 'RELATÓRIOS'
  else if Codigo = '123' then
    Result := 'MAQUINA'
  else if Codigo = '124' then
    Result := 'NFC-e CONTINGÊNCIA'
  else if Codigo = '125' then
    Result := 'NF-e CONTINGÊNCIA'
   else if Codigo = '126' then
    Result := 'CRIAR TABELAS PADRÕES'
    else if Codigo = '127' then
    Result := 'LOGOS RELATORIOS'
   else if Codigo = '128' then
    Result := 'INICIALIZAR'
   else if Codigo = '129' then
    Result := 'NFE_NFCE_DUPLICADAS'
   else if Codigo = '130' then
    Result := 'VENCIMENTO SIGILO'
   else if Codigo = '131' then
    Result := 'BAT TIMER'


  else if Codigo = '1500' then
    Result := 'INTEGRAÇÃO TONIN'
    else if Codigo = '1501' then
    Result := 'INTEGRAÇÃO ENTREGA(PEGORARO)'


  else
    Result := 'TIPO DESCONHECIDO (' + Codigo + ')';
end;



// Eventos dos botões
procedure TFrmLogs.btnAtualizarClick(Sender: TObject);
begin
  CarregarArquivosLog;
end;

procedure TFrmLogs.btnMostrarLogsClick(Sender: TObject);
var
  ArquivoSelecionado: string;
begin
  if lstArquivosLog.ItemIndex >= 0 then
  begin
    ArquivoSelecionado := lstArquivosLog.Items[lstArquivosLog.ItemIndex];
    // Remover prefixo [ATUAL] ou [HISTÓRICO]
    if Pos('[ATUAL] ', ArquivoSelecionado) > 0 then
      ArquivoSelecionado := Copy(ArquivoSelecionado, 9, Length(ArquivoSelecionado))
    else if Pos('[HISTÓRICO] ', ArquivoSelecionado) > 0 then
      ArquivoSelecionado := Copy(ArquivoSelecionado, 13, Length(ArquivoSelecionado));
    
    CarregarLogArquivo(ArquivoSelecionado);
  end
  else
    ShowMessage('Selecione um arquivo de log para visualizar.');
end;

procedure TFrmLogs.btnRelatarLogClick(Sender: TObject);
begin
  // Implementar geração de relatório
  ShowMessage('Funcionalidade de relatório será implementada.');
end;

procedure TFrmLogs.btnAdicionarClick(Sender: TObject);
begin
  SalvarLogManual(memLogManual.Text);
  memLogManual.Clear;
end;

procedure TFrmLogs.lstArquivosLogClick(Sender: TObject);
begin
  // Opcional: carregar automaticamente ao clicar
  // btnMostrarLogsClick(Sender);
end;

procedure TFrmLogs.lstArquivosLogDblClick(Sender: TObject);
begin
  // Carregar automaticamente ao dar duplo clique
  btnMostrarLogsClick(Sender);
end;

procedure TFrmLogs.grdLogsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (ARow >= 1) and (ARow < grdLogs.RowCount) then
  begin
    FIndiceAtual := ARow - 1;
    if (FIndiceAtual >= 0) and (FIndiceAtual < FLogEntries.Count) then
    begin
      memMensagemSelecionada.Text := FLogEntries[FIndiceAtual].Mensagem;
    end;
  end;
end;

procedure TFrmLogs.grdLogsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LogEntry: TLogEntry;
  Texto: string;
begin
  // Aplicar cor apenas na coluna Nível (coluna 2) e apenas nas linhas de dados (ARow > 0)
  if (ACol = 2) and (ARow > 0) and (ARow - 1 < FLogEntries.Count) then
  begin
    LogEntry := FLogEntries[ARow - 1];
    
    // Definir cor de fundo baseada no nível
    grdLogs.Canvas.Brush.Color := ObterCorNivel(LogEntry.Nivel);
    
    // Definir cor do texto
    if gdSelected in State then
      grdLogs.Canvas.Font.Color := clBlack
    else
      grdLogs.Canvas.Font.Color := clBlack;
    
    // Preencher o retângulo com a cor de fundo
    grdLogs.Canvas.FillRect(Rect);
    
    // Desenhar o texto
    Texto := grdLogs.Cells[ACol, ARow];
    grdLogs.Canvas.TextRect(Rect, Texto, [tfCenter, tfVerticalCenter]);
  end
  else
  begin
    // Para outras colunas ou cabeçalho, usar o comportamento padrão
    grdLogs.Canvas.Brush.Color := clWindow;
    grdLogs.Canvas.Font.Color := clWindowText;
  end;
end;

procedure TFrmLogs.btnPrimeiroClick(Sender: TObject);
begin
  if FLogEntries.Count > 0 then
  begin
    FIndiceAtual := 0;
    grdLogs.Row := FIndiceAtual + 1;
    if (FIndiceAtual >= 0) and (FIndiceAtual < FLogEntries.Count) then
    begin
      memMensagemSelecionada.Text := FLogEntries[FIndiceAtual].Mensagem;
    end;
  end;
end;

procedure TFrmLogs.btnAnteriorClick(Sender: TObject);
begin
  if FIndiceAtual > 0 then
  begin
    Dec(FIndiceAtual);
    grdLogs.Row := FIndiceAtual + 1;
    if (FIndiceAtual >= 0) and (FIndiceAtual < FLogEntries.Count) then
    begin
      memMensagemSelecionada.Text := FLogEntries[FIndiceAtual].Mensagem;
    end;
  end;
end;

procedure TFrmLogs.btnProximoClick(Sender: TObject);
begin
  if FIndiceAtual < FLogEntries.Count - 1 then
  begin
    Inc(FIndiceAtual);
    grdLogs.Row := FIndiceAtual + 1;
    if (FIndiceAtual >= 0) and (FIndiceAtual < FLogEntries.Count) then
    begin
      memMensagemSelecionada.Text := FLogEntries[FIndiceAtual].Mensagem;
    end;
  end;
end;

procedure TFrmLogs.btnUltimoClick(Sender: TObject);
begin
  if FLogEntries.Count > 0 then
  begin
    FIndiceAtual := FLogEntries.Count - 1;
    grdLogs.Row := FIndiceAtual + 1;
    if (FIndiceAtual >= 0) and (FIndiceAtual < FLogEntries.Count) then
    begin
      memMensagemSelecionada.Text := FLogEntries[FIndiceAtual].Mensagem;
    end;
  end;
end;

procedure TFrmLogs.btnAtualizarGridClick(Sender: TObject);
begin
  if FArquivoAtual <> '' then
    CarregarLogArquivo(FArquivoAtual);
end;

procedure TFrmLogs.btnFiltroClick(Sender: TObject);
begin
  AplicarFiltros;
end;

procedure TFrmLogs.btnCustomizarClick(Sender: TObject);
begin
  // Implementar customização de filtros
  ShowMessage('Funcionalidade de customização será implementada.');
end;

procedure TFrmLogs.chkAtualizarAutomaticoClick(Sender: TObject);
begin
  FAtualizacaoAutomatica := chkAtualizarAutomatico.Checked;
  FIntervaloAtualizacao := spnIntervalo.Value;
  FMaxRegistros := spnMaxRegistros.Value;
  
  tmrAtualizacao.Interval := FIntervaloAtualizacao * 1000;
  tmrAtualizacao.Enabled := FAtualizacaoAutomatica;
end;

procedure TFrmLogs.tmrAtualizacaoTimer(Sender: TObject);
begin
  if FArquivoAtual <> '' then
    CarregarLogArquivo(FArquivoAtual);
end;

procedure TFrmLogs.spnIntervaloChange(Sender: TObject);
begin
  FIntervaloAtualizacao := spnIntervalo.Value;
  if FAtualizacaoAutomatica then
  begin
    tmrAtualizacao.Interval := FIntervaloAtualizacao * 1000;
  end;
end;

procedure TFrmLogs.spnMaxRegistrosChange(Sender: TObject);
begin
  FMaxRegistros := spnMaxRegistros.Value;
  if FArquivoAtual <> '' then
    AtualizarGrid;
end;

end.


