# docker-defect-dojo

Run DefectDojo in a "stateless" fashion.

## Run with `docker-compose`
```bash
$ docker-compose build
$ docker-compose up
```

Once the containers are ready, you should have a docker container running against the "remote" database.

```bash
localhost:8000 admin/admin
```

## Supported versions
- 1.3.0

## Configuration
Pass the following environment variables to configure your container:

```
AUTO_DOCKER="yes"               # Skip prompts during setup
SQLHOST="db"                    # Remote MYSQL host
SQLPORT="3306"                  # Remote MYSQL port
SQLUSER="dojo"                  # Remote MYSQL user
SQLPWD="dojo"                   # Remote MYSQL password
DBNAME="defectdojo"             # Remote MYSQL DB name
DOJO_ADMIN_USER="john"          # Admin username
DOJO_ADMIN_PASSWORD="john"      # Admin password
FLUSHDB="N"                     # Set to N, if you want to preserve your DB
RUN_TIERED="True"               # Run in tiered mode, separate DB instance
```
