# 📋 DTC Atualizador Server - Sistema de Sincronização e Integração

## 🎯 Visão Geral

O **DTC Atualizador Server** é um sistema completo desenvolvido em Delphi/Pascal que atua como um **hub centralizado** para sincronização de dados, gerenciamento de configurações e integração entre múltiplos bancos de dados e sistemas externos. O sistema opera em dois modos principais: **Servidor** e **Cliente**, permitindo uma arquitetura distribuída com comunicação via API REST.

---

## 🏗️ Arquitetura do Sistema

### **Componentes Principais**

```
┌─────────────────────────────────────────────────────────────┐
│              DTC ATUALIZADOR SERVER                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   MODO       │         │   MODO        │                 │
│  │  SERVIDOR    │◄───────►│  CLIENTE      │                 │
│  └──────┬───────┘         └──────┬───────┘                  │
│         │                        │                          │
│         ▼                        ▼                          │
│  ┌──────────────────────────────────────────┐               │
│  │      SERVIDOR HTTP (Porta 44**)          │               │
│  │      API REST com Autenticação Basic     │               │
│  └──────────────────────────────────────────┘               │
│         │                        │                          │
│         ▼                        ▼                          │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │ Banco Server │         │ Banco Cliente│                  │
│  │ (PostgreSQL) │         │ (PostgreSQL) │                  │
│  └──────────────┘         └──────────────┘                  │
│                                                             │
│  ┌──────────────────────────────────────────┐               │
│  │     INTEGRAÇÕES EXTERNAS                 │               │
│  │  - Integração Estrada (API Externa)      │               │
│  │  - Integração Entregas (JSON)            │               │
│  │  - Integração Ararajuba                  │               │
│  └──────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Modos de Operação

### **1. Modo Servidor**

O sistema em modo **Servidor** atua como o **núcleo central** do sistema:

#### **Funcionalidades:**
- ✅ **Servidor HTTP REST** na porta **44******
- ✅ **Sincronização de Relatórios** (código >= 450) do servidor para clientes
- ✅ **Gerenciamento de Configurações** via API
- ✅ **Monitoramento de Ocorrências** em múltiplos bancos
- ✅ **Processamento de Integrações** externas
- ✅ **Geração de arquivos JSON** para integrações

#### **Conexões:**
- **CXServer**: Conexão com banco de dados do servidor
- **ConexaoModulo**: Conexão com banco de módulos/configurações
- **CXClient**: Conexão com banco de dados do cliente (quando necessário)

#### **Threads Específicas:**
- `TTransferenciaServerThread`: Sincroniza relatórios do servidor para clientes
- `ThreadMonitordeOcorrenciaSERVER`: Monitora ocorrências no servidor

---

### **2. Modo Cliente**

O sistema em modo **Cliente** atua como um **nó remoto** que se conecta ao servidor:

#### **Funcionalidades:**
- ✅ **Recepção de Relatórios** sincronizados do servidor (código >= 500)
- ✅ **Envio de Notificações** para o servidor via API
- ✅ **Monitoramento Local** de ocorrências
- ✅ **Atualização Automática** de data de sincronização

#### **Conexões:**
- **CXClient**: Conexão com banco de dados local do cliente
- **ConexaoModulo**: Conexão com banco de módulos (via servidor)

#### **Threads Específicas:**
- `TTransferenciaThread`: Recebe e sincroniza relatórios do servidor
- `ThreadMonitordeOcorrencia`: Monitora ocorrências no cliente

#### **Configuração:**
O cliente lê sua identificação do arquivo `ConfigServer.ini`:
```ini
[Config]
ID_Client=111111
```

---

## 🌐 Comunicação Cliente-Servidor via API

### **Servidor HTTP REST**

O servidor expõe uma **API REST** na porta **44****** com autenticação Basic HTTP.

#### **Credenciais de Autenticação:**
```pascal
API_USERNAME = 'admin'
API_PASSWORD = '**************' (MD5)
```

#### **URLs Dinâmicas:**
O sistema seleciona automaticamente a URL baseado no modo:
- **Modo Cliente**: `http://******.ddns.com.br:44****`
- **Modo Servidor**: `http://192.168.0.000:44**`

---

### **Endpoints Disponíveis**

#### **1. GET /api/config/{numeroempresamodulo}**

