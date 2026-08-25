-- Runs before the Pagila dump loads (files run in alphabetical order).
--
-- 1) The Pagila dump sets every object's OWNER to the role "postgres".
--    Our container superuser is "dbt", so we create that role up front,
--    otherwise the 100+ "ALTER ... OWNER TO postgres" lines would abort load.
do $$
begin
  if not exists (select from pg_roles where rolname = 'postgres') then
    create role postgres superuser;
  end if;
end $$;

-- 2) A read-only role used by the post-hook GRANT demo (Module 04).
do $$
begin
  if not exists (select from pg_roles where rolname = 'reporter') then
    create role reporter nologin;
  end if;
end $$;
