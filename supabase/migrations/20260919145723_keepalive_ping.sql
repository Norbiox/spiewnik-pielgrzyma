-- Keepalive target for the external scheduler (n8n): free projects pause after
-- 7 days without activity. anon has no access to any table, so it needs a
-- callable endpoint that runs a real query. Reads no data, so nothing leaks.
create or replace function public.ping()
returns int language sql stable set search_path = '' as $$
  select 1;
$$;

grant execute on function public.ping() to anon;