**Descrição**: Retorna todas as configurações da tabela `public.config` filtradas pelo número da empresa módulo.

**Exemplo de Requisição:**
```http
GET http://192.168.0.000:44****/api/config/111111
Authorization: Basic ******************************************(MD5)
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "message": "Configurações encontradas com sucesso",
  "data": [
    {
      "id": 1,
      "numeroempresamodulo": 111111,
      "ip": "192.168.0.000",
      "port": 3306,
      "nomeempresa": "Empresa Exemplo",
      "apilogin": "http://api.exemplo.com/login",
      "apiabastecimentos": "http://api.exemplo.com/abastecimentos",
      // ... outros campos de configuração
    }
  ],
  "total": 1,
  "numeroempresamodulo": 111111
}
```

---

#### **2. POST /api/atualizar-empresa**

**Descrição**: Atualiza o campo `data_atualizada` na tabela `cadastro_empresas` para a hora atual, apenas se `atualizador_ativo` for `true`.

**Exemplo de Requisição:**
```http
POST http://dtcmonitor.ddns.com.br:4450/api/atualizar-empresa
Content-Type: application/json
Authorization: Basic ************************************************(MD5)

{
  "id_empresa": 111111
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "message": "Data atualizada com sucesso",
  "id_empresa": 111111,
  "data_atualizada": "2025-01-13 11:39:58"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "message": "Atualizador inativo para esta empresa",
  "id_empresa": 111111,
  "data_atualizada": ""
}
```

---

### **Chamadas Automáticas do Cliente**

O sistema cliente **automaticamente** chama a API `/api/atualizar-empresa` nas seguintes situações:

1. **Ao salvar configurações** (`BtnSalvarClientClick`)
2. **Timer de atualização periódica** (`Timer2Timer`, `Timer3Timer`)
3. **Timer específico de empresa** (`TimerAtualizaHoraEmpresaTimer`)
4. **Botão manual de atualização** (`BitBtn13Click`)

**Exemplo de Log:**
```
[API CLIENTE] Enviando requisição para: http://`***********`.ddns.com.br:44`**`/api/atualizar-empresa
[API CLIENTE] Corpo da requisição: {"id_empresa": 111111}
[API CLIENTE] Resposta recebida: {"success": true, "message": "Data atualizada com sucesso", ...}
```

---

## 🔄 Sincronização de Relatórios

### **Fluxo de Sincronização**

```
┌─────────────────────────────────────────────────────────────┐
│              SINCRONIZAÇÃO DE RELATÓRIOS                    │
└─────────────────────────────────────────────────────────────┘

SERVIDOR                                    CLIENTE
    │                                          │
    │ 1. Busca relatórios (cod >= 450)         │
    │    na tabela relatorios                  │
    │                                          │
    │ 2. Compara com destino                   │
    │    - Se não existe: INSERE               │
    │    - Se existe e diferente: ATUALIZA     │
    │    - Se não existe na origem: EXCLUI     │
    │                                          │
    │ 3. Transação atômica                     │
    │    - Commit em caso de sucesso           │
    │    - Rollback em caso de erro            │
    │                                          │
    │ 4. Logs detalhados                       │
    │                                          │
    └──────────────────────────────────────────┘
```

### **Diferenças entre Modos**

| Aspecto | Servidor | Cliente |
|---------|----------|---------|
| **Código Inicial** | `cod_relatorio >= 450` | `cod_relatorio >= 500` |
| **Direção** | Servidor → Cliente | Servidor → Cliente |
| **Thread** | `TTransferenciaServerThread` | `TTransferenciaThread` |
| **Origem** | Banco do Servidor | Banco do Servidor |
| **Destino** | Banco do Cliente | Banco do Cliente |

### **Campos Sincronizados**

- `cod_relatorio`
- `categoria`
- `subcategoria`
- `descricao`
- `relatorio` (código SQL)
- `exibir`
- `nome`
- `uso_interno`
- `relatorio_pai`
- `relatorio_sistema`
- `data_inclusao`
- `data_alteracao`

---

## 🔌 Integrações Externas

### **1. Integração Estrada**

**Objetivo**: Sincronizar classes de clientes e enviar notificações por email.

