# mysql-backup
### Dump and upload all/one database that are served by a MySQL server to a AWS S3 bucket
This project has a goal to build a docker image that can be integrated into a K8s cluster to dump and upload to AWS S3 all hosted databases by one MySQL server.
The best usage is to create a job in a K8s cluster and use this image to do the work.

You need to declare this environment variables:
```
AWS Configuration
* All fields are mandatory
- AWS_BACKUP_BUCKET
- AWS_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

Database Configuration
* MYSQL_DATABASE - is optional, in case this parameter is not provided, it will backup all databases
* MYSQL_PORT - is optional, default 3306
- MYSQL_DATABASE
- MYSQL_HOST
- MYSQL_PORT
- MYSQL_USER
- MYSQL_PASS
```

If you want to try this local, you can edit by filling in all the required environment variables in `docker-compose.yaml` and run `docker compose up`
