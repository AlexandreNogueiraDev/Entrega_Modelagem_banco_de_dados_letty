# Entrega 1 — Modelo Conceitual (DER)

### Modelagem de um sistema de gestão de informações para a Letty Gestão Comercial LTDA

---

## 1. Caracterização da Organização

* **Nome e natureza da organização:** Letty Gestão Comercial LTDA, empresa privada com fins lucrativos atuante no segmento de representação e gestão comercial no varejo alimentício.


* **Contexto e porte:** Operação enxuta composta por 2 pessoas (sendo o representante comercial Ednilson o responsável direto pelas operações de campo e negociações). A empresa atua há 1 ano e 6 meses representando fabricantes da indústria alimentícia e gerenciando a carteira de pedidos junto a redes de supermercados no varejo.


* **Problemas e necessidades identificados:** A gestão comercial atual é fragmentada entre planilhas, anotações pessoais e portais isolados de clientes. Os principais gargalos operacionais são:


* Falta de acompanhamento em tempo real da atuação dos promotores terceirizados na reposição de gôndolas.


* Dificuldade de controle do estoque e risco de perda de produtos por vencimento nas lojas (gerando prejuízo direto).


* Retrabalho e gargalos no fluxo de cadastro e emissão de pedidos de venda por divergências de preços ou dados fiscais.


* Ausência de uma plataforma unificada que integre os dados do fabricante e do varejo para suporte a decisões estratégicas e ações promocionais preventivas.




* **Justificativa da escolha:** A Letty possui uma operação de alta relevância logística e comercial, sendo um estudo de caso ideal para modelagem de banco de dados. Apresenta complexidade adequada de entidades e relacionamentos (gestão de lotes, promoções, pedidos, auditoria em loja e conformidade fiscal/LGPD) em uma estrutura de pequeno porte acessível para levantamento de requisitos.


* **Evidências da organização:**
* **Razão Social:** Letty Gestão Comercial LTDA.


* **Tempo de Atuação:** 1 ano e 6 meses.


* **Responsável Operacional:** Ednilson (Representante Comercial).


* **Forma de Contato / Entrevista:** Entrevista técnica e levantamento de requisitos com o gestor comercial em setembro de 2026.





---

## 2. Processos de Negócio

* **Principais processos mapeados:**
1. **Captação e Cadastro:** Registro cadastral de Fabricantes, Redes de Supermercados (Matriz e Filiais/Lojas) e do portfólio de Produtos com especificações fiscais.


2. **Análise de Mercado e PDV:** Leitura de concorrência, precificação em gôndola e levantamento de performance por loja.


3. **Negociação e Registro de Pedidos:** Reunião periódica com o comprador da rede, fechamento e lançamento de pedidos com múltiplos itens, quantidade e preço negociado.


4. **Faturamento, Lote e Logística:** Processamento do pedido pela fábrica, emissão do Lote de produção com datas de fabricação/validade e entrega na loja recebedora.


5. **Auditoria e Promotoria (Visita PDV):** Reposição de mercadorias por promotor terceirizado, acompanhamento de estoque de gôndola e conferência de validades.


6. **Ações Promocionais e Gestão de Validade:** Identificação de itens com baixo giro/proximidade do vencimento e aplicação de promoções para evitar perdas.




* **Fluxogramas:**

```
[Cadastro: Fabricante / Rede / Produtos] 
                   │
                   ▼
[Análise de Mercado & Precificação PDV] 
                   │
                   ▼
[Negociação & Registro do Pedido de Venda] 
                   │
                   ▼
[Faturamento pela Fábrica & Geração do Lote] 
                   │
                   ▼
[Logística & Entrega na Loja/Filial] 
                   │
                   ▼
[Visita do Promotor: Reposição & Auditoria de Validade] ──(Risco de Vencimento)──► [Ação Promocional]

```

---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais

* **RF01 - Gestão Cadastral:** O sistema deve permitir o cadastro de Fabricantes, Produtos, Redes de Supermercados, Lojas/Filiais, Contatos por setor e Promotores terceirizados.


