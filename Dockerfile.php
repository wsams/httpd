# PHP flavor layered on the base httpd image.
# docker build -t wsams/httpd:php-local -f Dockerfile.php --build-arg BASE_IMAGE=wsams/httpd:local .
ARG BASE_IMAGE=wsams/httpd:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        imagemagick \
        libapache2-mod-php \
        php \
        php-curl \
        php-gd \
        php-imagick \
        php-mongodb \
        php-mysql \
        php-sqlite3 \
        php-xml \
        php-xsl \
        php-zip \
        unzip \
        zip && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*
