#!/bin/bash

while ! nc -z "${MYSQL_HOST}" ${MYSQL_PORT:-3306}; do
  echo "Sleeping 1s ..."
  sleep 1
done

# Validate Database Configuration
[ -z "${MYSQL_HOST}" ] && { echo "=> MYSQL_HOST cannot be empty" && exit 1; }
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASS}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }

# Validate AWS Configuration
[ -z "${AWS_REGION}" ] && { echo "=> AWS_REGION cannot be empty" && exit 1; }
[ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
[ -z "${AWS_BACKUP_BUCKET}" ] && { echo "=> AWS_BACKUP_BUCKET cannot be empty" && exit 1; }

GZIP_LEVEL=6
DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"

# Get all databases
MYSQL_PORT=${MYSQL_PORT:-3306}
DATABASES=${MYSQL_DATABASE:-${MYSQL_DB:-$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)}}

# Backup every database
for db in ${DATABASES}
do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]]
  then
    echo "==> Dumping database: $db"

    FILENAME=/$db-$DATE.sql
    LATEST=/$db-latest.sql.gz

    if mysqldump --single-transaction -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" $db $MYSQLDUMP_OPTS > "$FILENAME"
    then
      gzip "-$GZIP_LEVEL" -f "$FILENAME"
      echo "==> Creating symlink to latest backup: $(basename "$FILENAME".gz)"
      rm "$LATEST" 2> /dev/null
      ln -s $(basename "$FILENAME".gz) $(basename "$LATEST")

      echo "==> Upload files to S3"
      aws s3 mv $LATEST s3://$AWS_BACKUP_BUCKET/
      aws s3 mv "$FILENAME.gz" s3://$AWS_BACKUP_BUCKET/
      echo "==> Files was uploaded!"
    else
      rm -rf "$FILENAME"
    fi
  fi
done

echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
exit
