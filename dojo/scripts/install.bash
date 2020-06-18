!/bin/bash

set -e

cd $DOJO_ROOT_DIR

python3 -m pip install celery
export PATH="$HOME/dojo/.local/bin:$PATH"

# sudo pip3 install gunicorn
# python3 -m pip install django

# echo "*** Exporting environment variables"
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

if [ -z "$HOST" ]; then
    export HOST='0.0.0.0'
fi

echo "*** Waiting for Database"
bash $DOCKER_DIR/wait-for-it.sh $DOJO_MYSQL_HOST:$DOJO_MYSQL_PORT

echo "*** Updating dojo/settings/settings.py"
unset HISTFILE

echo "***** python version"
python3 --version

SECRET=`cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c 128`
TARGET_SETTINGS_FILE=dojo/settings/.env.prod

# Save MySQL details in settings file
cp dojo/settings/settings.dist.py dojo/settings/settings.py 
cp dojo/settings/template-env ${TARGET_SETTINGS_FILE}
cp -r dojo/db_migrations dojo/migrations
# sed -i'' "s#DOJO_STATIC_ROOT#$PWD/static/#g" dojo/settings/settings.py
# sed -i "s/django.db.backends.mysql/django.db.backends.sqlite3/g" dojo/settings/settings.py

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
        -e "s#DD_STATIC_ROOT#'$PWD/static/'#g" \
        -e "s/BACKENDDB/django.db.backends.mysql/g" \
        -e "s/TEMPLATE_DEBUG = DEBUG/TEMPLATE_DEBUG = False/g" \
        -e "s/DEBUG = True/DEBUG = True/g" \
        -e "s/ALLOWED_HOSTS = \[]/ALLOWED_HOSTS = [$ALLOWED_HOSTS, 'localhost', '$(awk 'END{print $1}' /etc/hosts)']/g" \
        ${TARGET_SETTINGS_FILE}

# cat settings
# cat dojo/settings/settings.py

# Disables DATA_UPLOAD_MAX_MEMORY_SIZE in Django
awk '/STATIC_URL/ { print; print "DATA_UPLOAD_MAX_MEMORY_SIZE = None"; next }1' ${TARGET_SETTINGS_FILE} > tmp && mv tmp ${TARGET_SETTINGS_FILE}

#DB config
echo "*** DB CONFIG ***"
if [ -z "$DD_DATABASE_URL" ]; then
  if [ -z "$DD_DATABASE_PASSWORD" ]; then
      echo "Please set DD_DATABASE_URL or other DD_DATABASE_HOST, DD_DATABASE_USER, DD_DATABASE_PASSWORD, ..."
      exit 1
  fi
  export DD_DATABASE_URL="$DD_DATABASE_TYPE://$DD_DATABASE_USER:$DD_DATABASE_PASSWORD@$DD_DATABASE_HOST:$DD_DATABASE_PORT/$DD_DATABASE_NAME"
fi

if [ -z "$DD_ADMIN_PASSWORD" ]; then
      DD_ADMIN_PASSWORD="admin"
  fi


echo "*** Running migrations"
# python3 manage.py showmigrations
echo "*** Running makemigrations dojo"
python3 manage.py makemigrations dojo 
echo "*** Running makemigrations merge"
python3 manage.py makemigrations --merge --noinput
echo "*** Running migrate"
python3 manage.py migrate
echo "*** Running create user"
# python3 manage.py createsuperuser --noinput --username=admin --email='ed@example.com' || true
# docker/setup-superuser.expect
echo "*** Running loaddata"
python3 manage.py loaddata system_settings
echo "*** Running install watson"
python3 manage.py installwatson
python3 manage.py buildwatson

if [ "$GENERATE_STATIC_FILES" = True ]; then
    echo "*** Generating static files"
    python3 manage.py collectstatic --noinput
fi

if [ "$LOAD_SAMPLE_DATA" = True ]; then
    echo "*** Loading sample data"
    bash $DOCKER_DIR/dojo-data.bash load
fi

# python3 manage.py runserver 0.0.0.0.:$PORT & \
#     celery -A dojo worker -l info --concurrency 3

python3 -m pip install virtualenv
python3 -m venv env
source env/bin/activate

gunicorn --env DJANGO_SETTINGS_MODULE=dojo.settings.settings dojo.wsgi:application --bind 0.0.0.0:$PORT --workers 3 & \
    celery -A dojo worker -l info --concurrency 3