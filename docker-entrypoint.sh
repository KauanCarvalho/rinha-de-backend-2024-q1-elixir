#!/bin/sh

until nc -z -v -w20 database 5432; do
  >&2 echo "PostgreSql is unavailable - sleeping"
	sleep 2;
done

if [ "$1" = 'release' ]; then
  exec /app/bin/backend_fight start
elif [ "$1" = 'migrate_and_release' ]; then
  /app/bin/backend_fight eval "DB.Release.migrate()"
  exec /app/bin/backend_fight start
fi
