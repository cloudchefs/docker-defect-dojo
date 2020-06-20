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
    libpq-dev \
    libssl-dev \
    # gunicorn3 \
    python3-dev \
    libmysqlclient-dev \
    # socat curl python3-software-properties \
    # python-pip \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    # python-virtualenv \
    python3-venv \
    rabbitmq-server \
    python3-software-properties \
    mysql-server \
    git \
    apt-utils \
    apt-transport-https \
    libjpeg-dev \
    wkhtmltopdf \
    libmysqlclient-dev \
    build-essential && apt-get clean

# Install yarn and node
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="DontWarn"
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash && \
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
RUN python3 --version
# RUN sed -i 's/pandas>=0.25/pandas>=0.24.2/g' requirements.txt 
# RUN echo cat requirements.txt
RUN python3 -m pip install virtualenv 
RUN python3 -m venv env 
CMD ["bash", "source env/bin/activate"]
RUN sudo -H python3 -m pip install --upgrade pip && \
    pip3 install -U pip && \
    pip3 install -r requirements.txt
RUN sudo -H python3 -m pip install setuptools --upgrade    

RUN cd components && yarn && cd ..

# RUN sudo python3 -m pip uninstall -y numpy && \
#     sudo apt-get install -y python3-numpy

COPY scripts ./cloudchefs-scripts
RUN sudo chown -R dojo:dojo ./cloudchefs-scripts && \
    chmod +x ./cloudchefs-scripts/install.bash && \
    chmod +x ./cloudchefs-scripts/config-vars.sh 

CMD ["bash", "./cloudchefs-scripts/config-vars.sh"]
CMD ["bash", "./cloudchefs-scripts/install.bash"]
ENV DEBIAN_FRONTEND teletype
