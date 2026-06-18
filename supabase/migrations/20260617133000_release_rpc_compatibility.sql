-- Release RPC compatibility layer for the Flutter Android app.
-- This maps the current FI-YOU production schema to the JSON contract used by
-- SupabaseSelfDiscoveryRepository without exposing table internals to Flutter.

create or replace function public.get_my_profile()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object(
    'id', p.user_id::text,
    'displayName', p.nickname,
    'avatarUrl', null,
    'timezone', 'Asia/Seoul',
    'onboardingCompleted', p.onboarding_completed
  )
  from public.profiles p
  where p.user_id = auth.uid();
$$;

create or replace function public.upsert_my_profile(
  display_name text,
  avatar_url text default null,
  timezone text default 'Asia/Seoul'
)
returns jsonb
language sql
security invoker
set search_path = public
as $$
  insert into public.profiles (user_id, nickname, preferred_language, onboarding_completed, updated_at)
  values (auth.uid(), nullif(display_name, ''), 'ko', true, now())
  on conflict (user_id) do update
    set nickname = excluded.nickname,
        onboarding_completed = true,
        updated_at = now()
  returning jsonb_build_object(
    'id', user_id::text,
    'displayName', nickname,
    'avatarUrl', avatar_url,
    'timezone', coalesce(timezone, 'Asia/Seoul'),
    'onboardingCompleted', onboarding_completed
  );
$$;

create or replace function public.get_next_question()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with next_question as (
    select q.*
    from public.questions q
    where q.active
      and q.question_set in ('onboarding_required', 'basic_free')
      and not exists (
        select 1
        from public.answers a
        where a.user_id = auth.uid()
          and a.question_id = q.id
      )
    order by
      case q.question_set when 'onboarding_required' then 0 else 1 end,
      q.sequence
    limit 1
  ),
  fallback_question as (
    select q.*
    from public.questions q
    where q.active
      and q.question_set in ('onboarding_required', 'basic_free')
    order by
      case q.question_set when 'onboarding_required' then 0 else 1 end,
      q.sequence
    limit 1
  ),
  picked as (
    select * from next_question
    union all
    select * from fallback_question
    where not exists (select 1 from next_question)
    limit 1
  )
  select jsonb_build_object(
    'id', p.id::text,
    'prompt', p.prompt,
    'category', p.question_set,
    'questionType', 'single_choice',
    'subtitle', p.helper_text,
    'optionalTextPrompt', '덧붙이고 싶은 말이 있나요?',
    'whyThisQuestion', '현재까지의 기록 흐름을 더 선명하게 보기 위한 질문이에요.',
    'choices', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', o.id::text,
          'label', o.label,
          'signalHints', coalesce(o.axis_weights->'signals', '[]'::jsonb)
        )
        order by o.sequence
      )
      from public.question_options o
      where o.question_id = p.id
    ), '[]'::jsonb)
  )
  from picked p;
$$;

create or replace function public.upsert_my_answer(
  question_id uuid,
  answer_text text default null,
  answer_value jsonb default '{}'::jsonb
)
returns jsonb
language sql
security invoker
set search_path = public
as $$
  insert into public.answers (
    user_id,
    question_id,
    selected_option_id,
    optional_text,
    skipped,
    answered_at,
    updated_at
  )
  values (
    auth.uid(),
    question_id,
    nullif(answer_value->'choices'->>0, '')::uuid,
    nullif(answer_text, ''),
    false,
    now(),
    now()
  )
  on conflict (user_id, question_id) do update
    set selected_option_id = excluded.selected_option_id,
        optional_text = excluded.optional_text,
        skipped = false,
        updated_at = now()
  returning jsonb_build_object(
    'id', id::text,
    'questionId', question_id::text,
    'answeredAt', answered_at
  );
$$;

create or replace function public.get_my_diaries(from_date date default null, to_date date default null)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', d.id::text,
      'entryDate', d.entry_date::text,
      'title', d.title,
      'body', d.body,
      'moodScore', null,
      'tags', '[]'::jsonb,
      'createdAt', d.created_at,
      'updatedAt', d.updated_at
    )
    order by d.entry_date desc, d.created_at desc
  ), '[]'::jsonb)
  from public.diaries d
  where d.user_id = auth.uid()
    and d.deleted_at is null
    and (from_date is null or d.entry_date >= from_date)
    and (to_date is null or d.entry_date <= to_date);
$$;

