FROM ubuntu:latest

ENV TZ="Europe/Amsterdam"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    expect \
    netcat \
    wget \
    mysql-server \
    sudo \
    gcc \
    libssl-dev \
    python-dev \
    libmysqlclient-dev \
    python-pip \
    mysql-server \
    git \
    nodejs \
    npm \
    apt-transport-https \
    libjpeg-dev \
    wkhtmltopdf \
    unzip \
    build-essential && apt-get clean

ENV VERSION="461c13affda9d1e1001a55f502379cdb45e6f3d7"

RUN wget https://github.com/abelmokadem/django-DefectDojo/archive/$VERSION.zip

RUN unzip $VERSION.zip
RUN mv django-DefectDojo-$VERSION /opt/django-DefectDojo

WORKDIR /opt/django-DefectDojo

RUN sudo apt-get install -y curl apt-transport-https
#Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash

RUN adduser --disabled-password --gecos "DefectDojo" dojo
RUN cp docker/etc/dojo_sudo /etc/sudoers.d/dojo
RUN chmod 0440 /etc/sudoers.d/dojo

RUN chown -R dojo:dojo /opt/django-DefectDojo /home/dojo
USER dojo:dojo

ENV DBTYPE="1"
ENV AUTO_DOCKER="yes"
ENV DOCKER_DIR="/opt/django-DefectDojo/docker"
ENV DOJO_ROOT_DIR="/opt/django-DefectDojo"
ENV DJANGO_SETTINGS_MODULE="dojo.settings.settings"
ENV RUN_TIERED="True"
ENV FLUSHDB="N"

RUN sudo pip install --upgrade virtualenv
RUN virtualenv venv

COPY ./setup.sh ./

CMD ["bash", "-c", "\
    echo \"*** Exporting environment variables\" && \
    export DBNAME=$MYSQL_DATABASE && \
    export SQLUSER=$MYSQL_USER && \
    export SQLPWD=$MYSQL_PASSWORD && \
    export SQLHOST=$MYSQL_HOST && \
    export SQLPORT=$MYSQL_PORT && \
    export DOJO_MYSQL_HOST=$MYSQL_HOST && \
    export DOJO_MYSQL_PORT=$MYSQL_PORT && \
    \
    echo \"*** Running setup script\" && \
    bash setup.bash -y && \
    \
    echo \"*** Updating dojo/settings/settings.py\" && \
    sed -i \"s/TEMPLATE_DEBUG = DEBUG/TEMPLATE_DEBUG = False/g\" dojo/settings/settings.py && \
    sed -i \"s/DEBUG = True/DEBUG = False/g\" dojo/settings/settings.py && \
    sed -i \"s/ALLOWED_HOSTS = \[]/ALLOWED_HOSTS = ['localhost', '127.0.0.1']/g\" dojo/settings/settings.py && \
    \
    echo \"*** Running startup script\" && \
    bash docker/docker-startup.bash \
"]

