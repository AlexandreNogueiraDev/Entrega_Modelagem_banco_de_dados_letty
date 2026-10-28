-- =====================================================================
-- SCRIPT DDL - LETTY GESTAO COMERCIAL LTDA (Versao revisada)
-- SGBD: MySQL 8.0+ | Engine: InnoDB | Charset: utf8mb4
--
-- Principais ajustes:
--   * Padronizacao de nomes em snake_case.
--   * Codigos de negocio renomeados para nr_* (CPF, CNPJ, EAN, NCM).
--   * Atributo composto endereco separado em endereco.
--   * Telefones/e-mails separados em tabelas proprias (atributos multivalorados).
--   * Empresa terceirizada normalizada em empresa_terceirizada.
--   * Ocorrencia de vencimento passa a referenciar o lote por id_lote.
--
-- ATENCAO: este script recria as tabelas abaixo. Em um banco com dados,
-- faca backup e migre os dados antes de executar DROP TABLE.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS letty_gestao_comercial
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE letty_gestao_comercial;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS vencimento_prod;
DROP TABLE IF EXISTS item_visita;
DROP TABLE IF EXISTS visita;
DROP TABLE IF EXISTS item_pedido;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS envia;
DROP TABLE IF EXISTS email_contato;
DROP TABLE IF EXISTS telefone_contato;
DROP TABLE IF EXISTS contato;
DROP TABLE IF EXISTS telefone_promotor;
DROP TABLE IF EXISTS promotor;
DROP TABLE IF EXISTS empresa_terceirizada;
DROP TABLE IF EXISTS loja;
DROP TABLE IF EXISTS super_mercado;
DROP TABLE IF EXISTS telefone_fabricante;
DROP TABLE IF EXISTS email_fabricante;
DROP TABLE IF EXISTS fabricante;
DROP TABLE IF EXISTS endereco;
DROP TABLE IF EXISTS item_pedido;
DROP TABLE IF EXISTS comissao;
DROP TABLE IF EXISTS lote;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS contrato;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Atributo composto ENDERECO, reutilizado por fabricante, rede e loja.
CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    ds_logradouro VARCHAR(120) NOT NULL,
    nr_endereco VARCHAR(15) NOT NULL,
    ds_complemento VARCHAR(80) NULL,
    nm_bairro VARCHAR(80) NOT NULL,
    nm_cidade VARCHAR(80) NOT NULL,
    sg_estado CHAR(2) NOT NULL,
    nr_cep VARCHAR(8) NOT NULL,
    nm_pais VARCHAR(60) NOT NULL DEFAULT 'Brasil'
) ENGINE=InnoDB;

-- 2. FABRICANTE
CREATE TABLE fabricante (
    id_fabricante INT AUTO_INCREMENT PRIMARY KEY,
    nm_razao_social VARCHAR(120) NOT NULL,
    nm_fantasia VARCHAR(100) NOT NULL,
    nr_cnpj VARCHAR(14) NOT NULL UNIQUE,
    nr_inscricao_estadual VARCHAR(20) NOT NULL,
    id_endereco INT NOT NULL,
    CONSTRAINT fk_fabricante_endereco FOREIGN KEY (id_endereco)
        REFERENCES endereco(id_endereco)
) ENGINE=InnoDB;

CREATE TABLE telefone_fabricante (
    id_telefone_fabricante INT AUTO_INCREMENT PRIMARY KEY,
    id_fabricante INT NOT NULL,
    nr_telefone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE CASCADE,
    CONSTRAINT uq_telefone_fabricante UNIQUE (id_fabricante, nr_telefone)
) ENGINE=InnoDB;

CREATE TABLE email_fabricante (
    id_email_fabricante INT AUTO_INCREMENT PRIMARY KEY,
    id_fabricante INT NOT NULL,
    ds_email VARCHAR(100) NOT NULL,
    CONSTRAINT fk_email_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE CASCADE,
    CONSTRAINT uq_email_fabricante UNIQUE (id_fabricante, ds_email)
) ENGINE=InnoDB;