* **RF02 - Registro de Lotes:** O sistema deve permitir o vínculo de Lotes a Produtos, armazenando data de fabricação, data de validade e quantidade produzida.


* **RF03 - Emissão de Pedidos:** O sistema deve permitir criar pedidos de venda vinculados a uma Rede, Loja e Representante, contendo um ou mais produtos com suas respectivas quantidades e preços negociados.


* **RF04 - Gestão de Status de Pedido:** O sistema deve registrar o ciclo de vida do pedido nos status: Negociação, Registrado, Aprovado, Faturado, Em Transporte, Entregue, Entregue Parcialmente, Recusado/Cortado e Cancelado.


* **RF05 - Auditoria de Visita e Gôndola:** O sistema deve registrar as visitas presenciais dos promotores nas lojas, capturando horário de início/fim, contagem de estoque e menor data de validade encontrada em gôndola.


* **RF06 - Alertas de Validade e Ruptura:** O sistema deve emitir relatórios/alertas prévios sobre lotes com vencimento próximo e produtos com estoque crítico/baixo giro.



### 3.2 Requisitos Não Funcionais

* **RNF01 - Integridade e Mecanismo de Armazenamento:** O sistema deve utilizar SGBD MySQL 8 com mecanismo InnoDB para garantir transações ACID e integridade referencial por chaves estrangeiras.


* **RNF02 - Codificação de Caracteres:** Uso exclusivo do charset `utf8mb4` com collation `utf8mb4_0900_ai_ci` para suporte a acentuação e símbolos.


* **RNF03 - Segurança e Proteção de Dados (LGPD):** O acesso a dados pessoais (CPF, e-mail, telefone de promotores e contatos) deve ser restrito ao Usuário Principal e totalmente auditado via log de acesso do SGBD (`audit_log` ou `mysql.general_log`), em conformidade com a Lei nº 13.709/2018 (art. 5º, I e art. 7º, V).


* **RNF04 - Restrição de Acesso Operacional:** Somente o Usuário Principal possui permissões globais de inserção, alteração e exclusão de cadastros. Registros de transações (pedidos e visitas) devem ser imutáveis para garantir histórico fiscal e auditoria.



---

## 4. Regras de Negócio

* **Regras Operacionais:**
* **RN01 (Dependência Cadastral):** Não é permitido emitir pedidos para clientes ou produtos não cadastrados previamente.


* **RN02 (Unicidade de Documentos):** O CNPJ é único e obrigatório para cada Fabricante, Rede e Loja física (filiais possuem CNPJ próprio). O CPF é único e obrigatório para Promotores.


* **RN03 (Itens de Pedido):** Todo pedido de venda deve conter obrigatoriamente no mínimo um item.


* **RN04 (Restrição do Preço Praticado):** O preço unitário negociado em pedido não pode ser inferior ao preço mínimo de tabela aprovado para o produto.


* **RN05 (Bloqueio de Vencidos):** Produtos com lote vencido não podem ser comercializados, faturados ou repostos em gôndola.


* **RN06 (Regras de Recebimento):** Cada Loja/Filial possui regras específicas de entrega e recebimento (janelas de horário, prazos e documentação) que devem ser registradas no pedido.




* **Restrições Organizacionais:**
* **RO01 (Fluxo Administrativo Engessado do Varejo):** A integração com redes de supermercado exige estrita observância do fluxo sequencial: Comercial → Cadastro → Fiscal → Pricing → Produtos → Logística.


* **RO02 (Imutabilidade do Histórico Fiscal/Comercial):** Por exigência legal e fiscal, registros de pedidos e histórico de auditoria de visitas não podem ser deletados do sistema.





---

## 5. Dicionário de Dados Conceitual (Preliminar)

### FABRICANTE

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_FABRICANTE | Identificador único do fabricante | Chave Primária (PK), obrigatório.

 |
| NM_RAZAO_SOCIAL | Razão social completa da empresa | Obrigatório.

 |
| NM_FANTASIA | Nome comercial/marca do fabricante | Obrigatório.

 |
