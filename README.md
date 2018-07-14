# docker-defect-dojo

Run DefectDojo in a "stateless" fashion.

## Run with `docker`
```bash
# This step is optional, you can also connect to an existing database
docker run -it \
    -e MYSQL_ROOT_PASSWORD="password" \
    -e MYSQL_USER="dojo" \
    -e MYSQL_PASSWORD="dojo" \
    -e MYSQL_PASSWORD="dojo" \
    -e MYSQL_DATABASE="defectdojo" \
    --name db \
    mysql:5.7 

# This is where the magic happens :)
docker run -it \
    -e AUTO_DOCKER="yes" \
    -e SQLHOST="db" \
    -e SQLPORT="3306" \
    -e SQLUSER="dojo" \
    -e SQLPWD="dojo" \
    -e DBNAME="defectdojo" \
    -e DOJO_ADMIN_USER="john" \
    -e DOJO_ADMIN_PASSWORD="john" \
    -e FLUSHDB="N" \
    -p 8000:8000 \
    --name defectdojo \
    --link db:db \
    defectdojo
    
localhost:8000 admin/admin
```

## Run with `docker-compose`
```bash
$ docker-compose build
$ docker-compose up
```

Once the containers are ready, you should have two docker containers running against the same
"remote" database.

```bash
localhost:8000 admin/admin
localhost:8001 admin/admin
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
```
