# Go flavor layered on the base httpd image.
# Installs the Go toolchain and enables Apache CGI for small net/http/cgi apps.
# docker build -t wsams/httpd:go-local -f Dockerfile.go --build-arg BASE_IMAGE=wsams/httpd:local .
ARG BASE_IMAGE=wsams/httpd:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    GOTOOLCHAIN=local

COPY go/apache-go.conf /etc/apache2/conf-available/go-cgi.conf

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        golang-go && \
    a2enmod cgi cgid && \
    a2enconf go-cgi && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*
