FROM ubuntu:18.04

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

# Install nginx
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

RUN openssl req -subj '/CN=localhost' -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
RUN mkdir -p /etc/nginx/external && mv cert.pem key.pem /etc/nginx/external/

RUN apt-get install -y nginx
COPY ./nginx/default.nginx /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN nginx -t && service nginx restart

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

COPY ./install.bash /opt/django-DefectDojo/install.bash

CMD ["bash", "install.bash"]

