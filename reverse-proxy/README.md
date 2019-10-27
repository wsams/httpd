# Reverse Proxy

The following directory contains a `Dockerfile` suitable for building a reverse proxy server.

You can build this image using the following command,

```
docker build -t wsams/proxy --rm=true --no-cache --build-arg SSL_DIR=/etc/letsencrypt/live/example.com .
```

It assumes you will be using Let's Encrypt for SSL. It also builds off of `wsams/httpd` which also assumes Let's Encrypt.

You can place your reverse proxy configurations in `sample.proxy.conf`. See it for an example.

This document is not full flushed out and will be updated soon to provide better getting started instructions.
