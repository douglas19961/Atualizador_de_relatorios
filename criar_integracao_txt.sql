-- Script para criar schema e tabela IntegracaoTXt
-- Execute no banco de dados do cliente (ex: sig) ao qual o aplicativo se conecta

-- 1. Criar schema se não existir
CREATE SCHEMA IF NOT EXISTS integracao;

-- 2. Criar tabela se não existir
CREATE TABLE IF NOT EXISTS integracao.IntegracaoTXt (
    id SERIAL PRIMARY KEY,
    tipo_integracao VARCHAR(50) NOT NULL,
    caminho_arquivo VARCHAR(500) NOT NULL,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. (Opcional) Inserir registro para integração VENDASPIT se não existir
-- Caminho vazio = usa raiz do sistema. Preencha com caminho completo ex: 'C:\Pasta\entregas.json'
INSERT INTO integracao.integracoatxt (tipo_integracao, caminho_arquivo)
SELECT 'VENDASPIT', ''
WHERE NOT EXISTS (SELECT 1 FROM integracao.integracoatxt WHERE tipo_integracao = 'VENDASPIT');
