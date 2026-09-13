-- Regras de acesso (RLS) da galeria
-- Rodar uma vez no Supabase: SQL Editor → New query → colar tudo → Run.
--
-- Visitantes (anon):   ver desenhos, ver e criar comentários, ver imagens
-- Família (logada):    tudo acima + criar/editar/apagar desenhos,
--                      apagar comentários, enviar/apagar imagens

-- 1. Remove as regras antigas dessas tabelas e do bucket "drawings"
do $$
declare p record;
begin
  for p in
    select schemaname, tablename, policyname from pg_policies
    where (schemaname = 'public' and tablename in ('drawings', 'comments'))
       or (schemaname = 'storage' and tablename = 'objects'
           and (coalesce(qual, '') || coalesce(with_check, '')) like '%drawings%')
  loop
    execute format('drop policy %I on %I.%I', p.policyname, p.schemaname, p.tablename);
  end loop;
end $$;

-- 2. Garante que o RLS está ligado
alter table public.drawings enable row level security;
alter table public.comments enable row level security;

-- 3. Desenhos
create policy "drawings: todos podem ver"
  on public.drawings for select to anon, authenticated using (true);

create policy "drawings: familia cria"
  on public.drawings for insert to authenticated with check (true);

create policy "drawings: familia edita"
  on public.drawings for update to authenticated using (true) with check (true);

create policy "drawings: familia apaga"
  on public.drawings for delete to authenticated using (true);

-- 4. Comentários
create policy "comments: todos podem ver"
  on public.comments for select to anon, authenticated using (true);

create policy "comments: todos podem comentar"
  on public.comments for insert to anon, authenticated
  with check (char_length(author) between 1 and 40 and char_length(text) between 1 and 300);

create policy "comments: familia apaga"
  on public.comments for delete to authenticated using (true);

-- 5. Imagens (bucket "drawings")
create policy "drawings bucket: todos podem ver"
  on storage.objects for select to anon, authenticated using (bucket_id = 'drawings');

create policy "drawings bucket: familia envia"
  on storage.objects for insert to authenticated with check (bucket_id = 'drawings');

create policy "drawings bucket: familia atualiza"
  on storage.objects for update to authenticated using (bucket_id = 'drawings');

create policy "drawings bucket: familia apaga"
  on storage.objects for delete to authenticated using (bucket_id = 'drawings');
