create or replace function private.axis_seed()
returns table(axis text)
language sql
stable
set search_path = pg_temp
as $$
  values
    ('exploration'),
    ('independence'),
    ('relationship'),
    ('growth'),
    ('emotional_sensitivity'),
    ('stability'),
    ('initiative'),
    ('self_expression')
$$;

revoke execute on function public.delete_diary_with_star_revoke(uuid) from public, anon;
revoke execute on function public.revoke_diary_star(uuid) from public, anon;
revoke execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) from public, anon;
revoke execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) from public, anon, authenticated;

grant execute on function public.delete_diary_with_star_revoke(uuid) to authenticated;
grant execute on function public.revoke_diary_star(uuid) to authenticated;
grant execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) to authenticated;
grant execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) to service_role;
