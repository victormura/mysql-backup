#!/bin/bash

# Validate Database Configuration
[ -z "${MYSQL_HOST}" ] && { echo "=> MYSQL_HOST cannot be empty" && exit 1; }
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASS}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }

while ! nc -z "${MYSQL_HOST}" ${MYSQL_PORT:-3306}; do
  echo "Sleeping 1s ..."
  sleep 1
done

# Validate AWS Configuration
[ -z "${AWS_REGION}" ] && { echo "=> AWS_REGION cannot be empty" && exit 1; }
[ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
[ -z "${AWS_BACKUP_BUCKET}" ] && { echo "=> AWS_BACKUP_BUCKET cannot be empty" && exit 1; }

if [ ! -z "${ROLLBACK}" ];
then
  ./scripts/rollback.sh
else
  ./scripts/backup.sh
fi
exit
