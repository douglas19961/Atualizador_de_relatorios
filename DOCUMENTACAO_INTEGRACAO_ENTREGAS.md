# 📦 DOCUMENTAÇÃO - INTEGRAÇÃO DE ENTREGAS (VENDASPIT)

## 🎯 **Visão Geral**

A integração de entregas (Vendas PIT) é um módulo que gera um arquivo JSON (`entregas.json`) contendo informações de vendas processadas, agrupadas por lançamento financeiro. O sistema processa vendas dos últimos 7 dias que atendem aos critérios (PDV, não processadas internamente) e gera um arquivo JSON formatado para integração com sistemas externos.

---

## 📋 **Funcionalidades Principais**

### **1. Processamento de Vendas**
- Busca vendas dos últimos **7 dias** (configurável no código)
- Filtra vendas não processadas internamente (`vendas_pit_interno IS NOT TRUE`)
- Filtra apenas vendas do PDV (`vendas_pit_pdv = true`)
- Filtra lançamentos de produtos do tipo venda (`lp.tipo_lancamento = 'V'`)
- Filtra lançamentos com situação aprovada (`lf.situacao = 2`) e não cancelados (`lp.cancelado = false`)
- Agrupa produtos por `cod_lanc_financeiro`
- Marca vendas como processadas após gerar o JSON (`vendas_pit_interno = TRUE`)

### **2. Configuração do Caminho do Arquivo**
- Caminho obtido da tabela `integracao.IntegracaoTXt` com `tipo_integracao = 'VENDASPIT'`
- Se não existir registro, usa pasta raiz do executável + `entregas.json`
- Se a tabela não existir, é criada automaticamente com o schema `integracao`

### **3. Geração do Arquivo JSON**
- Arquivo: `entregas.json` (ou caminho configurado no banco)
- Formato: JSON formatado com indentação (legível)
- Estrutura: Hierárquica com vendas, pessoas e produtos

### **4. Persistência de Dados**
- Carrega arquivo JSON existente (se houver)
- Adiciona novas vendas ao final do array
- Mantém histórico de todas as vendas processadas

---

## 🏗️ **Estrutura do JSON Gerado**

