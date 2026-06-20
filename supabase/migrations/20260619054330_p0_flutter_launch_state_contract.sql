-- FI-YOU P0 Flutter launch-state contract.
-- This is the exact app-restart gate for SupabaseFiYouRepository.
-- Flutter handles the "no session" branch locally. This RPC is called only
-- after an authenticated Supabase session exists.

create or replace function public.get_flutter_launch_state()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_profile public.profiles;
  v_star_balance integer;
  v_required_count integer;
  v_required_answer_count integer;
  v_latest_snapshot_id uuid;
  v_profile_exists boolean;
  v_onboarding_complete boolean;
  v_route text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select *
    into v_profile
  from public.profiles
  where user_id = v_user;

  v_profile_exists := v_profile.user_id is not null;
  v_onboarding_complete := v_profile_exists and coalesce(v_profile.onboarding_completed, false);
  v_route := case when v_onboarding_complete then 'app_shell' else 'onboarding' end;

  select count(*)
    into v_required_count
  from public.questions
  where question_set = 'onboarding_required'
    and active = true;

  select count(distinct oa.question_id)
    into v_required_answer_count
  from public.onboarding_answers oa
  join public.questions q on q.id = oa.question_id
  where oa.user_id = v_user
    and q.question_set = 'onboarding_required'
    and q.active = true;

  select id
    into v_latest_snapshot_id
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  v_star_balance := public.get_star_balance();

  return jsonb_build_object(
    'userId', v_user,
    'route', v_route,
    'profileExists', v_profile_exists,
    'onboardingCompleted', v_onboarding_complete,
    'profile', case when v_profile_exists then to_jsonb(v_profile) else null end,
    'starBalance', coalesce(v_star_balance, 0),
    'requiredQuestionCount', coalesce(v_required_count, 0),
    'requiredAnswerCount', coalesce(v_required_answer_count, 0),
    'requiredQuestionsCompleted',
      coalesce(v_required_count, 0) > 0
      and coalesce(v_required_answer_count, 0) >= coalesce(v_required_count, 0),
    'latestUMapSnapshotId', v_latest_snapshot_id
  );
end;
$$;

create or replace function public.complete_onboarding(
  p_nickname text default null,
  p_preferred_language text default 'ko',
  p_birthday date default null,
  p_focus_area text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_required_count integer;
  v_answer_count integer;
  v_profile public.profiles;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  v_profile := public.upsert_profile(p_nickname, p_preferred_language, p_birthday, p_focus_area);

  if nullif(btrim(coalesce(v_profile.nickname, '')), '') is null then
    raise exception 'nickname_required';
  end if;

  select count(*)
    into v_required_count
  from public.questions
  where question_set = 'onboarding_required'
    and active = true;

  select count(distinct oa.question_id)
    into v_answer_count
  from public.onboarding_answers oa
  join public.questions q on q.id = oa.question_id
  where oa.user_id = v_user
    and q.question_set = 'onboarding_required'
    and q.active = true;

  update public.profiles
  set onboarding_completed = true,
      required_questions_completed_at = case
        when coalesce(v_required_count, 0) > 0
         and coalesce(v_answer_count, 0) >= coalesce(v_required_count, 0)
        then coalesce(required_questions_completed_at, now())
        else required_questions_completed_at
      end,
      updated_at = now()
  where user_id = v_user
  returning * into v_profile;

  return jsonb_build_object(
    'profile', to_jsonb(v_profile),
    'requiredQuestionCount', coalesce(v_required_count, 0),
    'requiredAnswerCount', coalesce(v_answer_count, 0),
    'requiredQuestionsCompleted',
      coalesce(v_required_count, 0) > 0
      and coalesce(v_answer_count, 0) >= coalesce(v_required_count, 0),
    'flutterLaunchState', public.get_flutter_launch_state()
  );
end;
$$;

revoke execute on function public.get_flutter_launch_state() from public, anon;
revoke execute on function public.complete_onboarding(text, text, date, text) from public, anon;

grant execute on function public.get_flutter_launch_state() to authenticated;
grant execute on function public.complete_onboarding(text, text, date, text) to authenticated;

comment on function public.get_flutter_launch_state()
  is 'Flutter app-restart route contract: call only after auth session exists; app_shell when profiles.onboarding_completed is true, otherwise onboarding.';

comment on function public.complete_onboarding(text, text, date, text)
  is 'Sets profiles.onboarding_completed as the app-restart source of truth. Required question counts are returned but do not block persistence.';
