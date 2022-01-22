#!/bin/bash
echo "=> Rollback started at $(date "+%Y-%m-%d %H:%M:%S")"

# Get all databases
MYSQL_PORT=${MYSQL_PORT:-3306}
DATABASES=${MYSQL_DATABASE:-${MYSQL_DB:-$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)}}

for db in ${DATABASES}
do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]]
  then
    echo "==> Rollback database: $db"
    mkdir rollback && cd rollback
    ROLLBACK_LATEST_ARHIVE=$db-$ROLLBACK.sql.gz
    ROLLBACK_LATEST_FILENAME=$db-$ROLLBACK.sql

    echo "==> Started File download from S3 ${ROLLBACK_LATEST_ARHIVE}"
    aws s3 cp s3://$AWS_BACKUP_BUCKET/$ROLLBACK_LATEST_ARHIVE $ROLLBACK_LATEST_ARHIVE;
    gzip -d "$ROLLBACK_LATEST_ARHIVE"
    echo "==> Finished file download from S3 ${ROLLBACK_LATEST_ARHIVE}"
    if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" $db < "$ROLLBACK_LATEST_FILENAME"
    then
        echo "==> Succeed rollback for database: $db"
    else
        echo "==> Failed rollback for database: $db"
    fi
    cd .. && rm -rf rollback
  fi
done

echo "=> Rollback process finished at $(date "+%Y-%m-%d %H:%M:%S")"