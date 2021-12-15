CREATE OR REPLACE FUNCTION public.pg_shadow_lookup(in i_username text, out username text, out password text) RETURNS record AS $$
BEGIN
    SELECT usename, passwd FROM pg_catalog.pg_shadow
    WHERE usename = i_username INTO username, password;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION public.pg_shadow_lookup(text) FROM public, pgbouncer;
GRANT EXECUTE ON FUNCTION public.pg_shadow_lookup(text) TO pgbouncer;