#### **Fluxo:**
1. **Login na API Externa** (`FazerLogin`)
2. **Buscar Clientes** com paginação (`BuscarClientesComPaginacao`)
3. **Verificar e Atualizar Classe** (`VerificarEAtualizarClasse`)
4. **Armazenar Clientes Atualizados** em memória (`ArmazenarClienteAtualizado`)
5. **Enviar Email em Lote** (`EnviarEmailEmLote`)

#### **Características:**
- ✅ **Email Consolidado**: Um único email com todos os clientes atualizados
- ✅ **HTML Responsivo**: Email formatado com CSS moderno
- ✅ **Configuração SMTP Dinâmica**: Busca configurações no banco de dados
- ✅ **Processamento em Lote**: Acumula atualizações antes de enviar

#### **Estrutura do Email:**
```html
- Header com título
- Resumo do processamento (data/hora, total de clientes)
- Tabela formatada com CPF, Nome e Status
- Footer com assinatura
```

---

### **2. Integração Entregas**

**Objetivo**: Gerar arquivo JSON (`entregas.json`) com vendas processadas para integração externa.

#### **Fluxo:**
1. **Buscar Vendas** do último mês (30 dias)
2. **Filtrar** apenas vendas não processadas (`cash_back_lanc IS NOT TRUE`)
3. **Agrupar** produtos por `cod_lanc_financeiro`
4. **Gerar JSON** formatado
5. **Marcar como processado** (`cash_back_lanc = TRUE`)

#### **Estrutura do JSON:**
```json
{
  "vendas": [
    {
      "cod_lanc_financeiro": 123,
      "chave_acesso": "chave123",
      "valor": 100.50,
      "numero_documento": "DOC001",
      "data_inclusao": "2024-01-15 14:30:45",
      "pessoa": {
        "cod_pessoa": 456,
        "nome": "Nome da Pessoa",
        "identificacao": "12345678900",
        "endereco": "Rua Exemplo",
        // ... outros campos
      },
      "produtos": [
        {
          "cod_produto": 789,
          "nome": "Nome do Produto",
          "valor": 10.50,
          "quantidade": 5.0,
          "cod_barra": "7891234567890"
        }
      ]
    }
  ]
}
```

#### **Localização:**
- **Arquivo**: `entregas.json`
- **Pasta**: Raiz do executável

---

### **3. Integração Ararajuba**

**Objetivo**: Integração específica com sistema Ararajuba (detalhes no código).

---

## 📊 Monitoramento de Ocorrências

### **Threads de Monitoramento**

#### **Servidor: `ThreadMonitordeOcorrenciaSERVER`**
- Monitora múltiplos bancos de clientes
- Verifica divergências e problemas
- Insere ocorrências na tabela de monitoramento

#### **Cliente: `ThreadMonitordeOcorrencia`**
- Monitora banco local do cliente
- Verifica certificados, hardware, NFe, etc.
- Envia informações para o servidor via API

### **Funcionalidades Monitoradas:**
- ✅ Documentos fiscais em aberto
- ✅ Divergências de NFe/NFce
- ✅ Erros de produção
- ✅ Divergências de encerrantes
- ✅ Validação de certificados
- ✅ Validação de CNPJ
- ✅ Informações de hardware
- ✅ Replicas de lojas

---

## 📝 Sistema de Logs

### **Gerenciamento Automático**

#### **Backup Automático:**
- **Trigger**: Quando `Logs.txt` atinge **5MB**
- **Ação**: Move para `logs\Logs_YYYY-MM-DD_HH-NN-SS.txt`
- **Resultado**: Cria novo arquivo `Logs.txt` vazio

