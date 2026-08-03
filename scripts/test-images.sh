#!/usr/bin/env bash
# Smoke-test locally built wsams/httpd image flavors.
#
# Usage:
#   ./scripts/test-images.sh ci
#   IMAGE_NAME=wsams/httpd ./scripts/test-images.sh local
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-wsams/httpd}"
VERSION="${1:?Usage: $0 <version>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLES_DIR="${ROOT_DIR}/examples"
CURL_OPTS=(--silent --show-error --fail --max-time 10)

PASS_COUNT=0
FAIL_COUNT=0
CLEANUP_IDS=()

cleanup() {
  local id
  for id in "${CLEANUP_IDS[@]+"${CLEANUP_IDS[@]}"}"; do
    [[ -n "${id}" ]] || continue
    docker rm -f "${id}" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT

log() {
  printf '==> %s\n' "$*"
}

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$*"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$*" >&2
}

require_image() {
  local tag="$1"
  if ! docker image inspect "${tag}" >/dev/null 2>&1; then
    echo "Missing image: ${tag}" >&2
    echo "Build first with: ./scripts/build-images.sh ${VERSION}" >&2
    exit 1
  fi
}

wait_for_http() {
  local url="$1"
  local attempts="${2:-30}"
  local i
  for ((i = 1; i <= attempts; i++)); do
    if curl "${CURL_OPTS[@]}" -k -o /dev/null "${url}" 2>/dev/null; then
      return 0
    fi
    sleep 1
  done
  return 1
}

start_container() {
  local name="$1"
  shift
  local id
  id="$(docker run -d --name "${name}" "$@")"
  CLEANUP_IDS+=("${id}")
  echo "${id}"
}

assert_body_contains() {
  local url="$1"
  local needle="$2"
  local body
  body="$(curl "${CURL_OPTS[@]}" -k "${url}")"
  if [[ "${body}" == *"${needle}"* ]]; then
    return 0
  fi
  printf 'Expected body to contain %q, got:\n%s\n' "${needle}" "${body}" >&2
  return 1
}

httpd_env=(
  -e HTTPD_SERVER_NAME=localhost
  -e HTTPD_SERVER_ADMIN=webmaster@example.com
  -e SSL_CERTIFICATE_FILE=/apache-cert.pem
  -e SSL_CERTIFICATE_KEY_FILE=/apache-key.pem
)

nginx_env=(
  -e NGINX_SERVER_NAME=localhost
  -e SSL_CERTIFICATE_FILE=/nginx-cert.pem
  -e SSL_CERTIFICATE_KEY_FILE=/nginx-key.pem
)

log "Checking required images for version ${VERSION}"
require_image "${IMAGE_NAME}:${VERSION}"
require_image "${IMAGE_NAME}:php-${VERSION}"
require_image "${IMAGE_NAME}:python-${VERSION}"
require_image "${IMAGE_NAME}:go-${VERSION}"
require_image "${IMAGE_NAME}:nginx-${VERSION}"

# --- base ---
log "Testing base image"
base_id="$(start_container "httpd-test-base-$$" \
  -p 18080:80 -p 18443:443 \
  "${httpd_env[@]}" \
  "${IMAGE_NAME}:${VERSION}")"
if wait_for_http "http://127.0.0.1:18080/" && wait_for_http "https://127.0.0.1:18443/"; then
  pass "base responds on HTTP and HTTPS"
else
  fail "base did not become ready on HTTP/HTTPS"
fi

# --- php ---
log "Testing php image"
php_id="$(start_container "httpd-test-php-$$" \
  -p 18081:80 -p 18444:443 \
  "${httpd_env[@]}" \
  -v "${EXAMPLES_DIR}:/var/www/html:ro" \
  "${IMAGE_NAME}:php-${VERSION}")"
if wait_for_http "http://127.0.0.1:18081/" \
  && assert_body_contains "http://127.0.0.1:18081/" "PHP is working" \
  && assert_body_contains "https://127.0.0.1:18444/" "PHP is working"; then
  pass "php serves examples/index.php over HTTP and HTTPS"
else
  fail "php flavor smoke test failed"
fi

# --- python ---
log "Testing python image"
python_id="$(start_container "httpd-test-python-$$" \
  -p 18082:80 -p 18445:443 \
  "${httpd_env[@]}" \
  -v "${EXAMPLES_DIR}:/var/www/html:ro" \
  "${IMAGE_NAME}:python-${VERSION}")"
if wait_for_http "http://127.0.0.1:18082/" \
  && assert_body_contains "http://127.0.0.1:18082/" "Python (mod_wsgi) is working" \
  && assert_body_contains "https://127.0.0.1:18445/" "Python (mod_wsgi) is working"; then
  pass "python serves examples/index.py over HTTP and HTTPS"
else
  fail "python flavor smoke test failed"
fi

# --- go ---
log "Testing go image"
go_id="$(start_container "httpd-test-go-$$" \
  -p 18083:80 -p 18446:443 \
  "${httpd_env[@]}" \
  "${IMAGE_NAME}:go-${VERSION}")"
if ! docker exec "${go_id}" go version >/dev/null; then
  fail "go binary missing in go flavor"
else
  pass "go toolchain is available"
fi

docker exec "${go_id}" bash -lc '
  set -euo pipefail
  cat >/tmp/index.go <<'"'"'EOF'"'"'
package main

import (
  "fmt"
  "net/http"
  "net/http/cgi"
  "runtime"
)

func main() {
  if err := cgi.Serve(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    fmt.Fprintf(w, "<!DOCTYPE html><html><body><h1>Go (CGI) is working</h1><p>%s</p></body></html>", runtime.Version())
  })); err != nil {
    panic(err)
  }
}
EOF
  go build -o /var/www/html/index.cgi /tmp/index.go
  chmod 755 /var/www/html/index.cgi
'

if wait_for_http "http://127.0.0.1:18083/" \
  && assert_body_contains "http://127.0.0.1:18083/" "Go (CGI) is working" \
  && assert_body_contains "https://127.0.0.1:18446/" "Go (CGI) is working"; then
  pass "go serves CGI app over HTTP and HTTPS"
else
  fail "go flavor smoke test failed"
fi

# --- nginx ---
log "Testing nginx image"
nginx_id="$(start_container "httpd-test-nginx-$$" \
  -p 18084:80 -p 18447:443 \
  "${nginx_env[@]}" \
  -v "${EXAMPLES_DIR}/nginx:/var/www/html:ro" \
  "${IMAGE_NAME}:nginx-${VERSION}")"
if wait_for_http "http://127.0.0.1:18084/" \
  && assert_body_contains "http://127.0.0.1:18084/" "Nginx is working" \
  && assert_body_contains "https://127.0.0.1:18447/" "Nginx is working"; then
  pass "nginx serves index.html over HTTP and HTTPS"
else
  fail "nginx flavor smoke test failed"
fi

log "Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"
if [[ "${FAIL_COUNT}" -ne 0 ]]; then
  exit 1
fi
