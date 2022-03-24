# RDBC Backup

Relational database container backup

This docker image runs mysqldump to backup your MySQL/MariaDB databases periodically using cron task manager.

Add following code into your docker yaml file

`docker-compose.yml`

```yml
backup:
  image: euclid1990/rdbcbackup
  restart: on-failure
  env_file:
    - .env.rdbc
  volumes:
    - .data/backup:/backup
    - .data/logs/backup:/logs
  tty: true
  stdin_open: true
  networks:
    - compose_network
```

`.env.rdbc`

```bash
MYSQL_HOST=db
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dev_user
MYSQL_DATABASE=dev_database
MYSQL_PASSWORD=123456
TIMEZONE=Asia/Ho_Chi_Minh
CONNECT_TIMEOUT=180
BACKUP_SCHEDULE=0 0 * * *
BACKUP_COMPRESSION=gzip
BACKUP_IGNORES=information_schema|performance_schema|sys|mysql
BACKUP_LOG_COMBINE=1
BACKUP_OUTPUT_LOGFILE=/logs/backup.log
BACKUP_ERROR_LOGFILE=/logs/error.log
BACKUP_MAX_FILES=6
BACKUP_RETAIN_DAYS=5
```
