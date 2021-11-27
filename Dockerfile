FROM node:16.13.0-alpine As Builder

RUN npm config set unsafe-perm true

COPY ./package*.json /usr/build/
WORKDIR /usr/build
RUN npm ci

COPY ./ /usr/build/
#COPY ./public /usr/build/
RUN npm run build

FROM bitnami/nginx:1.18
USER root
RUN apt-get update && apt-get install -y gettext-base

RUN chown 1000:100 /opt/bitnami/nginx/

COPY --chown=1000:100 ./nginx.conf /opt/bitnami/nginx/conf/nginx.conf

USER 1000

RUN mkdir -p /opt/bitnami/nginx/tmp/client_body && \
    mkdir -p /opt/bitnami/nginx/tmp/proxy && \
    mkdir -p /opt/bitnami/nginx/tmp/uwsgi && \
    mkdir -p /opt/bitnami/nginx/tmp/scgi && \
    mkdir -p /opt/bitnami/nginx/www

RUN ln -sf /dev/stdout /opt/bitnami/nginx/logs/access.log && \
    ln -sf /dev/stderr /opt/bitnami/nginx/logs/error.log

WORKDIR /app

COPY --chown=1000:100 --from=builder /usr/build/build /opt/bitnami/nginx/www

# Carries out NGINX setup (see https://github.com/bitnami/bitnami-docker-nginx)
ENTRYPOINT [ "/opt/bitnami/scripts/nginx/entrypoint.sh" ]

STOPSIGNAL SIGQUIT

COPY ./startNginx.sh /
CMD ["/bin/bash", "/startNginx.sh"]