create or replace function public.get_my_diary(id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object(
    'id', d.id::text,
    'entryDate', d.entry_date::text,
    'title', d.title,
    'body', d.body,
    'moodScore', null,
    'tags', '[]'::jsonb,
    'createdAt', d.created_at,
    'updatedAt', d.updated_at
  )
  from public.diaries d
  where d.user_id = auth.uid()
    and d.id = $1
    and d.deleted_at is null;
$$;

create or replace function public.create_my_diary(
  entry_date date,
  title text,
  body text,
  mood_score integer default null,
  tags text[] default '{}'::text[]
)
returns jsonb
language sql
security invoker
set search_path = public
as $$
  insert into public.diaries (user_id, entry_date, title, body, mood_label, updated_at)
  values (auth.uid(), entry_date, coalesce(nullif(title, ''), 'Diary'), body, mood_score::text, now())
  returning jsonb_build_object(
    'id', id::text,
    'entryDate', entry_date::text,
    'title', title,
    'body', body,
    'moodScore', mood_score,
    'tags', coalesce(to_jsonb(tags), '[]'::jsonb),
    'createdAt', created_at,
    'updatedAt', updated_at
  );
$$;

create or replace function public.update_my_diary(
  id uuid,
  entry_date date,
  title text,
  body text,
  mood_score integer default null,
  tags text[] default '{}'::text[]
)
returns jsonb
language sql
security invoker
set search_path = public
as $$
  update public.diaries d
  set entry_date = update_my_diary.entry_date,
      title = coalesce(nullif(update_my_diary.title, ''), 'Diary'),
      body = update_my_diary.body,
      mood_label = update_my_diary.mood_score::text,
      updated_at = now()
  where d.user_id = auth.uid()
    and d.id = update_my_diary.id
    and d.deleted_at is null
  returning jsonb_build_object(
    'id', d.id::text,
    'entryDate', d.entry_date::text,
    'title', d.title,
    'body', d.body,
    'moodScore', update_my_diary.mood_score,
    'tags', coalesce(to_jsonb(update_my_diary.tags), '[]'::jsonb),
    'createdAt', d.created_at,
    'updatedAt', d.updated_at
  );
$$;

create or replace function public.delete_my_diary(id uuid)
returns void
language sql
security invoker
set search_path = public
as $$
  update public.diaries d
  set deleted_at = now(),
      updated_at = now()
  where d.user_id = auth.uid()
    and d.id = $1
    and d.deleted_at is null;
$$;

create or replace function public.get_my_u_map()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with latest as (
    select *
    from public.u_map_snapshots s
    where s.user_id = auth.uid()
    order by s.created_at desc
    limit 1
  )
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'code', scores.key,
      'label', scores.key,
      'summary', coalesce(l.summary, '현재까지의 기록에서 보이는 흐름이에요.'),
      'score', coalesce((scores.value)::numeric, 0),
      'clarity', coalesce((l.axis_clarity->>scores.key)::numeric, 0),
      'flow', 'emerging',
      'signals', l.dominant_signals,
      'nextDepth', null
    )
    order by scores.key
  ), '[]'::jsonb)
  from latest l
  cross join lateral jsonb_each_text(l.axis_scores) as scores(key, value);
$$;

create or replace function public.get_current_signature(signature_type text default 'primary')
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select null::jsonb;
$$;

create or replace function public.get_my_star_balance()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object('balance', coalesce(sum(l.amount), 0))
  from public.star_ledger l
  where l.user_id = auth.uid();
$$;

create or replace function public.get_my_star_ledger()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select coalesce(jsonb_agg(to_jsonb(l) order by l.created_at desc), '[]'::jsonb)
  from public.star_ledger l
  where l.user_id = auth.uid();
$$;

create or replace function public.get_my_entitlements()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', e.id::text,
      'productId', e.entitlement_type,
      'status', 'active',
      'expiresAt', null
    )
    order by e.unlocked_at desc
  ), '[]'::jsonb)
  from public.entitlements e
  where e.user_id = auth.uid();
$$;

create or replace function public.get_store_products(platform text default 'android')
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_array(
    jsonb_build_object('id','fiyou_star_100','title','Star 100','description','추가 탐색에 사용할 수 있는 Star입니다.','priceLabel','Google Play','kind','consumable','starAmount',100),
    jsonb_build_object('id','fiyou_star_300','title','Star 300','description','조금 더 넓은 탐색에 사용할 수 있는 Star입니다.','priceLabel','Google Play','kind','consumable','starAmount',330),
    jsonb_build_object('id','fiyou_star_700','title','Star 700','description','확장 리포트와 추가 탐색에 사용할 수 있는 Star입니다.','priceLabel','Google Play','kind','consumable','starAmount',800),
    jsonb_build_object('id','fiyou_star_1500','title','Star 1500','description','깊은 탐색 흐름을 위해 사용할 수 있는 Star입니다.','priceLabel','Google Play','kind','consumable','starAmount',1800),
    jsonb_build_object('id','fiyou_report_umap_deep_1','title','U-Map 확장 리포트','description','현재까지의 기록을 더 넓게 정리한 참고 리포트입니다.','priceLabel','Google Play','kind','non_consumable'),
    jsonb_build_object('id','fiyou_report_signature_deep_1','title','Signature 확장 리포트','description','반복되는 표현과 선택의 흐름을 더 길게 정리합니다.','priceLabel','Google Play','kind','non_consumable'),
    jsonb_build_object('id','fiyou_report_relation_1','title','관계 흐름 리포트','description','내 기록 속 관계 단서를 참고용으로 정리합니다.','priceLabel','Google Play','kind','non_consumable'),
    jsonb_build_object('id','fiyou_report_past_self_1','title','지난 나 돌아보기 리포트','description','시간이 지나며 달라진 기록 흐름을 정리합니다.','priceLabel','Google Play','kind','non_consumable'),
    jsonb_build_object('id','fiyou_plus','title','FI-YOU Plus','description','추가 기록 정리와 확장 탐색을 위한 구독입니다.','priceLabel','Google Play','kind','subscription')
  );
