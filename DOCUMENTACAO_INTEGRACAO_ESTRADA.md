# 📧 DOCUMENTAÇÃO - SISTEMA DE INTEGRAÇÃO ESTRADA

## 🎯 **Visão Geral**

O Sistema de Integração Estrada é um módulo especializado que processa atualizações de classes de clientes e envia notificações por email em lote. O sistema foi desenvolvido para otimizar a comunicação, enviando um único email consolidado com todas as atualizações processadas.

---

## 🏗️ **Arquitetura do Sistema**

### **Componentes Principais:**

1. **`FClientesAtualizados: TStringList`** - Lista em memória para armazenar clientes atualizados
2. **`FTotalClientesAtualizados: Integer`** - Contador de clientes processados
3. **`EnviarEmailEmLote()`** - Função principal de envio de email
4. **`ArmazenarClienteAtualizado()`** - Função para adicionar clientes à lista
5. **`LimparClientesAtualizados()`** - Função para limpar a lista

---

## 📋 **Fluxo de Processamento**

### **1. Inicialização**
```delphi
// FormCreate
FClientesAtualizados := TStringList.Create;
FTotalClientesAtualizados := 0;
```

### **2. Processamento de Clientes**
```delphi
// VerificarEAtualizarClasse
if ArmazenarClienteAtualizado(CPF, NomeCliente, CodClasse, CodClasseDestino) then
  WriteLogFormatted('INFO', '1', 'Cliente armazenado com sucesso - CPF: ' + CPF);
```

### **3. Envio em Lote**
```delphi
// BitBtn7Click
WriteLogFormatted('INFO', '1', '*** CHAMANDO EnviarEmailEmLote ***');
if EnviarEmailEmLote then
  WriteLogFormatted('INFO', '1', 'Email em lote enviado com sucesso!');
```

### **4. Limpeza**
```delphi
// FormDestroy
if Assigned(FClientesAtualizados) then
  FClientesAtualizados.Free;
```

---

## 🔧 **Funções Principais**

### **`ArmazenarClienteAtualizado()`**
```delphi
function TFrmPrincipal.ArmazenarClienteAtualizado(
  const CPF, NomeCliente: string; 
  const CodClasseAnterior, CodClasseNovo: Integer): Boolean;
```
**Propósito:** Adiciona um cliente atualizado à lista em memória
**Formato de Armazenamento:** `CPF|Nome|ClasseAnterior|ClasseNova`
**Retorno:** `True` se armazenado com sucesso, `False` em caso de erro

### **`EnviarEmailEmLote()`**
```delphi
function TFrmPrincipal.EnviarEmailEmLote: Boolean;
```
**Propósito:** Envia email HTML consolidado com todos os clientes atualizados
**Recursos:**
- Configuração SMTP dinâmica via banco de dados
- HTML responsivo com CSS moderno
- Tabela formatada com dados dos clientes
- Logs detalhados de cada etapa

### **`LimparClientesAtualizados()`**
```delphi
procedure TFrmPrincipal.LimparClientesAtualizados;
```
**Propósito:** Limpa a lista de clientes para novo processamento
**Chamada:** Início de cada ciclo de processamento

---

## 📧 **Sistema de Email**

### **Configuração SMTP**
```sql
SELECT smtp_servidor, smtp_porta, smtp_usuario, smtp_senha, 
       smtp_ssl, smtp_tls, email_remetente, email_destinatario, 
       enviar_email_notificacao 
FROM integracao.config_api 
WHERE ativo = true 
ORDER BY id DESC LIMIT 1
```

### **Estrutura do Email HTML**
```html
<html>
<head>
<style>
/* CSS moderno para tabelas responsivas */
table { border-collapse: collapse; width: 100%; margin: 20px 0; 
        font-family: Arial, sans-serif; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
th { background-color: #f2f2f2; font-weight: bold; color: #333; 
     text-transform: uppercase; font-size: 12px; }
tr:nth-child(even) { background-color: #f9f9f9; }
tr:hover { background-color: #f5f5f5; }
.header { background: linear-gradient(135deg, #4CAF50, #45a049); 
          color: white; padding: 20px; margin-bottom: 20px; 
          border-radius: 5px; text-align: center; }
.summary { background-color: #e7f3ff; padding: 15px; margin: 20px 0; 
           border-left: 4px solid #2196F3; border-radius: 3px; }
.footer { background-color: #f8f9fa; padding: 15px; margin-top: 20px; 
          border-top: 1px solid #ddd; border-radius: 3px; }
body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; 
       max-width: 800px; margin: 0 auto; }
.status-ok { color: #28a745; font-weight: bold; }
.section-title { color: #2c3e50; border-bottom: 2px solid #3498db; 
                padding-bottom: 5px; margin-bottom: 15px; }
</style>
</head>
<body>
<div class="header">
<h2>*** RELAÇÃO DE CLIENTES DESATIVADOS COM APP CASHBACK ***</h2>
</div>
<div class="summary">
<h3>Resumo do Processamento</h3>
<p><strong>Data/Hora:</strong> 08/08/2025 11:39:25</p>
<p><strong>Total de Clientes Atualizados:</strong> 1</p>
</div>
<h3 class="section-title">Detalhamento dos Clientes</h3>
<table>
<thead>
<tr>
<th>#</th>
<th>CPF</th>
<th>Nome do Cliente</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td>29568650059</td>
<td>teste</td>
<td class="status-ok">Atualizado</td>
</tr>
</tbody>
</table>
<div class="footer">
<p><em>Esta notificação foi gerada automaticamente pelo DtcSync.</em></p>
<p><strong>Atenciosamente,</strong><br>Datacom Automações</p>
</div>
</body>
</html>
```

