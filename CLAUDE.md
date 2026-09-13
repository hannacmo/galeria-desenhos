# Galeria de arte — Obras de Elisa e Cecília

Galeria online dos desenhos e cartinhas das sobrinhas Elisa e Cecília, mantida pela Tia Naninha (Hanna).

- Produção: https://galeriadesenhos.vercel.app/ e https://hannacmo.github.io/galeria-desenhos/
- Repositório: https://github.com/hannacmo/galeria-desenhos (branch `main`)
- Os dois sites publicam sozinhos a cada push na `main`.

## Estrutura

Site estático, sem build e sem framework.

| Arquivo | O que é |
|---|---|
| `index.html` | Todo o site: HTML, CSS e JS inline. As fotos de perfil (`ELISA_PHOTO`, `CECILIA_PHOTO`) estão embutidas em base64, por isso o arquivo é grande. |
| `manifest.webmanifest` + `icons/` | "Salvar como app" no celular: nome **Galeria de arte**, ícone 🏛️ sobre o amarelo `#ffd54f` |
| `supabase/politicas.sql` | Regras de acesso (RLS) do banco e do Storage. Já foi rodado no Supabase. |

Caminhos sempre relativos (`icons/...`, `manifest.webmanifest`), porque o GitHub Pages serve em `/galeria-desenhos/`.

## Backend: Supabase

Projeto `zmddfnxzexnvqqkikaqi`. A chave anon fica no `index.html`, e isso é normal: a proteção vem do RLS.
Até fev/2026 o backend era Firebase; migrou para Supabase em 13/09/2026.

- Tabela `drawings`: `id, title, artist ('Elisa' | 'Cecília'), message, url, storage_path, created_at`
- Tabela `comments`: `id, drawing_id, author (1–40), text (1–300), created_at`
- Bucket público `drawings` com as imagens

**Permissões** (`supabase/politicas.sql`):
- Visitante: ver desenhos, comentários e imagens; comentar.
- Família logada (Supabase Auth, e-mail e senha criados no painel): criar, editar e apagar desenhos; apagar comentários; enviar e apagar imagens.

Não existe senha no código. A área restrita usa `sb.auth.signInWithPassword`.

## Comportamentos do site

- Filtros "Todas as artistas", "Elisa" e "Cecília". Os filtros das meninas mostram um box centralizado com foto e emojis.
- Card: "💬 N" abre a lista de comentários; "✍️ + Comentar" abre só o formulário.
- Botão "📱 + Salvar como app no celular" no topo abre as instruções para iPhone e Android.
- Evento `pageshow` (página restaurada da memória): volta para "Todas" e recarrega a galeria.
- Todo texto vindo do banco passa por `esc()` antes de ir para `innerHTML`.

## Como trabalhar neste projeto

- Conversa e commits em português.
- Depois de mudar, testar localmente (`python3 -m http.server` na pasta; abrir via `file://` ou `data:` quebra `sessionStorage` e o Supabase Auth).
- Validar a sintaxe do `<script>` principal com `node --check`: um erro de sintaxe já deixou a galeria vazia.
- Commit e push direto na `main`, depois confirmar que Vercel e GitHub Pages atualizaram.
- Se o Vercel não criar deploy para um commit, envie um commit vazio (`git commit --allow-empty`). Usar "Redeploy" no painel publica o commit antigo.
- Para verificar permissões, testar com a chave anon usando só registros de teste e apagá-los depois; nunca arriscar desenhos reais.

## Histórico

- **fev/2026:** criação com Firebase; comentários, fotos de perfil e Google Analytics.
- **13/09/2026:**
  - migração para Supabase;
  - correção do erro de sintaxe que esvaziava a galeria;
  - escape contra XSS;
  - login real e RLS;
  - botão e ícone de app;
  - recarga no `pageshow`;
  - ajustes nos comentários e no box de perfil.
