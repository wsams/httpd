# docker build -t wsams/httpd --rm=true .
FROM ubuntu:18.04

COPY httpd-foreground /usr/bin/

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install \
        apt-utils \
        git \
        sudo \
        fail2ban \
        vim \
        unzip \
        zip \
        curl \
        apache2 \
        php \
        php-curl \
        php-gd \
        php-imagick \
        php-imap \
        php-json \
        php-mongodb \
        php-mysql \
        php-sqlite3 \
        php-xml \
        php-xsl \
        php-zip && \
    a2enmod ssl && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 700 /usr/bin/httpd-foreground

EXPOSE 80

CMD ["httpd-foreground"]