| CD_CNPJ | CNPJ do fabricante | Obrigatório, chave única (14 dígitos).

 |
| CD_INSCRICAO_ESTADUAL | Inscrição estadual da indústria | Obrigatório.

 |
| DS_ENDERECO | Endereço completo da sede | Obrigatório.

 |
| CD_TELEFONE | Telefone corporativo principal | Obrigatório.

 |
| DS_EMAIL | E-mail do departamento comercial | Obrigatório, formato de e-mail válido.

 |
| DT_INICIO_REPRESENTACAO | Data de início do contrato comercial | Obrigatório.

 |

### PRODUTO

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_PRODUTO | Identificador único do produto | Chave Primária (PK), obrigatório.

 |
| ID_FABRICANTE | Vínculo com a fábrica fornecedora | Chave Estrangeira (FK), obrigatório.

 |
| CD_EAN | Código de barras do produto | Obrigatório, chave única.

 |
| CD_NCM | Código fiscal NCM | Obrigatório (8 dígitos).

 |
| DS_PRODUTO | Descrição detalhada do item | Obrigatório.

 |
| NM_MARCA | Marca comercial | Obrigatório.

 |
| TP_EMBALAGEM | Tipo de acondicionamento | Obrigatório (Ex: Caixa, Pacote, Fardo).

 |
| QT_PESO_BRUTO | Peso bruto em kg | Obrigatório, numérico positivo.

 |
| QT_PESO_LIQUIDO | Peso líquido em kg | Obrigatório, menor ou igual ao peso bruto.

 |
| TP_UNIDADE_MEDIDA | Unidade comercial padrão | Obrigatório (Ex: UN, KG, CX).

 |
| VL_PRECO_TABELA | Preço de tabela do fabricante | Obrigatório, valor numérico positivo.

 |
| TP_REGIME_TRIBUTARIO | Classificação tributária fiscal | Obrigatório.

 |
| IN_ATIVO | Status de operação do item | Obrigatório, booleano (1-Ativo, 0-Inativo).

 |

### LOTE

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_LOTE | Identificador único do lote | Chave Primária (PK), obrigatório.

 |
| ID_PRODUTO | Vínculo com o produto | Chave Estrangeira (FK), obrigatório.

 |
| CD_NUMERO_LOTE | Código do lote emitido pela fábrica | Obrigatório.

 |
| QT_PRODUZIDA | Quantidade produzida na remessa | Obrigatório, numérico maior que zero.

 |
| DT_FABRICACAO | Data de fabricação do lote | Obrigatório, menor ou igual à data atual.

 |
| DT_VALIDADE | Data de validade do produto | Obrigatório, maior que a data de fabricação.

 |

### SUPER_MERCADO (Rede Matriz)

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_REDE | Identificador único da rede varejista | Chave Primária (PK), obrigatório.

 |
| NM_RAZAO_SOCIAL | Razão social oficial da rede | Obrigatório.

 |
| NM_FANTASIA | Nome comercial/marca da rede | Obrigatório.

 |
| CD_CNPJ | CNPJ da matriz compradora | Obrigatório, chave única.

 |
| CD_INSCRICAO_ESTADUAL | Inscrição estadual fiscal | Obrigatório.

 |
| DS_ENDERECO | Endereço oficial da matriz | Obrigatório.

 |
| CD_TELEFONE | Telefone comercial da central | Obrigatório.

 |
| NM_REPRESENTANTE_GERAL | Nome do gestor/comprador principal | Obrigatório.

 |
| DS_PORTAL_URL | Link do portal de pedidos da rede | Opcional.

 |
| DT_INICIO_RELACIONAMENTO | Data do primeiro cadastro/atendimento | Obrigatório.

 |

### LOJA (Filial)

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_LOJA | Identificador único da filial física | Chave Primária (PK), obrigatório.

 |
| ID_REDE | Vínculo com a rede/matriz proprietária | Chave Estrangeira (FK), obrigatório.

 |
