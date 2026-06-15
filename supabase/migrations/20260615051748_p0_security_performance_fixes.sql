-- P0 advisor fixes.
-- Prevent anonymous callers from executing Star RPCs and add FK indexes.

revoke execute on function public.get_star_balance() from public, anon;
revoke execute on function public.grant_daily_attendance_star(date) from public, anon;
revoke execute on function public.grant_diary_star_once(uuid) from public, anon;
revoke execute on function public.spend_star(text, integer, text, uuid) from public, anon;
revoke execute on function public.unlock_entitlement(text, integer, uuid) from public, anon;
grant execute on function public.get_star_balance() to authenticated;
grant execute on function public.grant_daily_attendance_star(date) to authenticated;
grant execute on function public.grant_diary_star_once(uuid) to authenticated;
grant execute on function public.spend_star(text, integer, text, uuid) to authenticated;
grant execute on function public.unlock_entitlement(text, integer, uuid) to authenticated;
create index if not exists onboarding_answers_question_id_idx on public.onboarding_answers(question_id);
create index if not exists onboarding_answers_selected_option_id_idx on public.onboarding_answers(selected_option_id);
create index if not exists answers_question_id_idx on public.answers(question_id);
create index if not exists answers_selected_option_id_idx on public.answers(selected_option_id);
create index if not exists entitlements_source_ledger_id_idx on public.entitlements(source_ledger_id);
create index if not exists relations_user_id_idx on public.relations(user_id);
create index if not exists relation_answers_user_id_idx on public.relation_answers(user_id);
create index if not exists relation_answers_question_id_idx on public.relation_answers(question_id);
create index if not exists relation_answers_selected_option_id_idx on public.relation_answers(selected_option_id);