```json
{
  "vendas": [
    {
      "cod_lanc_financeiro": 123,
      "estabelecimento": "12345678000199",
      "chave_acesso": "chave123",
      "valor": 100.50,
      "numero_documento": "DOC001",
      "data_inclusao": "2024-01-15 14:30:45",
      "data_entrega": "2024-01-15 14:35:00",
      "prioridade": 1,
      "id_forma_de_pagamento": 1,
      "descricao_forma_de_pagamento": "Dinheiro",
      "valor_a_receber": "100.50",
      "pessoa": {
        "cod_pessoa": 456,
        "nome": "Nome da Pessoa",
        "identificacao": "12345678900",
        "endereco": "Rua Exemplo",
        "numero": "123",
        "uf": "SP",
        "cep": "12345-678",
        "telefone_comercial": "11999999999",
        "telefone_residencial": "11888888888",
        "nome_cidade": "São Paulo"
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

---

## 📊 **Campos do JSON**

### **Nível Venda (Raiz do Objeto)**
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `cod_lanc_financeiro` | Number | Código único do lançamento financeiro |
| `estabelecimento` | String | CNPJ do estabelecimento (empresa) |
| `chave_acesso` | String | Chave de acesso da nota fiscal |
| `valor` | Number | Valor total do lançamento financeiro |
| `numero_documento` | String | Número do documento fiscal |
| `data_inclusao` | String | Data e hora de inclusão (formato: `yyyy-mm-dd hh:nn:ss`) |
| `data_entrega` | String | Data/hora PIT para entrega (`vendas_pit_data` + `vendas_pit_hora`) |
| `prioridade` | Number | Prioridade da entrega (primeiro caractere de `vendas_pit_prioridade`) |
| `id_forma_de_pagamento` | Number | ID da forma de pagamento |
| `descricao_forma_de_pagamento` | String | Descrição da forma de pagamento |
| `valor_a_receber` | String | Valor a receber (`vendas_pit_valor_areceber`) |

### **Objeto Pessoa**
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `cod_pessoa` | Number | Código único da pessoa/cliente |
| `nome` | String | Nome completo da pessoa |
| `identificacao` | String | CPF/CNPJ da pessoa |
| `endereco` | String | Logradouro do endereço |
| `numero` | String | Número do endereço |
| `uf` | String | Unidade Federativa (estado) |
| `cep` | String | CEP do endereço |
| `telefone_comercial` | String | Telefone comercial |
| `telefone_residencial` | String | Telefone residencial |
| `nome_cidade` | String | Nome da cidade (do município) |

### **Array Produtos**
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `cod_produto` | Number | Código único do produto |
| `nome` | String | Nome do produto |
| `valor` | Number | Valor unitário do produto |
| `quantidade` | Number | Quantidade vendida |
| `cod_barra` | String | Código de barras do produto |

---

## 🗄️ **Tabela integracao.IntegracaoTXt**

Armazena a configuração do caminho do arquivo por tipo de integração.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL | Chave primária |
| `tipo_integracao` | VARCHAR(50) | Tipo da integração (ex: `VENDASPIT`) |
| `caminho_arquivo` | VARCHAR(500) | Caminho completo do arquivo |
| `ativo` | BOOLEAN | Se a integração está ativa (default: true) |
| `data_criacao` | TIMESTAMP | Data de criação |
| `data_atualizacao` | TIMESTAMP | Data de atualização |

### **Registro para VENDASPIT**
```sql
INSERT INTO integracao.IntegracaoTXt (tipo_integracao, caminho_arquivo)
SELECT 'VENDASPIT', 'C:\Program Files\Datacom\DtcSync\entregas.json'
WHERE NOT EXISTS (SELECT 1 FROM integracao.IntegracaoTXt WHERE tipo_integracao = 'VENDASPIT');
```

---

## 🔧 **Query SQL Utilizada**

```sql
SELECT 
  emp.identificacao,
  lf.cod_lanc_financeiro, 
  lf.chave_acesso, 
  lf.cod_pessoa, 
  lf.valor AS valor_lancamento, 
  lf.numero_documento, 
  lf.data_inclusao, 
  lp.valor AS valor_produto, 
  lp.quantidade, 
  lp.cod_produto, 
  COALESCE(TO_CHAR(lf.vendas_pit_data, 'YYYY-MM-DD') || ' ' || lf.vendas_pit_hora, '0000-00-00 00:00:00') AS data_hora_pit,
  LEFT(COALESCE(lf.vendas_pit_prioridade, '0'), 1) AS prioridade,
  LEFT(COALESCE(lf.vendas_pit_forma_pgto, '0'), 1) AS id_forma_de_pagamento,
  SUBSTRING(COALESCE(lf.vendas_pit_forma_pgto, '1') FROM 5) AS descricao_forma_de_pagamento,
  COALESCE(lf.vendas_pit_valor_areceber, 0) AS valor_a_receber,
  p.nome AS nome_produto, 
  p.cod_barra, 
  pe.nome AS nome_pessoa, 
  pe.identificacao, 
  pe.endereco, 
  pe.numero, 
  pe.uf, 
  pe.cep, 
  pe.telefone_comercial, 
  pe.telefone_residencial, 
  m.nome AS nome_cidade 
FROM lancamentos_financeiros lf 
INNER JOIN lancamentos_produtos lp ON lp.cod_lanc_financeiro = lf.cod_lanc_financeiro 
INNER JOIN produtos p ON p.cod_produto = lp.cod_produto 
INNER JOIN pessoas pe ON pe.cod_pessoa = lf.cod_pessoa 
INNER JOIN pessoas emp ON emp.cod_pessoa = lf.cod_empresa 
LEFT JOIN municipios m ON pe.cidade = m.cod_municipio 
WHERE lf.vendas_pit_interno IS NOT TRUE 
  AND vendas_pit_pdv = true
  AND date(lf.data_inclusao) BETWEEN :data_inicio AND :data_fim 
  AND lf.situacao = 2 
  AND lp.cancelado = false 
  AND lp.tipo_lancamento = 'V'
