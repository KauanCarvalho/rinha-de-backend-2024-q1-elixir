#!/bin/sh

if [ "$1" = 'release' ]; then
  exec /app/bin/backend_fight start
elif [ "$1" = 'migrate_and_release' ]; then
  /app/bin/backend_fight eval "DB.Release.migrate()"
  exec /app/bin/backend_fight start
fi
