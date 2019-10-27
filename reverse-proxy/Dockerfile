# docker build -t wsams/proxy --rm=true --no-cache --build-arg SSL_DIR=/etc/letsencrypt/live/example.com .
FROM wsams/httpd

ARG SSL_DIR

RUN apt-get update && \
    a2enmod headers && \
    a2enmod proxy && \
    a2enmod proxy_balancer && \
    a2enmod proxy_http && \
    a2enmod proxy_wstunnel && \
    a2enmod rewrite && \
    mkdir -p $SSL_DIR && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

COPY custom-proxy.conf /etc/apache2/sites-available/custom-proxy.conf
