FROM marvambass/nginx-ssl-secure

ARG VERSION
ARG DOJO_HOST

ADD static/static-$VERSION.tar.gz /django-DefectDojo/
COPY default.nginx /etc/nginx/external/default.conf
RUN sed -i -e "s/DOJO_HOST/$DOJO_HOST/g" /etc/nginx/external/default.conf