-- 3. CONTRATO
CREATE TABLE contrato (
    id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    id_fabricante INT NOT NULL,
    dt_inicio DATE NOT NULL,
    dt_fim DATE NULL,
    pc_comissao DECIMAL(5,2) NOT NULL,
    ds_territorio_atuacao VARCHAR(100) NULL,
    in_exclusividade BOOLEAN NOT NULL,
    vl_meta_vendas DECIMAL(12,2) NULL,
    st_contrato VARCHAR(30) NOT NULL,
    CONSTRAINT fk_contrato_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),
    CONSTRAINT chk_contrato_comissao CHECK (pc_comissao BETWEEN 0 AND 100),
    CONSTRAINT chk_contrato_datas CHECK (dt_fim IS NULL OR dt_fim >= dt_inicio)
) ENGINE=InnoDB;

-- 4. COMISSAO
CREATE TABLE comissao (
    id_comissao INT AUTO_INCREMENT PRIMARY KEY,
    id_contrato INT NOT NULL,
    dt_apuracao DATE NOT NULL,
    vl_base DECIMAL(10,2) NOT NULL,
    pc_aplicado DECIMAL(5,2) NOT NULL,
    vl_comissao DECIMAL(10,2) NOT NULL,
    st_pagamento VARCHAR(30) NOT NULL,
    dt_pagamento DATE NULL,
    CONSTRAINT fk_comissao_contrato FOREIGN KEY (id_contrato)
        REFERENCES contrato(id_contrato),
    CONSTRAINT chk_comissao_percentual CHECK (pc_aplicado BETWEEN 0 AND 100),
    CONSTRAINT chk_comissao_valores CHECK (vl_base >= 0 AND vl_comissao >= 0)
) ENGINE=InnoDB;

-- 5. PRODUTO
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_fabricante INT NOT NULL,
    nr_ean VARCHAR(14) NOT NULL UNIQUE,
    nr_ncm VARCHAR(8) NOT NULL,
    nm_produto VARCHAR(150) NOT NULL,
    nm_marca VARCHAR(60) NOT NULL,
    tp_embalagem VARCHAR(30) NOT NULL,
    vl_preco_tabela DECIMAL(10,2) NOT NULL,
    qt_peso_bruto DECIMAL(10,3) NOT NULL,
    qt_peso_liquido DECIMAL(10,3) NOT NULL,
    in_ativo BOOLEAN NOT NULL,
    tp_unidade_medida VARCHAR(10) NOT NULL,
    tp_regime_tributario VARCHAR(50) NOT NULL,
    CONSTRAINT fk_produto_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),
    CONSTRAINT chk_produto_precos CHECK (vl_preco_tabela >= 0),
    CONSTRAINT chk_produto_pesos CHECK (qt_peso_bruto >= 0 AND qt_peso_liquido >= 0)
) ENGINE=InnoDB;

-- 6. LOTE
CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    nr_lote VARCHAR(30) NOT NULL,
    qt_produzida DECIMAL(10,2) NOT NULL,
    dt_fabricacao DATE NOT NULL,
    dt_validade DATE NOT NULL,
    CONSTRAINT fk_lote_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),
    CONSTRAINT uq_lote_produto UNIQUE (id_produto, nr_lote),
    CONSTRAINT chk_lote_datas CHECK (dt_validade >= dt_fabricacao),
    CONSTRAINT chk_lote_quantidade CHECK (qt_produzida >= 0)
) ENGINE=InnoDB;

-- 7. SUPER_MERCADO (rede/matriz)
CREATE TABLE super_mercado (
    id_rede INT AUTO_INCREMENT PRIMARY KEY,
    nm_razao_social VARCHAR(120) NOT NULL,
    nm_fantasia VARCHAR(100) NOT NULL,
    nr_cnpj VARCHAR(14) NOT NULL UNIQUE,
    nr_inscricao_estadual VARCHAR(20) NOT NULL,
    id_endereco INT NOT NULL,
    nm_representante_geral VARCHAR(100) NOT NULL,
    ds_portal_url VARCHAR(150) NULL,
    dt_inicio_relacionamento DATE NOT NULL,
    CONSTRAINT fk_super_mercado_endereco FOREIGN KEY (id_endereco)
        REFERENCES endereco(id_endereco)
) ENGINE=InnoDB;

