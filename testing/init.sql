-- SPDX-License-Identifier: EUPL-1.2

create role lx with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role digimaks_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role lx_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role audit_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role wallet_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role issuer_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role idauth_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
grant lx to digimaks;

CREATE TABLESPACE digimaks_main OWNER digimaks LOCATION '/data/digimaks/main';
CREATE TABLESPACE digimaks_index OWNER digimaks LOCATION '/data/digimaks/index';
CREATE TABLESPACE digimaks_archive OWNER digimaks LOCATION '/data/digimaks/archive';
CREATE TABLESPACE digimaks_log OWNER digimaks LOCATION '/data/digimaks/log';
CREATE TABLESPACE lx_main OWNER lx LOCATION '/data/lx/main';
CREATE TABLESPACE lx_index OWNER lx LOCATION '/data/lx/index';
CREATE TABLESPACE lx_archive OWNER lx LOCATION '/data/lx/archive';
