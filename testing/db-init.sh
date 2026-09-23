#!/bin/sh
set -e  # Šī komanda liks skriptam apstāties pie pirmās kļūdas

if [ -z "$DB_PORT" ]; then
    DB_PORT=5432
fi

if [ -z "$DB_HOST" ]; then
    if [ -z "$POSTGRES_HOST" ]; then
        echo "DB_HOST is not set"
        exit 1
    else
        DB_HOST=$POSTGRES_HOST
    fi
fi

export PGPASSWORD=$POSTGRES_PASSWORD
echo "READ IF STOP ON ERROR FLAG IS SET OFF IN ENV VARIABLE (assign default value ON if not OFF)"
if [ -z "$ON_ERROR_STOP" ]; then
    ON_ERROR_STOP=ON
    echo "ON_ERROR_STOP is not set, assigning default value ON"
    echo "ON_ERROR_STOP is set to $ON_ERROR_STOP"
fi

echo "INIT SCRIPT: PostgreSQL started"
psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -d $POSTGRES_DB -v ON_ERROR_STOP=$ON_ERROR_STOP -f testing/init.sql
echo "INIT SCRIPT: CREATE EXTENSIONS"
psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -d $POSTGRES_DB -v ON_ERROR_STOP=$ON_ERROR_STOP -c 'CREATE EXTENSION pgcrypto;'
psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -d $POSTGRES_DB -v ON_ERROR_STOP=$ON_ERROR_STOP -c 'CREATE EXTENSION pgulid;'
psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -d $POSTGRES_DB -v ON_ERROR_STOP=$ON_ERROR_STOP -c 'CREATE EXTENSION plpgsql_check;'

if [ $? -ne 0 ]; then
    echo "Error occurred during database initialization"
    exit 1
fi

echo "Database initialization completed successfully"
exit 0