CREATE TABLE telefone_rede (
    id_telefone_rede INT AUTO_INCREMENT PRIMARY KEY,
    id_rede INT NOT NULL,
    nr_telefone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_rede FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede) ON DELETE CASCADE,
    CONSTRAINT uq_telefone_rede UNIQUE (id_rede, nr_telefone)
) ENGINE=InnoDB;

CREATE TABLE email_rede (
    id_email_rede INT AUTO_INCREMENT PRIMARY KEY,
    id_rede INT NOT NULL,
    ds_email VARCHAR(100) NOT NULL,
    CONSTRAINT fk_email_rede FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede) ON DELETE CASCADE,
    CONSTRAINT uq_email_rede UNIQUE (id_rede, ds_email)
) ENGINE=InnoDB;

-- 8. LOJA (filiais)
CREATE TABLE loja (
    id_loja INT AUTO_INCREMENT PRIMARY KEY,
    id_rede INT NOT NULL,
    nr_loja_rede VARCHAR(20) NOT NULL,
    nm_loja VARCHAR(100) NOT NULL,
    nr_cnpj VARCHAR(14) NOT NULL UNIQUE,
    id_endereco INT NOT NULL,
    in_ativa BOOLEAN NOT NULL,
    CONSTRAINT fk_loja_rede FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede),
    CONSTRAINT fk_loja_endereco FOREIGN KEY (id_endereco)
        REFERENCES endereco(id_endereco),
    CONSTRAINT uq_loja_codigo_rede UNIQUE (id_rede, nr_loja_rede)
) ENGINE=InnoDB;

CREATE TABLE telefone_loja (
    id_telefone_loja INT AUTO_INCREMENT PRIMARY KEY,
    id_loja INT NOT NULL,
    nr_telefone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja) ON DELETE CASCADE,
    CONSTRAINT uq_telefone_loja UNIQUE (id_loja, nr_telefone)
) ENGINE=InnoDB;

-- 9. CONTATO corporativo da rede
CREATE TABLE contato (
    id_contato INT AUTO_INCREMENT PRIMARY KEY,
    id_rede INT NOT NULL,
    nm_contato VARCHAR(100) NOT NULL,
    ds_setor VARCHAR(50) NOT NULL,
    ds_cargo VARCHAR(50) NOT NULL,
    CONSTRAINT fk_contato_rede FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede)
) ENGINE=InnoDB;

CREATE TABLE telefone_contato (
    id_telefone_contato INT AUTO_INCREMENT PRIMARY KEY,
    id_contato INT NOT NULL,
    nr_telefone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_contato FOREIGN KEY (id_contato)
        REFERENCES contato(id_contato) ON DELETE CASCADE,
    CONSTRAINT uq_telefone_contato UNIQUE (id_contato, nr_telefone)
) ENGINE=InnoDB;

CREATE TABLE email_contato (
    id_email_contato INT AUTO_INCREMENT PRIMARY KEY,
    id_contato INT NOT NULL,
    ds_email VARCHAR(100) NOT NULL,
    CONSTRAINT fk_email_contato FOREIGN KEY (id_contato)
        REFERENCES contato(id_contato) ON DELETE CASCADE,
    CONSTRAINT uq_email_contato UNIQUE (id_contato, ds_email)
) ENGINE=InnoDB;

-- 10. EMPRESA TERCEIRIZADA e PROMOTOR
CREATE TABLE empresa_terceirizada (
    id_empresa_terceirizada INT AUTO_INCREMENT PRIMARY KEY,
    nm_empresa VARCHAR(100) NOT NULL,
    nr_cnpj VARCHAR(14) NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE promotor (
    id_promotor INT AUTO_INCREMENT PRIMARY KEY,
    id_empresa_terceirizada INT NOT NULL,
    nm_promotor VARCHAR(100) NOT NULL,
    nr_cpf VARCHAR(11) NOT NULL UNIQUE,
    CONSTRAINT fk_promotor_empresa FOREIGN KEY (id_empresa_terceirizada)
        REFERENCES empresa_terceirizada(id_empresa_terceirizada)
) ENGINE=InnoDB;

CREATE TABLE telefone_promotor (
    id_telefone_promotor INT AUTO_INCREMENT PRIMARY KEY,
    id_promotor INT NOT NULL,
    nr_telefone VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_promotor FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor) ON DELETE CASCADE,
    CONSTRAINT uq_telefone_promotor UNIQUE (id_promotor, nr_telefone)
) ENGINE=InnoDB;

