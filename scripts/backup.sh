#!/bin/bash
GZIP_LEVEL=6
DATE=$(date +%Y-%m-%dT%H-%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"

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