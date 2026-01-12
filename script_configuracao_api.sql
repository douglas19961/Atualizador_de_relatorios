-- Script para criar tabela de configurações da API de integração
-- Schema: integracao

CREATE TABLE IF NOT EXISTS integracao.config_api (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL,
    url_api VARCHAR(500) NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    senha VARCHAR(100) NOT NULL,
    cod_classe_destino INTEGER NOT NULL DEFAULT 28,
    limite_registros INTEGER NOT NULL DEFAULT 30,
    ativo BOOLEAN NOT NULL DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Adicionar colunas de email se não existirem
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_servidor') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_servidor VARCHAR(200);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_porta') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_porta INTEGER DEFAULT 587;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_usuario') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_usuario VARCHAR(100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_senha') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_senha VARCHAR(100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_ssl') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_ssl BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'smtp_tls') THEN
        ALTER TABLE integracao.config_api ADD COLUMN smtp_tls BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'email_remetente') THEN
        ALTER TABLE integracao.config_api ADD COLUMN email_remetente VARCHAR(200);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'email_destinatario') THEN
        ALTER TABLE integracao.config_api ADD COLUMN email_destinatario VARCHAR(200);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'config_api' AND column_name = 'enviar_email_notificacao') THEN
        ALTER TABLE integracao.config_api ADD COLUMN enviar_email_notificacao BOOLEAN DEFAULT false;
    END IF;
END $$;

-- Inserir configuração padrão
INSERT INTO integracao.config_api (
    descricao, 
    url_api, 
    usuario, 
    senha, 
    cod_classe_destino, 
    limite_registros, 
    ativo
) VALUES (
    'API Grupo Estrada - Homologação',
    'https://api-admin-grupoestrada-homo.mxsolucoes.com.br',
    'user_pdv_novo_foxx_2',
    'tukhug-xadnar-6vaZxi',
    28,
    30,
    true
) ON CONFLICT DO NOTHING;

-- Comentários das colunas
COMMENT ON TABLE integracao.config_api IS 'Configurações da API de integração de clientes';
COMMENT ON COLUMN integracao.config_api.descricao IS 'Descrição da configuração';
COMMENT ON COLUMN integracao.config_api.url_api IS 'URL base da API';
COMMENT ON COLUMN integracao.config_api.usuario IS 'Usuário para autenticação na API';
COMMENT ON COLUMN integracao.config_api.senha IS 'Senha para autenticação na API';
COMMENT ON COLUMN integracao.config_api.cod_classe_destino IS 'Código da classe que será atribuída aos clientes';
COMMENT ON COLUMN integracao.config_api.limite_registros IS 'Limite de registros por página na API';
COMMENT ON COLUMN integracao.config_api.ativo IS 'Se a configuração está ativa';