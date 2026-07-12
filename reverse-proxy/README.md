# Reverse Proxy

Dockerfile for building a reverse proxy on top of `wsams/httpd:latest` (the base flavor).

```bash
docker build -t wsams/proxy --rm --no-cache --build-arg SSL_DIR=/etc/letsencrypt/live/example.com .
```

It assumes Let's Encrypt certificate paths under `SSL_DIR`. Put proxy rules in `sample.proxy.conf` (see that file for an example).
