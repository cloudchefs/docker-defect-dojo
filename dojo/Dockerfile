FROM ubuntu:18.04

ARG VERSION

ENV TZ="Europe/Amsterdam"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install OS dependenices
RUN apt-get update && apt-get install -y nodejs npm && apt-get install -y \
    wget \
    curl \
    unzip \
    sudo \
    expect \
    netcat \
    gcc \
    libssl-dev \
    python-dev \
    libmysqlclient-dev \
    python-pip \
    git \
    apt-utils \
    apt-transport-https \
    libjpeg-dev \
    wkhtmltopdf \
    libmysqlclient-dev \
    build-essential && apt-get clean

# Install yarn and node
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="DontWarn"
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -e && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - > /dev/null && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && apt-get clean

RUN wget https://github.com/DefectDojo/django-DefectDojo/archive/$VERSION.zip
RUN unzip $VERSION.zip
RUN mv django-DefectDojo-$VERSION /opt/django-DefectDojo
WORKDIR /opt/django-DefectDojo

RUN adduser --disabled-password --gecos "DefectDojo" dojo
RUN cp docker/etc/dojo_sudo /etc/sudoers.d/dojo
RUN chmod 0440 /etc/sudoers.d/dojo

RUN chown -R dojo:dojo /opt/django-DefectDojo /home/dojo
USER dojo:dojo

ENV DOCKER_DIR="/opt/django-DefectDojo/docker" \
    DOJO_ROOT_DIR="/opt/django-DefectDojo" \
    DJANGO_SETTINGS_MODULE="dojo.settings.settings"

RUN sudo pip install --upgrade pip && \
    sudo -H pip install -U pip && \
    sudo -H pip install -r requirements.txt

RUN cd components && yarn && cd ..

RUN sudo pip uninstall -y numpy && \
    sudo apt-get install -y python-numpy

COPY scripts ./cloudchefs-scripts
RUN sudo chown -R dojo:dojo ./cloudchefs-scripts && \
    chmod +x ./cloudchefs-scripts/install.bash

CMD ["bash", "./cloudchefs-scripts/install.bash"]

