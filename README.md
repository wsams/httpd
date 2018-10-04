# httpd web server

Create a Docker Compose to quickly run a web server. The examples found here use `example.com` - replace with your own domain.

```
  #
  # docker-compose.yml
  #
  version: '3'
  services:
    proxy:
      container_name: example-web
      image: wsams/httpd
      ports:
        - 443:443
        - 80:80
      volumes:
        - ./html:/var/www/html
        - ./proxy.conf:/etc/apache2/sites-enabled/proxy.conf
        - ./ssl/example.com:/etc/letsencrypt/live/example.com
```
        
`html` should contain web content. PHP 7 is enabled by default.

`proxy.conf` contains reverse proxy rules as well as SSL configuration. Both are optional. This example assumes you've created certificates with Lets Encrypt and they're stored in `/etc/letsencrypt/live/example.com`. You may have used `certbot certonly --manual`. Create a directory `ssl` and copy `example.com` into it. This will be bind mounted into the container.

```
  #
  # proxy.conf
  #
  
  # SSL Configuration 
  <VirtualHost *:443>
    ServerName example.com
    SSLEngine on
    SSLCertificateFile "/etc/letsencrypt/live/example.com/fullchain.pem"
    SSLCertificateKeyFile "/etc/letsencrypt/live/example.com/privkey.pem"
  </VirtualHost>

  # Pass https://foo.example.com thru https://example.com/proxy-path
  ProxyPass        /proxy-path https://foo.example.com retry=0 connectiontimeout=300 timeout=300
  ProxyPassReverse /proxy-path https://foo.example.com
```

Find images on [Docker Hub](https://hub.docker.com/r/wsams/httpd/)
