#!/usr/bin/env bash

set -e

#echo "*** Setting proxy"
touch ~/.npmrc
echo "proxy=$HTTP_PROXY" >> ~/.npmrc
echo "https-proxy=$HTTPS_PROXY" >> ~/.npmrc

echo "*** Starting nginx"
sudo service nginx start

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
sed -i "s/ALLOWED_HOSTS = \[]/ALLOWED_HOSTS = [$ALLOWED_HOSTS, 'localhost', '$(awk 'END{print $1}' /etc/hosts)']/g" dojo/settings/settings.py

echo "*** Tail nginx logs"
sudo tail -f /var/log/nginx/* &

echo "*** Running startup script"
bash docker/docker-startup.bash
