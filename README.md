# httpd Docker image

To use this image provide the following environment variables:

* `HTTPD_SERVER_NAME`: The virtual host `ServerName` value.
* `HTTPD_SERVER_ADMIN`: The virtual host `ServerAdmin` value.
* `SSL_CERTIFICATE_FILE`: The virtual host `SSLCertificateFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/fullchain.pem`
* `SSL_CERTIFICATE_KEY_FILE`: The virtual host `SSLCertificateKeyFile` value. If you're using Let's Encrypt, this could be the file: `/etc/letsencrypt/live/YOUR_HOSTNAME/privkey.pem`
