# httpd Docker image

This image can be used to run an Apache httpd 2.4 web server with SSL enabled. It also comes with PHP 7.

To use this image provide the following environment variables:

* `HTTPD_SERVER_NAME`: The virtual host `ServerName` value.
* `HTTPD_SERVER_ADMIN`: The virtual host `ServerAdmin` value.
* `SSL_CERTIFICATE_FILE`: The virtual host `SSLCertificateFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/fullchain.pem`. The image provides a self-signed certificate by default at `/apache-cert.pem`.
* `SSL_CERTIFICATE_KEY_FILE`: The virtual host `SSLCertificateKeyFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/privkey.pem`. The image provides a key by default at `/apache-key.pem`.

Build image or pull the existing `wsams/httpd` from Docker Hub (`docker pull wsams/httpd`),

```
docker build -t wsams/httpd --rm=true --no-cache --pull .
```

See `sample.docker-compose.yml` for example usage. Copy to `docker-compose.yml`, modify, and run `docker-compose up -d`.

The sample Docker Compose file uses the self-signed certificates provided in the image by default. Once a container is started you should be able to access `https://localhost`

Find images on [Docker Hub](https://hub.docker.com/r/wsams/httpd/). Find source at https://github.com/wsams/httpd