-- 11. Associativa ENVIA (fabricante <-> promotor)
CREATE TABLE envia (
    id_fabricante INT NOT NULL,
    id_promotor INT NOT NULL,
    PRIMARY KEY (id_fabricante, id_promotor),
    CONSTRAINT fk_envia_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),
    CONSTRAINT fk_envia_promotor FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor)
) ENGINE=InnoDB;

-- 12. PEDIDO
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_fabricante INT NOT NULL,
    id_loja INT NOT NULL,
    dt_pedido DATE NOT NULL,
    dt_prevista_entrega DATE NULL,
    vl_preco_total DECIMAL(10,2) NOT NULL,
    ds_condicao_pagamento VARCHAR(50) NOT NULL,
    st_atual VARCHAR(30) NOT NULL,
    CONSTRAINT fk_pedido_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante),
    CONSTRAINT fk_pedido_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja),
    CONSTRAINT chk_pedido_total CHECK (vl_preco_total >= 0)
) ENGINE=InnoDB;

-- 13. ITEM_PEDIDO (pedido <-> produto)
CREATE TABLE item_pedido (
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    qt_solicitada DECIMAL(10,2) NOT NULL,
    vl_preco_negociado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),
    CONSTRAINT chk_item_pedido_valores CHECK (qt_solicitada > 0 AND vl_preco_negociado >= 0)
) ENGINE=InnoDB;

-- 14. VISITA
CREATE TABLE visita (
    id_visita INT AUTO_INCREMENT PRIMARY KEY,
    id_promotor INT NOT NULL,
    id_loja INT NOT NULL,
    dt_visita DATE NOT NULL,
    hr_inicio TIME NOT NULL,
    hr_fim TIME NOT NULL,
    ds_observacao TEXT NULL,
    CONSTRAINT fk_visita_promotor FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor),
    CONSTRAINT fk_visita_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja),
    CONSTRAINT chk_visita_horarios CHECK (hr_fim >= hr_inicio)
) ENGINE=InnoDB;

-- 15. ITEM_VISITA (visita <-> produto)
CREATE TABLE item_visita (
    id_visita INT NOT NULL,
    id_produto INT NOT NULL,
    qt_estoque_gondola DECIMAL(10,2) NOT NULL,
    dt_validade_encontrada DATE NULL,
    PRIMARY KEY (id_visita, id_produto),
    CONSTRAINT fk_item_visita_visita FOREIGN KEY (id_visita)
        REFERENCES visita(id_visita) ON DELETE CASCADE,
    CONSTRAINT fk_item_visita_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto),
    CONSTRAINT chk_item_visita_estoque CHECK (qt_estoque_gondola >= 0)
) ENGINE=InnoDB;

-- 16. VENCIMENTO_PROD: a ocorrencia referencia o lote, que ja identifica o produto.
CREATE TABLE vencimento_prod (
    id_ocorrencia INT AUTO_INCREMENT PRIMARY KEY,
    id_loja INT NOT NULL,
    id_lote INT NOT NULL,
    dt_ocorrencia DATE NOT NULL,
    qt_ocorrencia DECIMAL(10,2) NOT NULL,
    ds_ocorrencia VARCHAR(150) NULL,
    st_vencimento VARCHAR(30) NOT NULL,
    CONSTRAINT fk_vencimento_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja),
    CONSTRAINT fk_vencimento_lote FOREIGN KEY (id_lote)
        REFERENCES lote(id_lote),
    CONSTRAINT chk_vencimento_quantidade CHECK (qt_ocorrencia > 0)
) ENGINE=InnoDB;
