#!/bin/bash

set -e
set -x

echo "*** Exporting environment variables"
export DBNAME=$MYSQL_DATABASE
export SQLUSER=$MYSQL_USER
export SQLPWD=$MYSQL_PASSWORD
export SQLHOST=$MYSQL_HOST
export SQLPORT=$MYSQL_PORT
export DOJO_MYSQL_HOST=$MYSQL_HOST
export DOJO_MYSQL_PORT=$MYSQL_PORT

if [ -z "$PORT" ]; then
    export PORT=8000
fi

echo "*** Waiting for Database"
bash $DOCKER_DIR/wait-for-it.sh $DOJO_MYSQL_HOST:$DOJO_MYSQL_PORT

echo "*** Updating dojo/settings/settings.py"
unset HISTFILE

SECRET=`cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c 128`
TARGET_SETTINGS_FILE=dojo/settings/settings.py

# Save MySQL details in settings file
cp dojo/settings/settings.dist.py ${TARGET_SETTINGS_FILE}

sed -i  -e "s/MYSQLHOST/$SQLHOST/g" \
        -e "s/MYSQLPORT/$SQLPORT/g" \
        -e "s/MYSQLUSER/$SQLUSER/g" \
        -e "s/MYSQLPWD/$SQLPWD/g" \
        -e "s/MYSQLDB/$DBNAME/g" \
        -e "s#DOJODIR#$PWD/dojo#g" \
        -e "s/DOJOSECRET/$SECRET/g" \
        -e "s/# SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')/SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')/g" \
        -e "s/# SECURE_SSL_REDIRECT = True/SECURE_SSL_REDIRECT = True/g" \
        -e "s/# SECURE_BROWSER_XSS_FILTER = True/SECURE_BROWSER_XSS_FILTER = True/g" \
        -e "s/# SESSION_COOKIE_SECURE = True/SESSION_COOKIE_SECURE = True/g" \
        -e "s/# CSRF_COOKIE_SECURE = True/CSRF_COOKIE_SECURE = True/g" \
        -e "s/ # 'django.middleware.security.SecurityMiddleware',/ 'django.middleware.security.SecurityMiddleware',/g" \
        -e "s#DOJO_MEDIA_ROOT#$PWD/media/#g" \
        -e "s#DOJO_STATIC_ROOT#$PWD/static/#g" \
        -e "s/BACKENDDB/django.db.backends.mysql/g" \
        -e "s/TEMPLATE_DEBUG = DEBUG/TEMPLATE_DEBUG = False/g" \
        -e "s/DEBUG = True/DEBUG = False/g" \
        -e "s/ALLOWED_HOSTS = \[]/ALLOWED_HOSTS = [$ALLOWED_HOSTS, 'localhost', '$(awk 'END{print $1}' /etc/hosts)']/g" \
        ${TARGET_SETTINGS_FILE}

echo "*** Running migrations"
python manage.py makemigrations dojo
python manage.py makemigrations --merge --noinput
python manage.py migrate
python manage.py createsuperuser --noinput --username=admin --email='ed@example.com' || true
docker/setup-superuser.expect

python manage.py loaddata product_type
python manage.py loaddata test_type
python manage.py loaddata development_environment
python manage.py loaddata system_settings
python manage.py installwatson
python manage.py buildwatson

python manage.py collectstatic --noinput

sudo chown -R dojo:dojo /nginx
echo "Copying static files to /nginx"
sudo cp -R $PWD/static/* /nginx

if [ "$LOAD_SAMPLE_DATA" = True ]; then
    echo "*** Loading sample data"
    bash $DOCKER_DIR/dojo-data.bash load
fi

cd $DOJO_ROOT_DIR

gunicorn --env DJANGO_SETTINGS_MODULE=dojo.settings.settings dojo.wsgi:application --bind 0.0.0.0:$PORT --workers 3 & \
    celery -A dojo worker -l info --concurrency 3
