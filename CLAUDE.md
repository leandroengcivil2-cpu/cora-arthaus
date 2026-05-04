# CLAUDE.md — Corá Arthaus | Histograma de Obra

Arquivo de contexto persistente do projeto. Lido automaticamente pelo Claude Code a cada sessão. Sempre que uma regra de negócio nova for criada, atualizar este arquivo.

---

## 1. Visão geral

Sistema web single-page de Controle de Histograma da obra **Corá Arthaus** (Penha/SC), da incorporadora **ArtHaus**. Usado pelo gestor de obra e pela equipe de campo para registrar efetivo diário, comparar previsto x realizado e gerar medições.

- App de página única em HTML/JS puro (sem framework, sem bundler)
- Banco de dados e API: Supabase
- Hospedagem: Vercel (deploy automático ao commitar no GitHub)
- Idioma: português do Brasil em toda a interface

---

## 2. Stack e infraestrutura

- Frontend: arquivo único `index.html` (HTML + CSS + JS embutidos)
- Backend: Supabase (PostgreSQL + REST API)
- Bibliotecas via CDN: jsPDF, jspdf-autotable, Google Fonts (DM Sans + Playfair Display)
- Repositório: `leandroengcivil2-cpu/cora-arthaus`
- Deploy: Vercel, automático em cada push no `main`

### Credenciais Supabase

- URL: `https://punbnqvggogteoleicyf.supabase.co`
- Anon JWT (chave pública, embarcada no client): `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bmJucXZnZ29ndGVvbGVpY3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMjk2MzMsImV4cCI6MjA5MTgwNTYzM30.vau-IUCVHKGHiPK4qI2g7bh9y82C4qm7Jirn4SnyFfA`

---

## 3. Estrutura do banco

Todas as tabelas usam `id TEXT` como chave primária, gerado no client antes do POST.

- `empreiteiros`: id, nome, especialidade, cnpj
- `colaboradores`: id, nome, empreiteiro_id, funcao, cpf
- `chamadas`: id, data, colaborador_id, status (P/F/M), motivo — UNIQUE(data, colaborador_id)
- `previsto`: id, mes (YYYY-MM), empreiteiro_id, quantidade
- `funcoes`: id, nome
- `diarias`: id, data, colaborador_id, descricao — UNIQUE(data, colaborador_id)

Status na tabela chamadas: **P** (presente), **F** (falta), **M** (meio expediente).

---

## 4. Funcionalidades do app

1. **Início**: dashboard com efetivo do dia, total de colaboradores e empreiteiros, foto do prédio (lado direito ocupando 55% da largura)
2. **Chamada**: marcação diária P/F/M, com campo motivo obrigatório quando F ou M
3. **Painel BI**: gráfico previsto x realizado por empreiteiro (barras verticais lado a lado), tabela diária, gráfico de efetivo por função (barras verticais com nome completo dentro), exportação de PDFs mensal e diário
4. **Diárias**: seletor para adicionar colaborador no dia, descrição do serviço, exportação de PDF de medição mensal
5. **Cadastros**: empreiteiros (CNPJ obrigatório), colaboradores (CPF obrigatório), funções, previsto mensal

Navegação inferior fixa com 5 itens: Início, Chamada, BI, Diárias, Cadastros.

---

## 5. Regras de negócio (não violar nunca)

- Todos os campos de texto livres devem forçar **CAIXA ALTA**
- CNPJ obrigatório, único, 14 dígitos com máscara
- CPF obrigatório, único, 11 dígitos com máscara
- Selects nunca devem aplicar `toUpperCase` no `value` — corrompe os IDs
- Queries de período devem usar o **último dia real do mês** (nunca dia 31 fixo)
- Todo POST ao Supabase precisa gerar o campo `id` no client
- Filtro de empreiteiro do BI precisa ser respeitado em todos os PDFs
- Os termos "HD" e "homem-dia" não podem aparecer em nenhum lugar do app
- PDFs sempre com bloco de assinaturas (engenheiro + empreiteiro)
- Campo motivo só aparece quando status é F ou M
- Interface 100% em português do Brasil, sem emojis e sem termos em inglês

---

## 6. Design system

- Fundo principal: `#0a0a0a`
- Dourado ArtHaus (destaque, ações primárias): `#c9a96e`
- Verde semântico (atingiu meta, status positivo): `#22c55e` e `#4ade80`
- Vermelho semântico (abaixo da meta, status negativo): `#ef4444` e `#f87171`
- Amarelo (alerta): `#fbbf24`
- Tipografia: DM Sans no corpo, Playfair Display em destaques
- Layout: mobile-first, viewport de referência ~380px, sem overflow horizontal

---

## 7. Bugs recorrentes — revisar a cada alteração

1. Query com data fixa em dia 31 quebra meses de 28, 29 ou 30 dias (erro 400 do PostgreSQL)
2. `oninput` com `toUpperCase` em select de empreiteiro corrompe o `value`
3. POST sem campo `id` falha silenciosamente no Supabase
4. Chamar `render()` logo após salvar previsto faz o input perder o foco
5. Handlers re-registrados sem remoção causam eventos duplicados
6. Ao mudar o mês, garantir que os dados do mês anterior são limpos antes de carregar os novos

---

## 8. PDFs do sistema (3 tipos)

Todos respeitam o filtro de empreiteiro do BI e fecham com bloco de assinaturas.

- **ATA Mensal**: resumo por empreiteiro + detalhamento diário + ocorrências com motivo
- **Efetivo Diário**: tabela com nome, função, CPF, status, motivo + resumo por função
- **Medição de Diárias**: por empreiteiro, com datas, descrição do serviço e totais

---

## 9. Workflow de desenvolvimento

- Editar `index.html` direto na raiz do projeto
- Testar abrindo o arquivo no navegador (não precisa servidor local)
- Commits em português, mensagem descritiva (exemplo: `corrige query de chamadas para usar último dia do mês`)
- Push no `main` dispara deploy automático no Vercel
- Se houver alteração de schema no Supabase, gerar arquivo `migration.sql` separado e rodar manualmente no painel do Supabase

---

## 10. Como atender os pedidos mais comuns

### Pedido: revisar e corrigir bugs

1. Ler o `index.html` inteiro
2. Conferir item por item a lista de bugs recorrentes (seção 7)
3. Validar o CRUD de cada tabela (criar, ler, atualizar, deletar)
4. Confirmar que mudança de mês carrega os dados certos
5. No fim, listar os bugs encontrados e as correções aplicadas

### Pedido: adicionar nova funcionalidade

1. Confirmar antes em qual aba a feature entra (Início, Chamada, BI, Diárias ou Cadastros)
2. Confirmar se precisa de tabela ou coluna nova no Supabase
3. Manter o design system e todas as regras de negócio
4. Atualizar este CLAUDE.md se a feature criar uma regra nova

### Pedido: refatorar

1. O app é single-page por escolha do projeto — não quebrar em múltiplos arquivos sem confirmar
2. Priorizar redução de duplicação e clareza de leitura
3. Não introduzir frameworks, bundlers ou dependências novas sem confirmar

### Pedido: ajuste visual

1. Usar exclusivamente as cores do design system (seção 6)
2. Manter mobile-first
3. Sem emojis, sem ícones com texto em inglês

---

## 11. Entrega esperada de cada interação

- Código corrigido salvo direto no `index.html`
- Lista clara, em português, do que foi alterado
- SQL separado em `migration.sql` quando houver mudança de schema
- Sem comentários redundantes no código (o arquivo já está enxuto)
- Em caso de dúvida sobre regra de negócio, perguntar antes de assumir
