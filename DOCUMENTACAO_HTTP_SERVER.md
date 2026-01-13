# Documentação do Servidor HTTP - Dtc_Atualizador_Server

## Visão Geral

O servidor HTTP foi implementado para expor APIs REST que permitem acesso às configurações do banco de dados e atualização de dados de empresas. O servidor roda na porta ***** e utiliza autenticação básica HTTP.

## Arquitetura

### Componentes Utilizados
- **TIdHTTPServer**: Servidor HTTP da biblioteca Indy
- **TIdContext**: Contexto da requisição HTTP
- **TIdHTTPRequestInfo**: Informações da requisição recebida
- **TIdHTTPResponseInfo**: Informações da resposta a ser enviada
- **TNetHTTPClient**: Cliente HTTP para chamadas externas

### Configuração do Servidor
- **Porta**: *****
- **Protocolo**: HTTP
- **Autenticação**: Basic HTTP Authentication
- **Inicialização**: Automática no `FormCreate`
- **Finalização**: Automática no `FormDestroy`

### Credenciais de Autenticação
```pascal
const
  API_USERNAME = 'admin';
  API_PASSWORD = '*****';
```

## Endpoints Disponíveis

### 1. GET /api/config/{numeroempresamodulo}

**Descrição**: Retorna todas as configurações da tabela `public.config` filtradas pelo `numeroempresamodulo`.

**Autenticação**: Basic HTTP Authentication

**Parâmetros**:
- `numeroempresamodulo` (path parameter): Número da empresa módulo para filtrar as configurações

**Exemplo de URL**:
```
http://192.168.0.000:*****/api/config/111
```

**Headers de Autenticação**:
```
Authorization: Basic ************************************************
```

**Resposta de Sucesso (200)**:
```json
{
  "success": true,
  "message": "Configurações encontradas com sucesso",
  "data": [
    {
      "id": 1,
      "status": 1,
      "data": "2024-01-01",
      "hora": "10:00:00",
      "enviado": 1,
      "empresa": 111111,
      "ip": "192.168.0.000",
      "port": *****,
      "numeroempresaapi": 111111,
      "virguladecimaltotallitros": 2,
      "virguladecimalprecoporlitro": 2,
      "virguladecimalprecototal": 2,
      "dtcusuario": "usuario",
      "dtcsenha": "*****",
      "apilogin": "http://api.exemplo.com/login",
      "apiabastecimentos": "http://api.exemplo.com/abastecimentos",
      "apitags": "http://api.exemplo.com/tags",
      "apiveiculo": "http://api.exemplo.com/veiculo",
      "apifrentista": "http://api.exemplo.com/frentista",
      "apiultimokm": "http://api.exemplo.com/ultimokm",
      "nomeempresa": "Empresa Exemplo",
      "apideposito": "http://api.exemplo.com/deposito",
      "apiprodutos": "http://api.exemplo.com/produtos",
      "apicompra": "http://api.exemplo.com/compra",
      "apimedidor": "http://api.exemplo.com/medidor",
      "apivinculomotorista": "http://api.exemplo.com/vinculomotorista",
      "portapi": *****,
      "bico_1": "BICO1",
      "bico_2": "BICO2",
      "bico_3": "BICO3",
      "bico_4": "BICO4",
      "bico_5": "BICO5",
      "bico_6": "BICO6",
      "bico_7": "BICO7",
      "bico_8": "BICO8",
      "bico_9": "BICO9",
      "bico_10": "BICO10",
      "ipmedidor": "192.168.0.000",
      "portmedidor": *****,
      "tanquesrenomeid": "TANQUE1",
      "tanquesmedidor": "Medidor Tanque 1",
      "empmedidor": 111,
      "numeroempresamodulo": 111,
      "ipservidor": "192.168.0.000",
      "twc": true,
      "android": false,
      "server": true,
      "cliente": false,
      "sw1": true,
      "sw2": false,
      "sw3": true,
      "sw4": false,
      "sw5": true,
      "sw6": false,
      "sw7": true,
      "sw8": false,
      "sw9": true,
      "sw10": false,
      "swmedidor": true,
      "capacidade": true,
      "horusconnect": false,
      "medidor": true,
      "bancodedados": "postgresql",
      "concetradores2": "concentrador1",
      "motorista": false,
      "vinculo_m_v": true,
      "apibico": "http://api.exemplo.com/bico"
    }
  ],
  "total": 1,
  "numeroempresamodulo": 1111111
}
```

