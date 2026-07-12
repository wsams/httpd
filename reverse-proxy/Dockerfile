# docker build -t wsams/proxy --rm=true --no-cache --build-arg SSL_DIR=/etc/letsencrypt/live/example.com .
# Base image already enables headers/proxy/rewrite/ssl modules.
FROM wsams/httpd:latest

ARG SSL_DIR

RUN mkdir -p "$SSL_DIR"

COPY custom-proxy.conf /etc/apache2/sites-available/custom-proxy.conf