#### **Limpeza Automática:**
- **Frequência**: 1 em cada 100 chamadas de `WriteLogFormatted`
- **Critério**: Arquivos mais antigos que **30 dias**
- **Localização**: Pasta `logs\`
- **Padrão**: `Logs_*.txt`

### **Formato de Logs:**
```
[INFO] [CÓDIGO] [CONTEXTO] Mensagem de log
[ERRO] [CÓDIGO] [CONTEXTO] Mensagem de erro
[DEBUG] [CÓDIGO] [CONTEXTO] Mensagem de debug
```

### **Exemplos:**
```
[INFO] [106] [API CLIENTE] Enviando requisição para: http://**********.ddns.com.br:44**/api/atualizar-empresa
[INFO] [122] [TRANSFERENCIA SERVER] Transferência concluída com sucesso! Total de registros: 45
[ERRO] [108] [INTEGRACAO ESTRADA] Erro ao conectar na API externa: Connection timeout
[LOG BACKUP] Arquivo Logs.txt movido para logs\Logs_2025-01-13_11-39-58.txt
[LOG CLEANUP] Removidos 5 arquivos de log antigos (mais de 30 dias)
```

---

## ⚙️ Configuração do Sistema

### **Arquivos de Configuração**

#### **1. ConfigServer.ini**
```ini
[Config]
ID_Client=111111
```

#### **2. ConfigServer.ini (Servidor)**
```ini
[Config]
IP_Servidor=192.168`*******`
Porta_Servidor=44`**`
```

### **Tabelas do Banco de Dados**

#### **public.config**
Armazena todas as configurações do sistema por empresa:
- Configurações de conexão (IP, porta, usuário, senha)
- URLs de APIs externas
- Configurações de bicos, tanques, medidores
- Flags de funcionalidades (sw1, sw2, sw3, etc.)

#### **cadastro_empresas**
Armazena informações das empresas:
- `id_empresa`: ID único
- `id_empresa_help`: ID para integração
- `nome_empresa`: Nome da empresa
- `cnpj`: CNPJ da empresa
- `atualizador_ativo`: Flag para habilitar/desabilitar atualizador
- `data_atualizada`: Última data de atualização

#### **relatorios**
Armazena os relatórios sincronizados:
- `cod_relatorio`: Código único do relatório
- `categoria`, `subcategoria`: Classificação
- `descricao`: Descrição do relatório
- `relatorio`: Código SQL do relatório
- `exibir`: Flag de exibição
- `nome`: Nome do relatório
- `uso_interno`: Flag de uso interno
- `relatorio_pai`: Relatório pai (hierarquia)
- `relatorio_sistema`: Flag de relatório do sistema
- `data_inclusao`, `data_alteracao`: Datas de controle

---

## 🚀 Execução e Timers

### **Timers Principais**

#### **TimerRelatoriosServerExe**
- **Função**: Executa sincronização de relatórios no servidor
- **Horários**: Configuráveis por turno

#### **TimerRelatoriosClientExe**
- **Função**: Executa sincronização de relatórios no cliente
- **Horários**: Configuráveis por turno

#### **TimerIntegracaoHoraMarcada**
- **Função**: Executa integrações externas em horário específico
- **Horário Padrão**: 15:30

#### **TimerMonitor**
- **Função**: Executa monitoramento de ocorrências
- **Frequência**: Configurável

#### **Timer2, Timer3**
- **Função**: Atualização periódica de dados
- **Ação**: Chama API `/api/atualizar-empresa`

---

## 🔒 Segurança

### **Autenticação API**
- **Tipo**: Basic HTTP Authentication
- **Usuário**: `admin`
- **Senha**: `***********` (MD5)


---

## 📦 Estrutura de Arquivos

```
Dtc_Atualizador_Server/
├── Dtc_Atualizador_Server.dpr          # Arquivo principal do projeto
├── UntPrincipal.pas                    # Formulário principal
├── uTransferenciaThread.pas            # Thread de transferência (Cliente)
├── uTransferenciaServerThread.pas      # Thread de transferência (Servidor)
├── UntConexaoCliente.pas              # Conexão com banco cliente
├── uThreadmonitorDeOcorrencia.pas     # Monitor de ocorrências (Cliente)
├── uThreadmonitorDeOcorrenciaSERVER.pas # Monitor de ocorrências (Servidor)
├── DOCUMENTACAO_HTTP_SERVER.md        # Documentação da API
├── DOCUMENTACAO_INTEGRACAO_ESTRADA.md  # Documentação integração Estrada
├── DOCUMENTACAO_INTEGRACAO_ENTREGAS.md # Documentação integração Entregas
├── README.md                           # Este arquivo
└── Win32/
    └── Debug/
        ├── Dtc_Atualizador_Server.exe  # Executável
        ├── ConfigServer.ini            # Configurações
        ├── Logs.txt                    # Logs do sistema
        └── logs/                       # Pasta de backups de logs
