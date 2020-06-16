FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

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
    python3-pip \
    git \
    apt-utils \
    apt-transport-https \
    libjpeg-dev \
    wkhtmltopdf \
    libmysqlclient-dev \
    build-essential && apt-get clean

# Install yarn and node
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="DontWarn"
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -e && \
    apt-get -y update && \
    apt-get -y install nodejs && \
    echo "$(node --version)" && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - > /dev/null && \
    echo "deb https://nightly.yarnpkg.com/debian/ nightly main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && echo "$(yarn --version)" && apt-get clean

RUN wget https://github.com/DefectDojo/django-DefectDojo/archive/$VERSION.zip
RUN unzip $VERSION.zip
RUN ls 
RUN mv django-DefectDojo-$VERSION /opt/django-DefectDojo
WORKDIR /opt/django-DefectDojo

RUN adduser --disabled-password --gecos "DefectDojo" dojo
RUN ls docker/
RUN cp docker/dojo_sudo /etc/sudoers.d/dojo
RUN chmod 0440 /etc/sudoers.d/dojo

RUN chown -R dojo:dojo /opt/django-DefectDojo /home/dojo
USER dojo:dojo

ENV DOCKER_DIR="/opt/django-DefectDojo/docker" \
    DOJO_ROOT_DIR="/opt/django-DefectDojo" \
    DJANGO_SETTINGS_MODULE="dojo.settings.settings"

# RUN sudo -H pip install --upgrade pip && \
RUN sudo -H pip3 install -U pip && \
    sudo -H pip3 install --upgrade pip && \
    #sudo -H pip install asteval==0.9.18 && \
    sudo -H pip3 install -r requirements.txt

RUN cd components && yarn && cd ..

RUN sudo pip3 uninstall -y numpy && \
    sudo apt-get install -y python-numpy

COPY scripts ./cloudchefs-scripts
RUN sudo chown -R dojo:dojo ./cloudchefs-scripts && \
    chmod +x ./cloudchefs-scripts/install.bash

CMD ["bash", "./cloudchefs-scripts/install.bash"]
ENV DEBIAN_FRONTEND teletype
