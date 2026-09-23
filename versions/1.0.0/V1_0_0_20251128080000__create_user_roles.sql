-- create role user_write_role
do
$$
begin
  if not exists (SELECT * FROM pg_roles where rolname = 'user_write_role') then
     CREATE ROLE user_write_role NOINHERIT;
  end if;
end
$$;
-- create role user_read_role
do
$$
begin
  if not exists (SELECT * FROM pg_roles where rolname = 'user_read_role') then
     CREATE ROLE user_read_role NOINHERIT;
  end if;
end
$$;