# Documentação do Sistema de Logs

## Visão Geral

O sistema de logs foi implementado para permitir a visualização e análise de arquivos de log tanto atuais (na raiz do aplicativo) quanto históricos (na pasta `logs/`). O formulário oferece uma interface intuitiva para navegar, filtrar e analisar os logs do sistema.

## Funcionalidades Principais

### 1. Visualização de Logs
- **Logs Atuais**: Arquivos `.txt` e `.log` localizados na raiz do aplicativo
- **Logs Históricos**: Arquivos `.txt` e `.log` localizados na pasta `logs/`
- **Formato de Exibição**: Tabela com colunas para Data, Hora, Nível, Tipo, Thread ID e Mensagem

### 2. Controles de Atualização
- **Atualização Automática**: Checkbox para ativar atualização automática
- **Intervalo Configurável**: De 1 a 3600 segundos
- **Limite de Registros**: Configuração do número máximo de registros exibidos (1 a 10.000)

### 3. Navegação
- **Botões de Navegação**: Primeiro, Anterior, Próximo, Último
- **Atualização Manual**: Botão para recarregar o arquivo atual
- **Filtros**: Sistema de filtros para busca específica

### 4. Log Manual
- **Adição de Registros**: Possibilidade de adicionar entradas manuais ao arquivo de log mais recente
- **Formato Padrão**: Segue o padrão do sistema de logs

## Interface do Usuário

### Painel Esquerdo
- **Lista de Arquivos**: Exibe todos os arquivos de log disponíveis com prefixos `[ATUAL]` e `[HISTÓRICO]`
- **Botões de Ação**:
  - `Atualizar (F5)`: Recarrega a lista de arquivos
  - `Mostrar Logs`: Carrega o arquivo selecionado
  - `Relatar Log`: Gera relatórios (funcionalidade futura)
- **Seção de Log Manual**: Área para adicionar entradas manuais

### Painel Direito
- **Abas**: Atualizar Monitor, Analisar Logs, Log Manual, Relatar Log
- **Controles de Atualização**: Configurações de intervalo e limite de registros
- **Grid de Logs**: Tabela principal com os dados dos logs
- **Barra de Navegação**: Controles de navegação e filtros
- **Área de Mensagem**: Exibe a mensagem completa do registro selecionado

## Formatos de Log Suportados

### 1. Formato com Pipe (|)
```
Data Hora | Nível | Tipo | ThreadID | Mensagem
28/08/2025 08:24:48 | DEBG | DataEntity | 18832 | Call to GetQueryRecords, number of requestItems = 1
```

### 2. Formato com Hífen (-)
```
Data Hora - Nível - Tipo - ThreadID - Mensagem
28/08/2025 08:24:48 - DEBG - DataEntity - 18832 - Call to GetQueryRecords, number of requestItems = 1
```

### 3. Formato Simples
```
Data Hora Mensagem
28/08/2025 08:24:48 Call to GetQueryRecords, number of requestItems = 1
```

## Como Usar

### 1. Abrir o Sistema de Logs
- Clique no botão `SpLogs` (BTN_Logs) no formulário principal
- O formulário de logs será aberto automaticamente

### 2. Selecionar um Arquivo de Log
- Na lista do painel esquerdo, escolha um arquivo de log
- Clique em `Mostrar Logs` para carregar o conteúdo

### 3. Configurar Atualização Automática
- Marque a caixa `Atualizar a cada`
- Configure o intervalo desejado (em segundos)
- Configure o número máximo de registros a exibir

### 4. Navegar pelos Registros
- Use os botões de navegação na barra inferior
- Clique em qualquer linha do grid para ver a mensagem completa
- Use os filtros para buscar registros específicos

### 5. Adicionar Log Manual
- Digite a mensagem na área de texto do painel esquerdo
- Clique em `Adicionar` para salvar no arquivo de log mais recente

## Estrutura de Arquivos

```
Aplicativo/
├── Logs.txt (logs atuais)
├── Logs.log (logs atuais)
├── logs/
│   ├── Logs_2025-08-13_16-54-32.txt (logs históricos)
│   └── ... (outros arquivos históricos)
└── ...
```

## Configurações

### Diretórios
- **Logs Atuais**: `ExtractFilePath(ParamStr(0))` (raiz do aplicativo)
- **Logs Históricos**: `ExtractFilePath(ParamStr(0)) + 'logs\'`

### Valores Padrão
- **Intervalo de Atualização**: 10 segundos
- **Máximo de Registros**: 50
- **Atualização Automática**: Desativada

## Funcionalidades Futuras

### 1. Sistema de Filtros Avançados
- Filtro por data/hora
- Filtro por nível de log (DEBUG, INFO, ERROR, etc.)
- Filtro por tipo de operação
- Filtro por Thread ID

### 2. Geração de Relatórios
- Exportação para PDF
- Exportação para Excel
- Relatórios por período
- Estatísticas de uso

### 3. Customização de Interface
- Temas visuais
- Configuração de colunas
- Personalização de cores

### 4. Integração com APIs
- Envio de logs para sistemas externos
- Monitoramento em tempo real
- Alertas automáticos

## Código de Exemplo

### Abertura do Formulário
```pascal
procedure TFrmPrincipal.BTN_LogsClick(Sender: TObject);
begin
  if not Assigned(FrmLogs) then
    FrmLogs := TFrmLogs.Create(Self);
  
  FrmLogs.Show;
  FrmLogs.BringToFront;
end;
```

### Adição de Log Manual
```pascal
procedure TFrmLogs.SalvarLogManual(const Mensagem: string);
var
  ArquivoLog: string;
  Lista: TStringList;
  DataHora: string;
begin
  ArquivoLog := EncontrarArquivoLogMaisRecente;
  
  Lista := TStringList.Create;
  try
    if FileExists(ArquivoLog) then
      Lista.LoadFromFile(ArquivoLog);
    
    DataHora := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
    Lista.Add(Format('%s - MANUAL - Sistema - 0 - %s', [DataHora, Mensagem]));
    
    Lista.SaveToFile(ArquivoLog);
  finally
    Lista.Free;
  end;
end;
```

## Troubleshooting

### Problemas Comuns

1. **Arquivo não encontrado**
   - Verifique se o arquivo existe no diretório correto
   - Use o botão "Atualizar" para recarregar a lista

2. **Logs não aparecem**
   - Verifique o formato do arquivo de log
   - Certifique-se de que o arquivo não está vazio

3. **Atualização automática não funciona**
   - Verifique se a caixa "Atualizar a cada" está marcada
   - Confirme se o intervalo está configurado corretamente

4. **Performance lenta**
   - Reduza o número máximo de registros exibidos
   - Aumente o intervalo de atualização automática

## Suporte

Para dúvidas ou problemas com o sistema de logs, consulte:
- Documentação técnica do projeto
- Logs de erro do sistema
- Equipe de desenvolvimento

---

*Versão: 1.0 | Data: 28/08/2025* 