create or replace function private.prevent_star_ledger_changes()
returns trigger
language plpgsql
set search_path = pg_temp
as $$
begin
  raise exception 'star_ledger is append-only';
end;
$$;
