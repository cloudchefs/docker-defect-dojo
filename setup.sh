#!/usr/bin/env bash

set -e

echo "*** Exporting environment variables"
export DBNAME=$MYSQL_DATABASE
export SQLUSER=$MYSQL_USER
export SQLPWD=$MYSQL_PASSWORD
export SQLHOST=$MYSQL_HOST
export SQLPORT=$MYSQL_PORT
export DOJO_MYSQL_HOST=$MYSQL_HOST
export DOJO_MYSQL_PORT=$MYSQL_PORT

echo "*** Running setup script"
bash setup.bash -y

echo "*** Updating dojo/settings/settings.py"
sed -i "s/TEMPLATE_DEBUG = DEBUG/TEMPLATE_DEBUG = False/g" dojo/settings/settings.py
sed -i "s/DEBUG = True/DEBUG = False/g" dojo/settings/settings.py
sed -i "s/ALLOWED_HOSTS = \[]/ALLOWED_HOSTS = ['localhost', '127.0.0.1']/g" dojo/settings/settings.py

echo "*** Running startup script"
bash docker/docker-startup.bash