### 2. POST /api/atualizar-empresa

**Descrição**: Atualiza o campo `data_atualizada` na tabela `cadastro_empresas` para a hora atual, apenas se `atualizador_ativo` for `true`.

**Autenticação**: Basic HTTP Authentication

**URL**:
```
http://192.168.0.000:*****/api/atualizar-empresa
```

**Headers**:
```
Content-Type: application/json
Authorization: Basic ************************************************
```

**Corpo da Requisição**:
```json
{
  "id_empresa": 1111111
}
```

**Resposta de Sucesso (200)**:
```json
{
  "success": true,
  "message": "Data atualizada com sucesso",
  "id_empresa": 111111,
  "data_atualizada": "2025-01-13 11:39:58"
}
```

**Resposta de Erro - Empresa não encontrada (200)**:
```json
{
  "success": false,
  "message": "Empresa não encontrada",
  "id_empresa": 999,
  "data_atualizada": ""
}
```

**Resposta de Erro - Atualizador inativo (200)**:
```json
{
  "success": false,
  "message": "Atualizador inativo para esta empresa",
  "id_empresa": 11111111,
  "data_atualizada": ""
}
```

## Funcionalidade do Cliente

### Chamada Automática da API

O sistema cliente automaticamente chama a API `/api/atualizar-empresa` nas seguintes situações:

1. **Ao salvar configurações do cliente** (`BtnSalvarClientClick`)
2. **Timer de atualização** (`Timer2Timer`, `Timer3Timer`)
3. **Timer específico de empresa** (`TimerAtualizaHoraEmpresaTimer`)
4. **Botão manual** (`BitBtn13Click`)

### Configuração do Cliente

O cliente lê o `ID_Client` do arquivo `ConfigServer.ini`:

```ini
[Config]
ID_Client=111
```

### URLs Dinâmicas

O sistema seleciona automaticamente a URL correta baseado no modo:

- **Modo Cliente**: `http://******.ddns.com.br:*****`
- **Modo Servidor**: `http://192.168.0.000:*****`

### Logs do Cliente

```
[API CLIENTE] Enviando requisição para: http://******.ddns.com.br:*****/api/atualizar-empresa
[API CLIENTE] Corpo da requisição: {"id_empresa": 1111111}
[API CLIENTE] Resposta recebida: {"success": true, "message": "Data atualizada com sucesso", "id_empresa": 111, "data_atualizada": "2025-01-13 11:39:58"}
```

## Sistema de Gerenciamento de Logs

### Backup Automático

O sistema monitora o arquivo `Logs.txt` e quando atinge 5MB:

1. **Move** o arquivo atual para `logs\Logs_YYYY-MM-DD_HH-NN-SS.txt`
2. **Cria** um novo arquivo `Logs.txt` vazio
3. **Registra** a ação no log

### Limpeza Automática

O sistema remove automaticamente logs antigos:

- **Frequência**: 1 em cada 100 chamadas de `WriteLogFormatted`
- **Critério**: Arquivos mais antigos que 30 dias
- **Localização**: Pasta `logs\`
- **Padrão**: `Logs_*.txt`

### Logs de Gerenciamento

```
[LOG BACKUP] Arquivo Logs.txt movido para logs\Logs_2025-01-13_11-39-58.txt
[LOG CLEANUP] Removidos 5 arquivos de log antigos (mais de 30 dias)
[LOG CLEANUP] Total de arquivos verificados: 15, arquivos removidos: 5
```

## Implementação Técnica

### Função serverApiDTC

```pascal
function TFrmPrincipal.serverApiDTC(const NumeroEmpresaModuloDTC: Integer): TJSONObject;
```

**Funcionalidades**:
- Conecta ao banco usando `ConexaoModulo`
- Executa query na tabela `public.config`
- Filtra por `numeroempresamodulo`
- Retorna todos os campos da tabela em formato JSON

### Função AtualizarDataEmpresa

```pascal
function TFrmPrincipal.AtualizarDataEmpresa(const IdEmpresa: Integer): TJSONObject;
```

**Funcionalidades**:
- Conecta ao banco usando `ConexaoModulo`
- Busca empresa por `id_empresa_help`
- Verifica se `atualizador_ativo` é `true`
- Atualiza `data_atualizada` para `Now()`
- Retorna resultado em JSON

### Event Handler HTTP

```pascal
procedure TFrmPrincipal.IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
```

**Funcionalidades**:
- Processa requisições GET e POST
- Valida autenticação Basic HTTP
- Extrai parâmetros da URL e corpo da requisição
- Chama funções apropriadas baseado no endpoint
- Formata resposta JSON
- Define headers e status codes

### Função de Autenticação

```pascal
function TFrmPrincipal.ValidarAutenticacaoAPI(const ARequestInfo: TIdHTTPRequestInfo): Boolean;
```

**Funcionalidades**:
- Extrai header `Authorization`
- Decodifica Base64
- Valida username/password
- Retorna `true` se autenticado

## Testando com Postman

### 1. Teste GET /api/config/{numero}

**Configuração**:
- **Método**: GET
- **URL**: `http://192.168.0.000:*****/api/config/1111111`
- **Headers**:
  - `Authorization: Basic ************************************************`

