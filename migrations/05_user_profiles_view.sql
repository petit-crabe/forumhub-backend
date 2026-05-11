-- Migration 05 — user_profiles
-- Table miroir de auth.users exposant l'email dans le schéma public.
-- Remplace une vue SECURITY INVOKER/DEFINER qui ne permettait pas
-- d'accorder SELECT sur auth.users au rôle authenticated.

-- ── Table ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL
);

-- ── RLS ───────────────────────────────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_authenticated"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (true);

GRANT SELECT ON public.user_profiles TO authenticated;

-- ── Trigger : sync au signup ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── Backfill des utilisateurs existants ───────────────────────────────────────
INSERT INTO public.user_profiles (id, email)
SELECT id, email FROM auth.users
ON CONFLICT (id) DO NOTHING;