| CD_CODIGO_LOJA_REDE | Código interno da filial na rede | Obrigatório.

 |
| NM_LOJA | Nome de identificação da unidade | Obrigatório (Ex: "Loja 02 - Centro").

 |
| CD_CNPJ | CNPJ próprio da filial física | Obrigatório, chave única.

 |
| DS_ENDERECO | Endereço físico completo da loja | Obrigatório para logística de entrega.

 |
| CD_TELEFONE | Telefone do setor de recebimento | Obrigatório.

 |
| IN_ATIVA | Indicador de unidade em operação | Obrigatório, booleano.

 |

### CONTATO

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_CONTATO | Identificador único do contato | Chave Primária (PK), obrigatório.

 |
| ID_REDE | Vínculo com a rede compradora | Chave Estrangeira (FK), obrigatório.

 |
| ID_LOJA | Vínculo opcional com filial específica | Chave Estrangeira (FK), opcional.

 |
| NM_CONTATO | Nome do profissional chave | Obrigatório.

 |
| DS_SETOR | Setor de atuação | Obrigatório (Ex: Fiscal, Compras, Logística).

 |
| DS_CARGO | Cargo desempenhado na empresa | Obrigatório.

 |
| CD_TELEFONE | Telefone ou ramal direto | Obrigatório.

 |
| DS_EMAIL | E-mail corporativo | Obrigatório.

 |

### PROMOTOR

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_PROMOTOR | Identificador único do promotor | Chave Primária (PK), obrigatório.

 |
| NM_PROMOTOR | Nome completo do repositor | Obrigatório.

 |
| CD_CPF | Documento CPF do profissional | Obrigatório, chave única (11 dígitos).

 |
| CD_TELEFONE | Telefone celular/WhatsApp | Obrigatório.

 |
| NM_EMPRESA_TERCEIRIZADA | Nome da agência terceirizada | Obrigatório.

 |

### REPRESENTANTE

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_REPRESENTANTE | Identificador do representante comercial | Chave Primária (PK), obrigatório.

 |

### PEDIDO

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_PEDIDO | Identificador do pedido de venda | Chave Primária (PK), obrigatório.

 |
| ID_REDE | Vínculo com a rede cliente | Chave Estrangeira (FK), obrigatório.

 |
| ID_REPRESENTANTE | Vínculo com o representante emissor | Chave Estrangeira (FK), obrigatório.

 |
| ID_LOJA | Vínculo com a loja recebedora | Chave Estrangeira (FK), obrigatório.

 |
| DT_PEDIDO | Data de emissão da venda | Obrigatório.

 |
| DT_PREVISTA_ENTREGA | Data acordada para entrega | Opcional.

 |
| VL_VALOR_TOTAL | Valor consolidado do pedido | Obrigatório, soma dos itens.

 |
| DS_CONDICAO_PAGAMENTO | Prazo e regra financeira | Obrigatório (Ex: 30/60 dias).

 |
| TP_STATUS_TOTAL | Estado no ciclo de vida da venda | Obrigatório (Domínio restrito aos status válidos).

 |
| DS_OBSERVACAO | Regras de entrega ou observações | Opcional.

 |
| ID_PRODUTO | Produto associado (por item) | Chave Estrangeira (FK), obrigatório por item.

 |
| QT_PEDIDA | Quantidade do item no pedido | Numérico positivo, obrigatório por item.

 |
| VL_PRECO_NEGOCIADO | Preço fechado para o item | Numérico positivo, não inferior ao mínimo.

 |

### VISITA

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| ID_VISITA | Identificador da auditoria presencial | Chave Primária (PK), obrigatório.

 |
| ID_PROMOTOR | Vínculo com o promotor terceirizado | Chave Estrangeira (FK), obrigatório.

 |
| ID_LOJA | Vínculo com a loja auditada | Chave Estrangeira (FK), obrigatório.

 |
| DT_VISITA | Data do atendimento em loja | Obrigatório.

 |
| HR_INICIO | Horário de chegada do promotor | Obrigatório.

 |
