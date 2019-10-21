# httpd Docker image

This image can be used to run an Apache httpd 2.4 web server with SSL enabled. It also comes with PHP 7.

To use this image provide the following environment variables:

* `HTTPD_SERVER_NAME`: The virtual host `ServerName` value.
* `HTTPD_SERVER_ADMIN`: The virtual host `ServerAdmin` value.
* `SSL_CERTIFICATE_FILE`: The virtual host `SSLCertificateFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/fullchain.pem`
* `SSL_CERTIFICATE_KEY_FILE`: The virtual host `SSLCertificateKeyFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/privkey.pem`

Build image,

```
docker build -t wsams/httpd --rm=true --no-cache --pull .
```

See `sample.docker-compose.yml` for example usage. Copy to `docker-compose.yml`, modify, and run `docker-compose up -d`.

Find images on [Docker Hub](https://hub.docker.com/r/wsams/httpd/). Find source at https://github.com/wsams/httpd