**cURL**:
```bash
curl --location 'http://192.168.0.000:*****/api/config/1111111' \
--header 'Authorization: Basic ************************************************'
```

### 2. Teste POST /api/atualizar-empresa

**Configuração**:
- **Método**: POST
- **URL**: `http://192.168.0.000:*****/api/atualizar-empresa`
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Basic ************************************************`
- **Body** (raw JSON):
```json
{
  "id_empresa": 11111111
}
```

**cURL**:
```bash
curl --location 'http://192.168.0.000:*****/api/atualizar-empresa' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic ************************************************' \
--data '{
  "id_empresa": 11111111
}'
```

## Estrutura das Tabelas

### Tabela public.config

A função consulta a tabela `public.config` que contém todos os campos de configuração do sistema.

### Tabela cadastro_empresas

A função POST atualiza a tabela `cadastro_empresas`:

```sql
CREATE TABLE "cadastro_empresas" (
  "id_empresa" INTEGER NOT NULL,
  "id_empresa_help" INTEGER NOT NULL,
  "nome_empresa" VARCHAR(150) NOT NULL,
  "cnpj" VARCHAR(14) NOT NULL,
  "id_cidade" INTEGER NOT NULL,
  "atualizador_ativo" BOOLEAN NULL DEFAULT true,
  "ativo" BOOLEAN NULL DEFAULT true,
  "data_atualizada" TIMESTAMP NOT NULL DEFAULT '2024-12-31 23:00:00',
  -- outros campos...
  PRIMARY KEY ("id_empresa"),
  UNIQUE ("id_empresa_help")
);
```

## Segurança

### Autenticação
- **Tipo**: Basic HTTP Authentication
- **Usuário**: admin
- **Senha**: ***** (MD5)

### Recomendações
- Implementar HTTPS para produção
- Adicionar rate limiting
- Implementar validação de entrada mais robusta
- Configurar firewall para restringir acesso

## Troubleshooting

### Problemas Comuns

1. **Erro 401 Unauthorized**:
   - Verificar se o header `Authorization` está correto
   - Verificar se as credenciais estão corretas

2. **Erro de conexão**:
   - Verificar se o servidor está rodando na porta configurada
   - Verificar se o firewall permite conexões

3. **Erro de banco de dados**:
   - Verificar se `ConexaoModulo` está conectado
   - Verificar se as tabelas existem

4. **JSON inválido**:
   - Verificar se o Content-Type está correto
   - Verificar se o JSON está bem formatado

### Logs de Debug

Todos os erros são logados com prefixos específicos:
- `[HTTP SERVER]` - Logs do servidor HTTP
- `[AUTH]` - Logs de autenticação
- `[API CLIENTE]` - Logs das chamadas do cliente
- `[LOG BACKUP]` - Logs de backup de arquivos
- `[LOG CLEANUP]` - Logs de limpeza de arquivos

## Conclusão

O servidor HTTP foi implementado de forma robusta e segura, incluindo autenticação básica, múltiplos endpoints, funcionalidade cliente automática e sistema de gerenciamento de logs. A implementação permite acesso fácil às configurações e atualização de dados através de APIs REST padronizadas. 