| HR_FIM | Horário de saída do promotor | Obrigatório, maior que horário de início.

 |
| DS_OBSERVACAO | Relato de ocorrências em gôndola | Opcional.

 |
| ID_PRODUTO | Item verificado (por auditoria) | Chave Estrangeira (FK), opcional por item.

 |
| QT_ESTOQUE_GONDOLA | Contagem de peças em gôndola/estoque | Numérico, opcional por item.

 |
| DT_VALIDADE_ENCONTRADA | Menor validade apurada em loja | Data, opcional por item.

 |

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

* **Entidades e Atributos Reconhecidos:**
* **FABRICANTE:** Entidade detentora dos produtos alimentícios e contratante da representação.


* **PRODUTO:** Itens do catálogo comercial com dados fiscais, físicos e preço base.


* **LOTE:** Rastreabilidade de produção, controle de validade e datas.


* **SUPER_MERCADO:** Entidade matriz compradora no varejo.


* **LOJA:** Filial física compradora e ponto de entrega/reposição de produtos.


* **CONTATO:** Pessoas físicas interlocutoras de cada setor (Fiscal, Pricing, Compras, Logística).


* **PROMOTOR:** Agente terceirizado responsável pelo abastecimento em gôndola.


* **REPRESENTANTE:** Agente comercial responsável pelas negociações e emissão de pedidos.


* **PEDIDO:** Transação comercial consolidada entre fabricante, representante, rede e loja.


* **VISITA:** Atendimento presencial para conferência de estoque de gôndola e validades.




* **Relacionamentos e Cardinalidades:**
* **FABRICANTE fornece PRODUTO (1:N):** Um fabricante fornece diversos produtos cadastrados; um produto pertence a exatamente um fabricante.


* **FABRICANTE possui REPRESENTANTE (1:N) / envia PROMOTOR (N:M):** Um fabricante vincula representantes e atua com múltiplos promotores.


* **SUPER_MERCADO possui LOJA (1:N):** Uma matriz de supermercado possui uma ou mais lojas/filiais físicas.


* **SUPER_MERCADO possui CONTATO (1:N):** A rede possui múltiplos contatos por setor.


* **PRODUTO gera LOTE (1:N):** Um produto possui múltiplos lotes fabricados ao longo do tempo.


* **LOJA recebe PEDIDO (1:N):** Uma loja recebe múltiplos pedidos de venda.


* **REPRESENTANTE fecha PEDIDO (1:N):** Um representante registra diversos pedidos.


* **PROMOTOR realiza VISITA (1:N) em LOJA (1:N):** Um promotor realiza várias visitas; uma loja recebe auditorias periódicas.


* **PEDIDO contém ITEM_PEDIDO (1:N) de PRODUTO (1:N):** Um pedido engloba múltiplos produtos negociados em quantidades e preços específicos.


* **VISITA realiza AUDITORIA_GON DOLA (0:N) de PRODUTO (1:N):** Durante a visita, podem ser checados zero ou múltiplos produtos em gôndola.





---

## 7. Diagrama Entidade-Relacionamento (DER)

*(O Diagrama Entidade-Relacionamento Lógico correspondente encontra-se anexado ao repositório no arquivo `Lógico_1.png`)*

```
+------------------+         1:N         +------------------+         1:N         +------------------+
|    FABRICANTE    |-------------------->|     PRODUTO      |-------------------->|       LOTE       |
+------------------+                     +------------------+                     +------------------+
         |                                         |                                       |
         | 1:N                                     | 1:N                                   | (auditoria)
         v                                         v                                       v
+------------------+                     +------------------+                     +------------------+
|  REPRESENTANTE   |                     |   ITEM_PEDIDO    |                     | AUDITORIA_GONDOLA|
+------------------+                     +------------------+                     +------------------+
         |                                         ^                                       ^
         | 1:N                                     | 1:N                                   | 0:N
         v                                         |                                       |
+------------------+ 1:N                 +------------------+                     +------------------+
|      PEDIDO      |-------------------->|  SUPER_MERCADO   |                     |      VISITA      |
+------------------+                     +------------------+                     +------------------+
         |                                         |                                       ^
         | 1:N                                     | 1:N                                   | 1:N
         v                                         v                                       |
+------------------+ 1:N                 +------------------+ 1:N                     +------------------+
|       LOJA       |<--------------------|     CONTATO      |                     |     PROMOTOR     |
+------------------+                     +------------------+                     +------------------+

```