---

## 🔐 **Segurança e Compatibilidade**

### **SSL/TLS Configuration**
```delphi
// Configuração SSL Handler
with LSocketSSL do
begin
  with SSLOptions do
  begin
    Mode := sslmClient;
    Method := sslvTLSv1_2;
  end;
  Host := SMTP;
  Port := Porta;
end;

// Configuração SMTP
with IdSMTP do
begin
  IOHandler := LSocketSSL;
  Host := SMTP;
  Port := Porta;
  AuthType := satDefault;
  Username := QryConfig.FieldByName('smtp_usuario').AsString;
  Password := QryConfig.FieldByName('smtp_senha').AsString;
  UseTLS := utUseExplicitTLS;
end;
```

### **Tratamento de Erros**
```delphi
try
  // Operações de email
except
  on E: Exception do
  begin
    WriteLogFormatted('ERRO', '1', 'Erro ao enviar email em lote: ' + E.Message);
    Result := False;
  end;
end;
```

---

## 📊 **Logs e Monitoramento**

### **Logs de Processamento**
```
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] *** INICIANDO PROCESSO DE INTEGRAÇÃO ***
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Cliente armazenado na lista: 29568650059
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] *** CHAMANDO EnviarEmailEmLote ***
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Email em lote enviado com sucesso!
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] *** FINALIZANDO PROCESSO DE INTEGRAÇÃO ***
```

### **Logs de Email**
```
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Configurações de email carregadas
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Conectando ao servidor SMTP...
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Enviando email em lote...
[INFO(1)] [EXECUTADOR DE INTEGRAÇÃO ESTRADA] Email em lote enviado com sucesso
```

---

## 🚀 **Vantagens do Sistema**

### **1. Eficiência**
- ✅ **Um email por lote** em vez de múltiplos emails
- ✅ **Redução de spam** para destinatários
- ✅ **Menor carga** no servidor SMTP

### **2. Organização**
- ✅ **Dados consolidados** em uma única visualização
- ✅ **Tabela estruturada** com informações claras
- ✅ **Resumo executivo** no cabeçalho

### **3. Compatibilidade**
- ✅ **HTML responsivo** funciona em todos os clientes
- ✅ **CSS moderno** para visual profissional
- ✅ **Charset UTF-8** para caracteres especiais

### **4. Manutenibilidade**
- ✅ **Código modular** e bem estruturado
- ✅ **Logs detalhados** para debugging
- ✅ **Configuração flexível** via banco de dados

---

## 🔧 **Configuração do Banco de Dados**

### **Tabela de Configuração**
```sql
-- Exemplo de configuração ativa
INSERT INTO integracao.config_api (
  ativo, smtp_servidor, smtp_porta, smtp_usuario, smtp_senha,
  smtp_ssl, smtp_tls, email_remetente, email_destinatario, 
  enviar_email_notificacao
) VALUES (
  true, 'smtp.gmail.com', *****, 'seu-email@gmail.com', '*****',
  false, true, 'seu-email@gmail.com', 'destinatario@empresa.com',
  true
);
```

### **Campos Obrigatórios**
- `smtp_servidor`: Servidor SMTP (ex: smtp.gmail.com)
- `smtp_porta`: Porta SMTP (ex: ***** para TLS, ***** para SSL)
- `smtp_usuario`: Usuário SMTP
- `smtp_senha`: *****
- `email_remetente`: Email de origem
- `email_destinatario`: Email de destino
- `enviar_email_notificacao`: Flag para habilitar/desabilitar

---

## 📝 **Checklist de Implementação**

### **✅ Pré-requisitos**
- [ ] DLLs do OpenSSL instaladas (`libeay32.dll`, `ssleay32.dll`)
- [ ] Configuração SMTP válida no banco de dados
- [ ] Conexão com banco de dados funcionando
- [ ] Permissões de rede para SMTP

### **✅ Configuração**
- [ ] `FClientesAtualizados` inicializado no `FormCreate`
- [ ] `LimparClientesAtualizados` chamado no início do processamento
- [ ] `EnviarEmailEmLote` chamado no final do processamento
- [ ] Logs configurados para monitoramento

### **✅ Testes**
- [ ] Teste de conexão SMTP funcionando
- [ ] Email sendo enviado corretamente
- [ ] HTML renderizando adequadamente
- [ ] Logs registrando todas as operações

---

## 🆘 **Troubleshooting**

### **Problema: Email não está sendo enviado**
**Solução:**
1. Verificar logs para identificar erro específico
2. Testar conexão SMTP manualmente
3. Verificar configurações no banco de dados
4. Confirmar se DLLs do OpenSSL estão presentes

### **Problema: Caracteres especiais aparecem como "?"**
**Solução:**
1. Usar charset UTF-8 no ContentType
2. Remover caracteres Unicode problemáticos
3. Usar apenas texto ASCII para máxima compatibilidade

### **Problema: Email sendo enviado múltiplas vezes**
**Solução:**
1. Verificar se `EnviarEmailEmLote` está sendo chamado apenas uma vez
2. Confirmar se `LimparClientesAtualizados` está sendo chamado no início
3. Verificar se não há loops desnecessários

---

## 📞 **Suporte**

Para dúvidas ou problemas com o sistema de integração Estrada:

1. **Verificar logs** em `Logs.txt`
2. **Testar conexão SMTP** usando função de teste
3. **Validar configurações** no banco de dados
4. **Consultar documentação** para troubleshooting

---

*Documentação gerada automaticamente pelo Sistema de Integração Estrada*
*Versão: 1.0 | Data: 08/08/2025* 