FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y expect netcat
RUN apt-get install -y wget mysql-server sudo
RUN apt-get install -y gcc libssl-dev python-dev libmysqlclient-dev python-pip mysql-server git nodejs npm

RUN wget https://github.com/DefectDojo/django-DefectDojo/archive/1.3.0.tar.gz

RUN tar -zxvf 1.3.0.tar.gz
RUN mv django-DefectDojo-1.3.0 /opt/django-DefectDojo

ADD wait-for-db.sh wait-for-defectdojo.sh /opt/django-DefectDojo/
RUN chmod +x /opt/django-DefectDojo/wait-for-defectdojo.sh
RUN chmod +x /opt/django-DefectDojo/wait-for-db.sh

RUN groupadd -g 999 dojo && \
    useradd -r -u 999 -g dojo dojo && \
    echo "dojo ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/dojo && \
    chmod 0440 /etc/sudoers.d/dojo

RUN chown -R dojo:dojo /opt/django-DefectDojo

USER dojo:dojo

WORKDIR /opt/django-DefectDojo

RUN chmod +x docker/docker-startup.bash
RUN chmod +x docker/dojo-data.bash

CMD ["bash", "-c", "./setup.bash -y && bash docker/docker-startup.bash -y"]
