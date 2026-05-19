-- Migration: previsto — constraint UNIQUE + políticas RLS
-- Rodar no painel SQL do Supabase (app.supabase.com → SQL Editor)
-- NOTA: a coluna id da tabela previsto é INTEGER (serial), não TEXT.

-- 1. Constraint UNIQUE para evitar duplicatas de previsto por empreiteiro/mês
ALTER TABLE previsto
  ADD CONSTRAINT previsto_mes_emp_uniq UNIQUE (mes, empreiteiro_id);

-- 2. Políticas RLS para o role anon (caso estejam faltando)
ALTER TABLE previsto ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "previsto_anon_select" ON previsto;
DROP POLICY IF EXISTS "previsto_anon_insert" ON previsto;
DROP POLICY IF EXISTS "previsto_anon_update" ON previsto;
DROP POLICY IF EXISTS "previsto_anon_delete" ON previsto;

CREATE POLICY "previsto_anon_select" ON previsto FOR SELECT TO anon USING (true);
CREATE POLICY "previsto_anon_insert" ON previsto FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "previsto_anon_update" ON previsto FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "previsto_anon_delete" ON previsto FOR DELETE TO anon USING (true);