$$;

create or replace function public.get_my_relations()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', r.id::text,
      'label', r.name,
      'status', r.status,
      'note', r.relationship_type
    )
    order by r.created_at desc
  ), '[]'::jsonb)
  from public.relations r
  where r.user_id = auth.uid()
    and r.archived_at is null;
$$;

create or replace function public.create_my_relation(label text, note text default null)
returns jsonb
language sql
security invoker
set search_path = public
as $$
  insert into public.relations (user_id, name, relationship_type, status, updated_at)
  values (auth.uid(), label, coalesce(nullif(note, ''), 'record_based'), 'draft', now())
  returning jsonb_build_object(
    'id', id::text,
    'label', name,
    'status', status,
    'note', relationship_type
  );
$$;

create or replace function public.get_my_reports()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select '[]'::jsonb;
$$;

create or replace function public.get_my_report(id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select null::jsonb;
$$;

create or replace function public.get_paid_report_access(product_id text)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object('hasAccess', false, 'productId', product_id);
$$;

revoke execute on function public.get_my_profile() from public, anon;
revoke execute on function public.upsert_my_profile(text, text, text) from public, anon;
revoke execute on function public.get_next_question() from public, anon;
revoke execute on function public.upsert_my_answer(uuid, text, jsonb) from public, anon;
revoke execute on function public.get_my_diaries(date, date) from public, anon;
revoke execute on function public.get_my_diary(uuid) from public, anon;
revoke execute on function public.create_my_diary(date, text, text, integer, text[]) from public, anon;
revoke execute on function public.update_my_diary(uuid, date, text, text, integer, text[]) from public, anon;
revoke execute on function public.delete_my_diary(uuid) from public, anon;
revoke execute on function public.get_my_u_map() from public, anon;
revoke execute on function public.get_current_signature(text) from public, anon;
revoke execute on function public.get_my_star_balance() from public, anon;
revoke execute on function public.get_my_star_ledger() from public, anon;
revoke execute on function public.get_my_entitlements() from public, anon;
revoke execute on function public.get_store_products(text) from public, anon;
revoke execute on function public.get_my_relations() from public, anon;
revoke execute on function public.create_my_relation(text, text) from public, anon;
revoke execute on function public.get_my_reports() from public, anon;
revoke execute on function public.get_my_report(uuid) from public, anon;
revoke execute on function public.get_paid_report_access(text) from public, anon;

grant execute on function public.get_my_profile() to authenticated;
grant execute on function public.upsert_my_profile(text, text, text) to authenticated;
grant execute on function public.get_next_question() to authenticated;
grant execute on function public.upsert_my_answer(uuid, text, jsonb) to authenticated;
grant execute on function public.get_my_diaries(date, date) to authenticated;
grant execute on function public.get_my_diary(uuid) to authenticated;
grant execute on function public.create_my_diary(date, text, text, integer, text[]) to authenticated;
grant execute on function public.update_my_diary(uuid, date, text, text, integer, text[]) to authenticated;
grant execute on function public.delete_my_diary(uuid) to authenticated;
grant execute on function public.get_my_u_map() to authenticated;
grant execute on function public.get_current_signature(text) to authenticated;
grant execute on function public.get_my_star_balance() to authenticated;
grant execute on function public.get_my_star_ledger() to authenticated;
grant execute on function public.get_my_entitlements() to authenticated;
grant execute on function public.get_store_products(text) to authenticated;
grant execute on function public.get_my_relations() to authenticated;
grant execute on function public.create_my_relation(text, text) to authenticated;
grant execute on function public.get_my_reports() to authenticated;
grant execute on function public.get_my_report(uuid) to authenticated;
grant execute on function public.get_paid_report_access(text) to authenticated;
