-- Harden legacy SECURITY DEFINER RPCs that should not be directly callable
-- by Android clients during the official Google Play Billing release.
--
-- Supabase advisors flagged these functions because SECURITY DEFINER functions
-- in the exposed public schema can bypass RLS when executed through PostgREST.
-- The new Android release path uses client-safe RPCs plus Edge Functions for
-- payment/account-deletion authority, so these legacy privileged RPCs should
-- not remain executable by the authenticated role.

revoke execute on function public.delete_diary_with_star_revoke(uuid) from authenticated;
revoke execute on function public.finalize_relation_map(uuid, integer) from authenticated;
revoke execute on function public.grant_daily_attendance_star(date) from authenticated;
revoke execute on function public.grant_diary_star_once(uuid) from authenticated;
revoke execute on function public.reset_my_records() from authenticated;
revoke execute on function public.revoke_diary_star(uuid) from authenticated;
revoke execute on function public.spend_star(text, integer, text, uuid) from authenticated;
revoke execute on function public.start_free_explore(text, jsonb) from authenticated;
revoke execute on function public.unlock_entitlement(text, integer, uuid) from authenticated;
revoke execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) from authenticated;