ORDER BY lf.cod_lanc_financeiro, lp.cod_produto
```

### **Filtros Aplicados**
- `lf.vendas_pit_interno IS NOT TRUE`: Apenas vendas não processadas internamente
- `vendas_pit_pdv = true`: Apenas vendas do PDV
- `date(lf.data_inclusao) BETWEEN :data_inicio AND :data_fim`: Últimos 7 dias
- `lf.situacao = 2`: Lançamento aprovado
- `lp.cancelado = false`: Produto não cancelado
- `lp.tipo_lancamento = 'V'`: Apenas lançamentos de venda

---

## 🔄 **Fluxo de Processamento**

```
┌─────────────────────────────────────────────────────────────┐
│         INTEGRAÇÃO DE ENTREGAS (integracaoentregapegoraro)  │
└─────────────────────────────────────────────────────────────┘

1. INICIALIZAÇÃO
   ├─ Define período: 7 dias atrás até hoje
   ├─ Busca caminho em integracao.IntegracaoTXt (tipo VENDASPIT)
   ├─ Se tabela não existir: cria schema, tabela e insere registro padrão
   └─ Carrega JSON existente (se houver)

2. CONEXÃO COM BANCO
   ├─ Conecta com CXClient
   └─ Executa query SQL

3. PROCESSAMENTO
   ├─ Para cada registro retornado:
   │  ├─ Se novo cod_lanc_financeiro:
   │  │  ├─ Marca anterior como processado (vendas_pit_interno = TRUE)
   │  │  ├─ Cria novo objeto de venda
   │  │  ├─ Adiciona dados da pessoa
   │  │  └─ Cria array de produtos
   │  └─ Se mesmo cod_lanc_financeiro:
   │     └─ Adiciona produto ao array existente
   │
   └─ Marca último cod_lanc_financeiro como processado

4. GERAÇÃO DO JSON
   ├─ Formata JSON com indentação
   ├─ Salva arquivo entregas.json
   └─ Registra logs de sucesso
```

---

## 📝 **Procedure: `TFrmPrincipal.integracaoentregapegoraro`**

### **Localização**
```
UntPrincipal.pas - Linha ~1340
```

### **Parâmetros**
- Nenhum (procedure sem parâmetros)

### **Retorno**
- Nenhum (procedure void)

### **Dependências**
- `CXClient`: Conexão com banco de dados
- `WriteLogFormatted`: Sistema de logs
- `FormatJSON`: Função de formatação JSON

---

## 🎯 **Como Executar**

### **Chamada via Timer (Integrações Rotina)**
Executada automaticamente quando `ModuloHabilitado(12)` retorna true:

```delphi
if ModuloHabilitado(12) then
  integracaoentregapegoraro;
