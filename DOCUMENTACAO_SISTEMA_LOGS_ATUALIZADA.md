# Documentação do Sistema de Logs - Versão Atualizada

## Visão Geral

O sistema de logs foi atualizado para processar automaticamente os códigos de tipo baseados na legenda fornecida. Agora o sistema extrai automaticamente o código do tipo da mensagem e exibe o nome descritivo correspondente.

## Novas Funcionalidades

### 1. Processamento Automático de Códigos de Tipo
- **Extração de Código**: O sistema identifica automaticamente padrões como `INFO(107)` na mensagem
- **Legenda Integrada**: Códigos são convertidos automaticamente para nomes descritivos
- **Mensagem Limpa**: Remove o prefixo `INFO(código)]` da mensagem exibida

### 2. Interface Otimizada
- **5 Colunas**: Data, Hora, Nível, Tipo, Mensagem
- **Coluna Thread ID Removida**: Simplificação da interface
- **Tipo Descritivo**: Exibe o nome completo do tipo baseado no código

## Legenda de Códigos de Tipo

| Código | Nome do Tipo | Descrição |
|--------|--------------|-----------|
| **1** | LOGS(SISTEMA) | GERENCIAMENTO DE LOGS |
| **101** | PRODUÇÃO | ERRO PRODUÇÃO |
| **102** | CNPJ | VALIDAÇÃO CNPJ |
| **103** | NFC-e | CONSULTA NFCE DIVERGENCIA |
| **104** | NF-e | CONSULTA NFE DIVERGENCIA |
| **105** | VALIDADE | ATUALIZA VALIDADE DO SIGILO |
| **107** | ATUALIZA DATA E HORA | ATUALIZA DATA E HORA DO CLIENTE VIA API |
| **108** | EXECUTADOR DE INTEGRAÇÃO ESTRADA | ESTRADA |
| **109** | Conexão do cliente | Conexão do cliente |
| **110** | Divergencia encerrantes sig | DIVERCENCIA DE ENCERRANTES SIGILO |
| **111** | CERTIFICADOS WINDOWNS | VERIFICAR CERTIFICADOS CLIENTES |
| **112** | VERSÃO DTCSYNC | CONSULTA VERSÃO DTCSYNC |

## Formatos de Log Suportados

### 1. Formato com Pipe (|)
```
Data Hora | Nível | Tipo | ThreadID | INFO(107)] Mensagem
28/08/2025 08:24:48 | INFO | INFO | 18832 | INFO(107)] Atualizando data e hora do cliente
```

### 2. Formato com Hífen (-)
```
Data Hora - Nível - Tipo - ThreadID - INFO(107)] Mensagem
28/08/2025 08:24:48 - INFO - INFO - 18832 - INFO(107)] Atualizando data e hora do cliente
```

### 3. Formato Simples
```
Data Hora INFO(107)] Mensagem
28/08/2025 08:24:48 INFO(107)] Atualizando data e hora do cliente
```

## Processamento de Mensagens

### Exemplo de Processamento:
**Mensagem Original:**
```
INFO(107)] Atualizando data e hora do cliente via API
```

**Resultado no Grid:**
- **Data**: 28/08/2025
- **Hora**: 08:24:48
- **Nível**: INFO
- **Tipo**: ATUALIZA DATA E HORA - ATUALIZA DATA E HORA DO CLIENTE VIA API
- **Mensagem**: Atualizando data e hora do cliente via API

## Como Adicionar Novos Códigos

Para adicionar novos códigos à legenda, edite a função `ObterNomeTipoPorCodigo` no arquivo `UntLogs.pas`:

```pascal
function TFrmLogs.ObterNomeTipoPorCodigo(const Codigo: string): string;
begin
  case Codigo of
    '1': Result := 'LOGS(SISTEMA) - GERENCIAMENTO DE LOGS';
    '101': Result := 'PRODUÇÃO - ERRO PRODUÇÃO';
    // ... outros códigos existentes ...
    '113': Result := 'NOVO TIPO - DESCRIÇÃO DO NOVO TIPO'; // Adicionar aqui
    else
      Result := 'TIPO DESCONHECIDO (' + Codigo + ')';
  end;
end;
```

## Funcionalidades Mantidas

### 1. Visualização de Logs
- ✅ Logs atuais (raiz do aplicativo)
- ✅ Logs históricos (pasta `logs/`)
- ✅ Suporte para arquivos `.txt` e `.log`

### 2. Controles de Atualização
- ✅ Atualização automática configurável
- ✅ Intervalo personalizável (1-3600 segundos)
- ✅ Limite de registros (1-10.000)

### 3. Navegação
- ✅ Botões de navegação (Primeiro, Anterior, Próximo, Último)
- ✅ Seleção de linha para ver mensagem completa
- ✅ Atualização manual

### 4. Log Manual
- ✅ Adição de entradas manuais
- ✅ Formato padronizado com código 1 (LOGS(SISTEMA))

## Interface Atualizada

### Colunas do Grid:
1. **Data**: Data do log
2. **Hora**: Hora do log
3. **Nível**: Nível do log (INFO, ERROR, DEBUG, etc.)
4. **Tipo**: Nome descritivo baseado no código extraído
5. **Mensagem**: Mensagem limpa (sem prefixo INFO(código))

### Exemplo de Exibição:
```
Data        | Hora     | Nível | Tipo                                    | Mensagem
28/08/2025  | 08:24:48 | INFO  | ATUALIZA DATA E HORA - ATUALIZA DATA... | Atualizando data e hora do cliente via API
28/08/2025  | 08:25:12 | INFO  | CNPJ - VALIDAÇÃO CNPJ                  | Validando CNPJ do cliente
28/08/2025  | 08:25:45 | ERROR | PRODUÇÃO - ERRO PRODUÇÃO               | Erro na conexão com banco de dados
```

## Vantagens da Nova Implementação

### 1. **Organização Automática**
- Códigos são automaticamente convertidos para nomes descritivos
- Facilita a identificação do tipo de log

### 2. **Interface Limpa**
- Mensagens sem prefixos desnecessários
- Colunas organizadas de forma lógica

### 3. **Escalabilidade**
- Fácil adição de novos códigos na legenda
- Sistema preparado para expansão

### 4. **Compatibilidade**
- Mantém compatibilidade com formatos existentes
- Processa automaticamente diferentes padrões

## Troubleshooting

### Problemas Comuns:

1. **Código não reconhecido**
   - Verifique se o código está na legenda
   - Adicione o código na função `ObterNomeTipoPorCodigo`

2. **Mensagem não processada corretamente**
   - Verifique se o formato é `INFO(código)] mensagem`
   - Certifique-se de que o parêntese está fechado

3. **Tipo aparece como "DESCONHECIDO"**
   - O código não está na legenda
   - Adicione o código correspondente

## Exemplos de Uso

### Log Manual:
```
28/08/2025 10:30:00 - INFO - INFO(1)] Teste de log manual
```

### Log de Sistema:
```
28/08/2025 10:30:15 - INFO - INFO(107)] Atualizando configurações do cliente
28/08/2025 10:30:20 - ERROR - INFO(101)] Erro na validação de dados
28/08/2025 10:30:25 - INFO - INFO(102)] Validando CNPJ: 12.345.678/0001-90
```

---

*Versão: 2.0 | Data: 28/08/2025 | Atualização: Sistema de códigos de tipo integrado* 