---

## 8. Justificativa Técnica

A modelagem do sistema da Letty Gestão Comercial foi concebida para sanar diretamente os gargalos de visibilidade do estoque e rastreabilidade identificados no levantamento de requisitos:

1. **Separação entre Matriz (`SUPER_MERCADO`) e Filial (`LOJA`):** A escolha de desacoplar a rede matriz das lojas físicas é fundamental para a realidade do varejo alimentício. A negociação e os contatos de setores (Fiscal, Compras) ocorrem no âmbito da matriz, enquanto o faturamento, a entrega logística, a apuração de estoque e a atuação dos promotores ocorrem exclusivamente na filial física.


2. **Modelagem do `LOTE` desvinculada do `PEDIDO` direto:** Os lotes de produção pertencem à entidade `PRODUTO`. Essa abstração permite que o estoque de determinado lote seja rastreado em gôndola durante as auditorias da `VISITA` sem forçar o cliente/comprador a escolher lotes na fase de negociação do `PEDIDO`.


3. **Composição Multitem em `PEDIDO` e `VISITA`:** O uso do agrupamento fracionado de itens em `PEDIDO` (`ITEM_PEDIDO`) garante que uma única venda contenha múltiplos produtos com preços e quantidades negociados independentes. Da mesma forma, a `VISITA` permite auditoria em formato iterativo (`0{/AUDITORIA_GON DOLA/}n`), possibilitando ao promotor registrar contagem de estoque e validades de múltiplos itens em uma única passagem pelo PDV.


4. **Simplificação da Entidade `REPRESENTANTE`:** Como a empresa conta com estrutura enxuta voltada à gestão comercial direta, a entidade `REPRESENTANTE` foi mantida como Chave Primária identificadora simples no modelo lógico para garantir integridade e expansões futuras, sem overhead de atributos redundantes nesta etapa.



---

## 9. Uso de Inteligência Artificial

| Item | O que registrar |
| --- | --- |
| **Ferramenta e etapa** | Gemini 2.5 — Utilizado na etapa de estruturação do `README.md`, formatação e consolidação das informações do Dicionário de Dados e Entrevistas de Requisitos. |
| **Motivação** | Padronizar a documentação técnica conforme o template oficial do projeto e estruturar os dados levantados em campo sem omissão de regras ou atributos. |
| **Prompt(s) utilizados** | "Com base nos dados fornecidos quero que realize a substituição dos dados deste read me com base nas regras propostas dentro dele." |
| **Resposta recebida** | Texto estruturado preenchendo as 9 seções do esqueleto do README com base nos arquivos PDF e imagens fornecidos sobre a empresa Letty Gestão Comercial. |
| **Fontes consultadas e verificadas** | Comparação direta com o documento `Dicionário_de_Dados_letty_quinta_Vs_2.1.pdf` e com as transcrições das perguntas e respostas em `Perguntas Gestão Comercial - Ednilson (1).pdf`. |
| **Trechos rejeitados ou corrigidos** | Foram ajustados nomes de entidades truncados no OCR original (ex: correção de `SUPER_MERCADO` e `AUDITORIA_GON DOLA`) para alinhar estritamente às convenções de banco do projeto. |
| **Justificativa da escolha final** | A estrutura gerada respeita com precisão as cardinalidades, convenções de chave, normas de proteção de dados (LGPD) e o fluxo do SGBD MySQL 8 estipulado na documentação técnica. |
| **Reflexão crítica** | A ferramenta facilita o alinhamento sintático do markdown e tabelas, mas exigiu validação humana rigorosa quanto às regras de negócio específicas da empresa e conferência da cardinalidade dos relacionamentos. |
