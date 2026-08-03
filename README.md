# httpd Docker image

Opinionated Apache httpd 2.4 images on Ubuntu 26.04, published as a single Docker Hub repository with flavor tags. An nginx sibling flavor is also published under the same repository.

| Tag | Contents |
| --- | --- |
| `wsams/httpd:x.y.z` / `wsams/httpd:latest` | Base httpd with SSL, HTTP/2, rewrite, and proxy modules |
| `wsams/httpd:php-x.y.z` / `wsams/httpd:php` | Base + PHP (mod_php) and common extensions |
| `wsams/httpd:python-x.y.z` / `wsams/httpd:python` | Base + Python 3 via `mod_wsgi` |
| `wsams/httpd:go-x.y.z` / `wsams/httpd:go` | Base + Go toolchain and Apache CGI support |
| `wsams/httpd:nginx-x.y.z` / `wsams/httpd:nginx` | Nginx with TLS and reverse-proxy-ready defaults (not Apache-based) |

Nightly tags follow the same pattern: `nightly`, `php-nightly`, `python-nightly`, `go-nightly`, `nginx-nightly` (plus date-stamped variants).

## Environment variables

Apache flavors (`latest`, `php`, `python`, `go`):

* `HTTPD_SERVER_NAME`: Virtual host `ServerName`
* `HTTPD_SERVER_ADMIN`: Virtual host `ServerAdmin`
* `SSL_CERTIFICATE_FILE`: `SSLCertificateFile` path (default self-signed cert: `/apache-cert.pem`)
* `SSL_CERTIFICATE_KEY_FILE`: `SSLCertificateKeyFile` path (default key: `/apache-key.pem`)

Nginx flavor:

* `NGINX_SERVER_NAME`: `server_name` (default `localhost`)
* `SSL_CERTIFICATE_FILE`: TLS certificate path (default `/nginx-cert.pem`)
* `SSL_CERTIFICATE_KEY_FILE`: TLS key path (default `/nginx-key.pem`)

## Build locally

```bash
./scripts/build-images.sh local
# Images: wsams/httpd:local, wsams/httpd:php-local, wsams/httpd:python-local,
#         wsams/httpd:go-local, wsams/httpd:nginx-local
```

Or build flavors individually:

```bash
docker build -t wsams/httpd:local --rm --pull .
docker build -t wsams/httpd:php-local -f Dockerfile.php --build-arg BASE_IMAGE=wsams/httpd:local .
docker build -t wsams/httpd:python-local -f Dockerfile.python --build-arg BASE_IMAGE=wsams/httpd:local .
docker build -t wsams/httpd:go-local -f Dockerfile.go --build-arg BASE_IMAGE=wsams/httpd:local .
docker build -t wsams/httpd:nginx-local -f Dockerfile.nginx --rm --pull .
```

Smoke-test a local or CI build:

```bash
./scripts/test-images.sh local
```

See `sample.docker-compose.yml` for example usage. Copy to `docker-compose.yml`, modify, and run `docker compose up -d`. Example apps live under `examples/` (`index.php`, `index.py`, `index.go`, `nginx/index.html`).

After start you should be able to open `https://localhost` (self-signed certificate).

Images: [Docker Hub](https://hub.docker.com/r/wsams/httpd/). Source: https://github.com/wsams/httpd

## Python notes

The Python flavor uses Apache `mod_wsgi`. Place an `index.py` in the document root that exposes a WSGI callable named `application` (see `examples/index.py`). Visiting `/` runs `index.py` the same way `/` runs `index.php` in the PHP flavor.

## Go notes

Go does not plug into Apache the way PHP (`mod_php`) or Python (`mod_wsgi`) do. The Go flavor installs the Go toolchain on the base httpd image and enables CGI so small programs using `net/http/cgi` can be served from the document root (see `examples/index.go`).

```bash
go build -o /var/www/html/index.cgi examples/index.go
chmod 755 /var/www/html/index.cgi
```

For typical Go services, prefer compiling a binary and reverse-proxying to it with the base image's proxy modules.

## Nginx notes

The nginx flavor is a sibling image (Ubuntu + nginx), not a layer on Apache. It ships TLS defaults similar to the httpd base and renders `/etc/nginx/conf.d/default.conf` from a template at container start via `envsubst`.

## Releases and automation

* Pushes and pull requests run **CI**, which builds every flavor and runs `scripts/test-images.sh` smoke tests (HTTP/HTTPS readiness plus PHP/Python/Go/nginx example checks).
* Pushes to `master` run **semantic-release**, which:
  1. Creates a GitHub release/tag from conventional commits
  2. Builds and pushes all Docker Hub flavors for that version (`x.y.z`, `php-x.y.z`, `python-x.y.z`, `go-x.y.z`, `nginx-x.y.z`) plus floating tags (`latest`, `php`, `python`, `go`, `nginx`)
* A **nightly** workflow rebuilds and pushes the nightly tags.
* **Renovate** runs on a schedule, opens dependency PRs with `fix(deps):` commits, and automerges eligible updates (patch/minor). Merges to `master` can produce a new semantic-release and image publish.
* The **Republish Docker images** workflow can manually rebuild/push a given version if needed.

### Renovate setup

Create a classic personal access token (or GitHub App token) with `repo` and `workflow` scopes, then add it as the repository secret `RENOVATE_TOKEN`. Enable **Allow auto-merge** under the repository Settings → General → Pull Requests.

Existing Docker Hub secrets remain `REGISTERY_USERNAME` and `REGISTRY_PASSWORD`.

## Proxy / TLS notes

If you are proxying to an https URL, the CN of the certificate must match the host as defined in the `custom.conf` file mounted into the container. For example, you may have a Docker service `myservice` that you are proxying. In that case you would set `CN=myservice` when generating the certificate:

```bash
openssl req -new -newkey rsa:4096 -nodes -keyout /privkey.pem -out /snakeoil.csr -subj "/C=US/ST=Oregon/L=Portland/O=Zoopaz/OU=Zoopaz/CN=myservice"
openssl x509 -req -sha256 -days 365 -in /snakeoil.csr -signkey /privkey.pem -out /fullchain.pem
```

Example proxy configuration:

```apache
ProxyPass        /app/ https://myservice:8080/app/ retry=0 connectiontimeout=300 timeout=300
ProxyPassReverse /app/ https://myservice:8080/app/
```

Peer CN and certificate expiry checks are enabled in `custom.conf`:

```apache
SSLProxyCheckPeerCN on
SSLProxyCheckPeerExpire on
```
