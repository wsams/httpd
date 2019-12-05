# docker build -t wsams/httpd --rm=true --pull .
FROM ubuntu:19.10

ARG SSL_DIR

COPY httpd-foreground /usr/bin/

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install \
        apache2 \
        apt-utils \
        curl \
        fail2ban \
        imagemagick \
        git \
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
        php-zip \
        unzip \
        vim \
        zip && \
    a2enmod headers && \
    a2enmod http2 && \
    a2enmod proxy && \
    a2enmod proxy_balancer && \
    a2enmod proxy_http && \
    a2enmod proxy_wstunnel && \
    a2enmod rewrite && \
    a2enmod ssl && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 700 /usr/bin/httpd-foreground && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /apache-key.pem -out /apache-cert.pem

COPY custom.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["httpd-foreground"]