```

### **Chamada via BitBtn7**
O procedure é chamado quando o sistema está em modo cliente e o timer de integrações é executado (TimerintegracoesRotinaTimer).

---

## 📂 **Arquivo Gerado**

### **Nome do Arquivo**
```
entregas.json
```

### **Localização Padrão**
```
[Pasta do Executável]\entregas.json
```

### **Localização Configurável**
Definida na tabela `integracao.IntegracaoTXt`:
- `tipo_integracao = 'VENDASPIT'`
- `caminho_arquivo` = caminho completo (ex: `C:\Program Files\Datacom\DtcSync\entregas.json`)

### **Formato**
- Encoding: UTF-8
- Formatação: JSON indentado (2 espaços por nível)
- Estrutura: Objeto raiz com array "vendas"

---

## 🔍 **Logs Gerados**

### **Código de Log**
- `1502`: Integração de entregas (VENDASPIT)

### **Níveis de Log**
- `INFO`: Informações gerais do processo
- `DEBUG`: Detalhes de processamento
- `ERRO`: Erros encontrados
- `AVISO`: Avisos e situações especiais

### **Exemplos de Logs**
```
[INFO] [1502] Iniciando geração do arquivo JSON
[INFO] [1502] Período: 2024-01-15 até 2024-01-22
[DEBUG] [1502] Caminho encontrado na tabela: C:\Program Files\Datacom\DtcSync\entregas.json
[INFO] [1502] Arquivo será salvo em: C:\...\entregas.json
[INFO] [1502] Registros encontrados: 150
[DEBUG] [1502] vendas_pit_interno marcado como TRUE para cod_lanc_financeiro: 123
[INFO] [1502] Arquivo JSON salvo com sucesso: C:\...\entregas.json
[INFO] [1502] Total de vendas no JSON: 45
```

---

## ⚠️ **Observações Importantes**

### **1. Processamento Único**
- Cada venda é processada apenas uma vez
- Após processar, `vendas_pit_interno` é marcado como `TRUE`
- Vendas já processadas não aparecem em execuções futuras

### **2. Agrupamento**
- Produtos são agrupados por `cod_lanc_financeiro`
- Uma venda pode ter múltiplos produtos
- Todos os produtos de uma venda ficam no mesmo objeto

### **3. Persistência**
- O arquivo JSON é mantido entre execuções
- Novas vendas são adicionadas ao final do array
- O arquivo nunca é sobrescrito completamente (apenas atualizado)

### **4. Formato de Data**
- `data_inclusao`: Formato `yyyy-mm-dd hh:nn:ss`
- `data_entrega`: Formato `yyyy-mm-dd hh:nn:ss` (ou `0000-00-00 00:00:00` se vazio)

### **5. Módulo**
- Integração habilitada via módulo ID 12 (`ModuloHabilitado(12)`)

---

## 🐛 **Tratamento de Erros**

### **Erros Tratados**
1. **Tabela IntegracaoTXt não existe**
   - Cria schema `integracao`, tabela `IntegracaoTXt` e insere registro VENDASPIT
   - Usa caminho padrão: `C:\Program Files\Datacom\DtcSync\entregas.json`

2. **Erro ao ler arquivo JSON existente**
   - Log: `[AVISO] [1502] Erro ao ler arquivo existente...`
   - Ação: Cria novo arquivo JSON

3. **Erro ao atualizar vendas_pit_interno**
   - Log: `[ERRO] [1502] Erro ao atualizar vendas_pit_interno...`
   - Ação: Continua processamento (não interrompe)

4. **Erro ao salvar arquivo JSON**
   - Log: `[ERRO] [1502] Erro ao salvar arquivo JSON...`
   - Ação: Exception é lançada

---

## 📈 **Performance**

### **Otimizações**
- Query ordenada por `cod_lanc_financeiro` para agrupamento eficiente
- Processamento em memória (JSON em memória antes de salvar)
- Uso de índices do banco de dados

### **Recomendações**
- Executar em horários de baixo uso do sistema
- Monitorar tamanho do arquivo JSON (pode crescer com o tempo)
- Considerar limpeza periódica de vendas antigas do JSON

---

## 🔄 **Manutenção**

### **Limpeza do Arquivo JSON**
Se necessário limpar o arquivo JSON:
1. Fazer backup do arquivo `entregas.json`
2. Deletar ou renomear o arquivo
3. Próxima execução criará novo arquivo

### **Reset de Vendas Processadas**
Para reprocessar vendas já processadas:
```sql
UPDATE lancamentos_financeiros 
SET vendas_pit_interno = FALSE 
WHERE vendas_pit_interno = TRUE;
```

### **Alterar Caminho do Arquivo**
```sql
UPDATE integracao.IntegracaoTXt 
SET caminho_arquivo = 'C:\Novo\Caminho\entregas.json' 
WHERE tipo_integracao = 'VENDASPIT';
```

---

## 📞 **Suporte**

Para dúvidas ou problemas:
- Verificar logs do sistema (código 1502)
- Consultar código fonte em `UntPrincipal.pas` - procedure `integracaoentregapegoraro`
- Verificar estrutura do banco de dados e tabela `integracao.IntegracaoTXt`

---

**Última atualização:** Março 2025  
**Versão:** 2.0
