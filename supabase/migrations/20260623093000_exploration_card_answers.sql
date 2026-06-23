create table if not exists public.user_card_answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  card_history_id uuid not null references public.user_card_history(id) on delete cascade,
  selected_options text[] not null default '{}',
  user_note text,
  created_at timestamptz not null default now(),
  unique (user_id, card_history_id)
);

alter table public.user_card_answers enable row level security;

drop policy if exists "user card answers own select" on public.user_card_answers;
create policy "user card answers own select" on public.user_card_answers
  for select using (auth.uid() = user_id);

grant select on public.user_card_answers to authenticated;

create or replace function public.record_exploration_card_answer(
  p_card_history_id uuid,
  p_selected_options text[],
  p_user_note text default null
)
returns public.user_card_answers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_card public.user_card_history;
  v_answer public.user_card_answers;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if coalesce(array_length(p_selected_options, 1), 0) = 0 then
    raise exception 'selected_options_required';
  end if;

  select *
    into v_card
  from public.user_card_history
  where id = p_card_history_id
    and user_id = v_user;

  if v_card.id is null then
    raise exception 'card_history_not_found';
  end if;

  insert into public.user_card_answers(user_id, card_history_id, selected_options, user_note)
  values (
    v_user,
    p_card_history_id,
    p_selected_options,
    nullif(left(btrim(coalesce(p_user_note, '')), 300), '')
  )
  on conflict (user_id, card_history_id) do update
  set selected_options = excluded.selected_options,
      user_note = excluded.user_note
  returning * into v_answer;

  perform public.mark_exploration_card_answered(p_card_history_id);

  return v_answer;
end;
$$;

revoke execute on function public.record_exploration_card_answer(uuid, text[], text) from public, anon;
grant execute on function public.record_exploration_card_answer(uuid, text[], text) to authenticated;

comment on table public.user_card_answers
  is 'Stores user selections and optional notes for Exploration Experience cards.';
