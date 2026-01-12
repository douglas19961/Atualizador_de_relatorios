# 📦 DOCUMENTAÇÃO - INTEGRAÇÃO DE ENTREGAS

## 🎯 **Visão Geral**

A integração de entregas é um módulo que gera um arquivo JSON (`entregas.json`) contendo informações de vendas processadas, agrupadas por lançamento financeiro. O sistema processa vendas do último mês que ainda não foram marcadas como processadas (`cash_back_lanc IS NOT TRUE`) e gera um arquivo JSON formatado para integração com sistemas externos.

---

## 📋 **Funcionalidades Principais**

### **1. Processamento de Vendas**
- Busca vendas do último mês (30 dias)
- Filtra apenas vendas não processadas (`cash_back_lanc IS NOT TRUE`)
- Filtra apenas lançamentos de produtos do tipo venda (`lp.tipo_lancamento = 'V'`)
- Agrupa produtos por `cod_lanc_financeiro`
- Marca vendas como processadas após gerar o JSON

### **2. Geração de Arquivo JSON**
- Arquivo: `entregas.json`
- Localização: Pasta raiz do executável
- Formato: JSON formatado com indentação (legível)
- Estrutura: Hierárquica com vendas, pessoas e produtos

### **3. Persistência de Dados**

- Carrega arquivo JSON existente (se houver)
- Adiciona novas vendas ao final do arquivo
- Mantém histórico de todas as vendas processadas

---

## 🏗️ **Estrutura do JSON Gerado**

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
| `chave_acesso` | String | Chave de acesso da nota fiscal |
| `valor` | Number | Valor total do lançamento financeiro |
| `numero_documento` | String | Número do documento fiscal |
| `data_inclusao` | String | Data e hora de inclusão (formato: `yyyy-mm-dd hh:nn:ss`) |

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

## 🔧 **Query SQL Utilizada**

```sql
SELECT 
  lf.cod_lanc_financeiro, 
  lf.chave_acesso, 
  lf.cod_pessoa, 
  lf.valor AS valor_lancamento, 
  lf.numero_documento, 
  lf.data_inclusao, 
  lp.valor AS valor_produto, 
  lp.quantidade, 
  lp.cod_produto, 
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
INNER JOIN municipios m ON pe.cidade = m.cod_municipio 
WHERE lf.cash_back_lanc IS NOT TRUE 
  AND lf.data_inclusao BETWEEN :data_inicio AND :data_fim
  AND lp.tipo_lancamento = 'V' 
ORDER BY lf.cod_lanc_financeiro, lp.cod_produto
```

### **Filtros Aplicados:**
- `lf.cash_back_lanc IS NOT TRUE`: Apenas vendas não processadas
- `lf.data_inclusao BETWEEN :data_inicio AND :data_fim`: Último mês (30 dias)
- `lp.tipo_lancamento = 'V'`: Apenas lançamentos de venda

---

## 🔄 **Fluxo de Processamento**

```
┌─────────────────────────────────────────────────────────────┐
│              INTEGRAÇÃO DE ENTREGAS                        │
└─────────────────────────────────────────────────────────────┘

1. INICIALIZAÇÃO
   ├─ Define período: 1 mês atrás até hoje
   ├─ Define caminho do arquivo: entregas.json
   └─ Carrega JSON existente (se houver)

2. CONEXÃO COM BANCO
   ├─ Conecta com CXClient
   └─ Executa query SQL

3. PROCESSAMENTO
   ├─ Para cada registro retornado:
   │  ├─ Se novo cod_lanc_financeiro:
   │  │  ├─ Marca anterior como processado (cash_back_lanc = TRUE)
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

## 📝 **Procedure: `TFrmPrincipal.integracaostop`**

### **Localização**
```delphi
UntPrincipal.pas - Linha ~1148
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

### **Chamada Manual**
```delphi
FrmPrincipal.integracaostop;
```

### **Chamada via Botão**
O procedure é chamado através do botão `BitBtn7` quando o sistema está em modo servidor:

```delphi
procedure TFrmPrincipal.BitBtn7Click(Sender: TObject);
begin
  if EhModoserver(ComboBox1) then
  begin
    integracaostop;
    WriteLogFormatted('INFO', '1501', '[EXECUTADOR DO json integração] executando json !');
  end;
end;
```

---

## 📂 **Arquivo Gerado**

### **Nome do Arquivo**
```
entregas.json
```

### **Localização**
```
[Pasta do Executável]\entregas.json
```

### **Exemplo**
```
C:\Program Files\Datacom\DtcSync\entregas.json
```

### **Formato**
- Encoding: UTF-8
- Formatação: JSON indentado (2 espaços por nível)
- Estrutura: Objeto raiz com array "vendas"

---

## 🔍 **Logs Gerados**

### **Níveis de Log**
- `INFO`: Informações gerais do processo
- `DEBUG`: Detalhes de processamento
- `ERRO`: Erros encontrados
- `AVISO`: Avisos e situações especiais

### **Exemplos de Logs**
```
[INFO] [1501] [INTEGRACAO STOP] Iniciando geração do arquivo JSON
[INFO] [1501] [INTEGRACAO STOP] Período: 2024-01-15 até 2024-02-15
[INFO] [1501] [INTEGRACAO STOP] Arquivo será salvo em: C:\...\entregas.json
[INFO] [1501] [INTEGRACAO STOP] Registros encontrados: 150
[DEBUG] [1501] [INTEGRACAO STOP] cash_back_lanc marcado como TRUE para cod_lanc_financeiro: 123
[INFO] [1501] [INTEGRACAO STOP] Arquivo JSON salvo com sucesso
[INFO] [1501] [INTEGRACAO STOP] Total de vendas no JSON: 45
[INFO] [1501] [INTEGRACAO STOP] Processamento concluído com sucesso
```

---

## ⚠️ **Observações Importantes**

### **1. Processamento Único**
- Cada venda é processada apenas uma vez
- Após processar, `cash_back_lanc` é marcado como `TRUE`
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
- Exemplo: `2024-01-15 14:30:45`

### **5. Valores Nulos**
- Campos vazios são salvos como strings vazias (`""`)
- Números nulos são salvos como `0`
- O sistema trata valores nulos automaticamente

---

## 🐛 **Tratamento de Erros**

### **Erros Tratados**
1. **Erro de conexão com banco**
   - Log: `[ERRO] [1501] [INTEGRACAO STOP] Erro ao conectar ao banco...`
   - Ação: Procedure é interrompido

2. **Erro ao ler arquivo JSON existente**
   - Log: `[AVISO] [1501] [INTEGRACAO STOP] Erro ao ler arquivo existente...`
   - Ação: Cria novo arquivo JSON

3. **Erro ao atualizar cash_back_lanc**
   - Log: `[ERRO] [1501] [INTEGRACAO STOP] Erro ao atualizar cash_back_lanc...`
   - Ação: Continua processamento (não interrompe)

4. **Erro ao salvar arquivo JSON**
   - Log: `[ERRO] [1501] [INTEGRACAO STOP] Erro ao salvar arquivo JSON...`
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
SET cash_back_lanc = FALSE 
WHERE cash_back_lanc = TRUE;
```

---

## 📞 **Suporte**

Para dúvidas ou problemas:
- Verificar logs do sistema
- Consultar código fonte em `UntPrincipal.pas`
- Verificar estrutura do banco de dados

---

**Última atualização:** 2024
**Versão:** 1.0