```

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem**: Delphi/Pascal
- **Banco de Dados**: PostgreSQL, MySQL
- **Bibliotecas**:
  - **UniDAC**: Acesso a dados
  - **Indy**: Servidor HTTP, SMTP, FTP
  - **FireDAC**: Acesso a dados alternativo
  - **System.Net.HttpClient**: Cliente HTTP
  - **System.JSON**: Manipulação de JSON

---

## 📞 Suporte e Troubleshooting

### **Problemas Comuns**

#### **1. Erro 401 Unauthorized na API**
- Verificar se o header `Authorization` está correto
- Verificar se as credenciais estão corretas
- Verificar se o servidor está rodando na porta 4450

#### **2. Erro de Conexão com Banco**
- Verificar se o banco está acessível
- Verificar credenciais de conexão
- Verificar se o firewall permite conexões

#### **3. Sincronização Não Funciona**
- Verificar se as conexões estão ativas
- Verificar logs para identificar erros
- Verificar se os códigos de relatórios estão corretos (>= 450 servidor, >= 500 cliente)

#### **4. Email Não Está Sendo Enviado**
- Verificar configurações SMTP no banco de dados
- Verificar se `enviar_email_notificacao` está `true`
- Verificar logs para identificar erros
- Testar conexão SMTP manualmente

---

## 📈 Métricas e Performance

### **Sincronização de Relatórios**
- **Tempo médio**: ~2-5 segundos para 100 relatórios
- **Transações**: Atômicas (commit/rollback)
- **Logs**: Detalhados para cada operação

### **API REST**
- **Latência**: < 100ms para requisições locais
- **Throughput**: Suporta múltiplas requisições simultâneas
- **Autenticação**: Validada em cada requisição

### **Integrações**
- **Estrada**: ~5-10 segundos por ciclo completo
- **Entregas**: ~2-3 segundos para gerar JSON
- **Email**: ~2-5 segundos para envio

---

## 🔄 Fluxo Completo do Sistema

```
┌─────────────────────────────────────────────────────────────┐
│              FLUXO COMPLETO DO SISTEMA                     │
└─────────────────────────────────────────────────────────────┘

1. INICIALIZAÇÃO
   ├─ Carrega configurações
   ├─ Conecta aos bancos de dados
   ├─ Inicia servidor HTTP (modo servidor)
   └─ Inicia timers

2. MODO SERVIDOR
   ├─ Servidor HTTP ativo (porta 4450)
   ├─ Aguarda requisições de clientes
   ├─ Sincroniza relatórios para clientes
   ├─ Monitora ocorrências
   └─ Processa integrações externas

3. MODO CLIENTE
   ├─ Conecta ao servidor via API
   ├─ Recebe relatórios sincronizados
   ├─ Envia notificações de atualização
   ├─ Monitora ocorrências locais
   └─ Atualiza data de sincronização

4. INTEGRAÇÕES
   ├─ Integração Estrada (API externa)
   ├─ Integração Entregas (JSON)
   └─ Integração Ararajuba

5. MONITORAMENTO
   ├─ Verifica ocorrências
   ├─ Gera logs
   └─ Envia notificações

6. MANUTENÇÃO
   ├─ Backup de logs
   ├─ Limpeza de logs antigos
   └─ Atualização de configurações
```

---

## 📚 Documentação Adicional

- **[DOCUMENTACAO_HTTP_SERVER.md](DOCUMENTACAO_HTTP_SERVER.md)**: Documentação completa da API REST
- **[DOCUMENTACAO_INTEGRACAO_ESTRADA.md](DOCUMENTACAO_INTEGRACAO_ESTRADA.md)**: Documentação da integração Estrada
- **[DOCUMENTACAO_INTEGRACAO_ENTREGAS.md](DOCUMENTACAO_INTEGRACAO_ENTREGAS.md)**: Documentação da integração Entregas
- **[FLUXO_INTEGRACAO_ESTRADA.md](FLUXO_INTEGRACAO_ESTRADA.md)**: Fluxograma da integração Estrada

---

## 📝 Licença

Este sistema é proprietário da Datacom Automações.

---

## 👥 Desenvolvido por

**Douglas Francisco Bonfim**

---

**Última atualização**: Janeiro 2025  
**Versão do Sistema**: 1.0
