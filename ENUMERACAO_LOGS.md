# 📋 ENUMERAÇÃO DE LOGS - Dtc_Atualizador_Server

## 🎯 **Visão Geral**

Este documento enumera todos os logs do sistema organizados por assunto/procedure, substituindo o número genérico '1' por códigos específicos para facilitar o monitoramento e debugging.

---

## 📊 **LEGENDA COMPLETA DE CÓDIGOS**

| Código | Assunto/Procedure | Descrição |
|--------|-------------------|-----------|
| **1** | **LOGS(SISTEMA)** | GERENCIAMENTO DE LOGS |
| **2** | **CONEXÃO ROTINA** | CONEXÃO ROTINA |
| **3** | **INSERÇÃO MODULOS** | INSERÇÃO MODULOS |
| **4** | **DELETA INICIALIZADOR** | DELETA INICIALIZADOR QUE HOUVE PROBLEMAS INICIAIS COM O WINDOWNS |
| **101** | **PRODUÇÃO** | ERRO PRODUÇÃO |
| **102** | **CNPJ** | VALIDAÇÃO CNPJ |
| **103** | **NFC-e** | CONSULTA NFCE DIVERGENCIA |
| **104** | **NF-e** | CONSULTA NFE DIVERGENCIA |
| **105** | **VALIDADE** | ATUALIZA VALIDADE DO SIGILO|
| **106** | **ATUALIZA DATA E HORA** | ATUALIZA DATA E HORA DO CLIENTE VIA API |
| **107** | **CARREGAR ID** | ATUALIZA data e hora sem ser api(é para ter sido desativada)|
| **108** | **EXECUTADOR DE INTEGRAÇÃO ESTRADA** | ESTRADA |
| **109** | **Conexão do cliente** | Conexão do cliente |
| **110** | **Divergencia encerrantes sig** | DIVERCENCIA DE ENCERRANTES SIGILO |
| **111** | **CERTIFICADOS WINDOWNS** | VERIFICAR CERTIFICADOS CLIENTES |
| **112** | **VERSÃO DTCSYNC** | CONSULTA VERSÃO DTCSYNC |
| **113** | **VERIFICAR DOCUMENTOS FISCAIS** | VERIFICAR DOCUMENTOS FISCAIS |
| **114** | **VERIFICAR REPLICAS CLIENTES** | VERIFICAR REPLICAS CLIENTES |
| **115** | **DTCSYNC** | DTCSYNC NÃO SINCRONIZADOS |
| **116** | **BACKUP-DOS** | DTCSYNC NÃO SINCRONIZADOS |
| **117** | **ENCERRANTES FROTA** | DIVERGENCIA DE ENCERRANTES DTCFROTA |
| **120** | **THREAD MONITOR OCORRENCIAS** | THREAD MONITOR OCORRENCIAS |
| **121** | **VERSÃO SIGILO CLIENTE** | VERSAO SIG |
| **122** | **TRANSFERÊNCIA SERVER THREAD** | TRANSFERÊNCIA DE RELATÓRIOS DO SERVIDOR |
| **123** | **HARDWARE CLIENTE** | COLETA DE ESPECIFICAÇÕES DE HARDWARE |






## 🔄 **PROCESSO DE ATUALIZAÇÃO**

### **Passo 1: Identificar o Tipo de Log**
Analise a mensagem do log e identifique a qual categoria pertence.

### **Passo 2: Substituir o Código**
Substitua o número '1' pelo código apropriado da tabela acima.

### **Exemplo de Substituição:**

**ANTES:**
```pascal
WriteLogFormatted('INFO', '1', '[HTTP SERVER] Servidor HTTP iniciado na porta 4450');
```

**DEPOIS:**
```pascal
WriteLogFormatted('INFO', '300', '[HTTP SERVER] Servidor HTTP iniciado na porta 4450');
```

---

## 📈 **BENEFÍCIOS DA ENUMERAÇÃO**

1. **Facilita o Filtro**: Permite filtrar logs por categoria específica
2. **Melhora o Debug**: Identifica rapidamente a origem do problema
3. **Organiza o Monitoramento**: Agrupa logs relacionados
4. **Padroniza o Sistema**: Cria uma estrutura consistente de logs

---

## 🎯 **PRÓXIMOS PASSOS**

1. **Implementar a enumeração** em todos os logs do sistema
2. **Atualizar a documentação** com os novos códigos
3. **Criar filtros** no sistema de logs para facilitar o monitoramento
4. **Treinar a equipe** sobre os novos códigos de log

---

## 📝 **NOTAS IMPORTANTES**

- **Códigos 100-999**: Logs principais do sistema
- **Códigos 1000+**: Logs específicos e de debug
- **Status**: INFO, ERRO, DEBG (mantidos como estão)
- **Compatibilidade**: A mudança é transparente para o usuário final

| 124 | NFE Contingência | Verificação de divergências NFE | `uThreadmonitorDeOcorrencia.consultaNFcECONTIGENCIA` |

---

*Versão: 3.0 | Data: 13/08/2025* 