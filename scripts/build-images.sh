#!/usr/bin/env bash
# Build (and optionally push) base, php, python, go, and nginx image tags for wsams/httpd.
#
# Usage:
#   ./scripts/build-images.sh 1.2.3
#   PUSH=true FLOAT_BASE=latest FLOAT_PHP=php FLOAT_PYTHON=python FLOAT_GO=go FLOAT_NGINX=nginx \
#     ./scripts/build-images.sh 1.2.3
#   FLOAT_BASE=nightly FLOAT_PHP=php-nightly FLOAT_PYTHON=python-nightly \
#     FLOAT_GO=go-nightly FLOAT_NGINX=nginx-nightly \
#     ./scripts/build-images.sh nightly-20260712
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-wsams/httpd}"
VERSION="${1:?Usage: $0 <version>}"
PUSH="${PUSH:-false}"
PLATFORM="${PLATFORM:-}"

docker_build() {
  if [[ -n "${PLATFORM}" ]]; then
    docker build --platform "${PLATFORM}" "$@"
  else
    docker build "$@"
  fi
}

echo "Building ${IMAGE_NAME}:${VERSION}"
docker_build \
  -t "${IMAGE_NAME}:${VERSION}" \
  -f Dockerfile \
  --pull \
  .

echo "Building ${IMAGE_NAME}:php-${VERSION}"
docker_build \
  -t "${IMAGE_NAME}:php-${VERSION}" \
  -f Dockerfile.php \
  --build-arg "BASE_IMAGE=${IMAGE_NAME}:${VERSION}" \
  .

echo "Building ${IMAGE_NAME}:python-${VERSION}"
docker_build \
  -t "${IMAGE_NAME}:python-${VERSION}" \
  -f Dockerfile.python \
  --build-arg "BASE_IMAGE=${IMAGE_NAME}:${VERSION}" \
  .

echo "Building ${IMAGE_NAME}:go-${VERSION}"
docker_build \
  -t "${IMAGE_NAME}:go-${VERSION}" \
  -f Dockerfile.go \
  --build-arg "BASE_IMAGE=${IMAGE_NAME}:${VERSION}" \
  .

echo "Building ${IMAGE_NAME}:nginx-${VERSION}"
docker_build \
  -t "${IMAGE_NAME}:nginx-${VERSION}" \
  -f Dockerfile.nginx \
  --pull \
  .

tag_and_maybe_push() {
  local source="$1"
  local target="$2"
  docker tag "${source}" "${target}"
  if [[ "${PUSH}" == "true" ]]; then
    docker push "${target}"
  fi
}

if [[ "${PUSH}" == "true" ]]; then
  docker push "${IMAGE_NAME}:${VERSION}"
  docker push "${IMAGE_NAME}:php-${VERSION}"
  docker push "${IMAGE_NAME}:python-${VERSION}"
  docker push "${IMAGE_NAME}:go-${VERSION}"
  docker push "${IMAGE_NAME}:nginx-${VERSION}"
fi

IFS=',' read -r -a base_floats <<< "${FLOAT_BASE:-}"
for t in "${base_floats[@]+"${base_floats[@]}"}"; do
  [[ -z "${t}" ]] && continue
  tag_and_maybe_push "${IMAGE_NAME}:${VERSION}" "${IMAGE_NAME}:${t}"
done

IFS=',' read -r -a php_floats <<< "${FLOAT_PHP:-}"
for t in "${php_floats[@]+"${php_floats[@]}"}"; do
  [[ -z "${t}" ]] && continue
  tag_and_maybe_push "${IMAGE_NAME}:php-${VERSION}" "${IMAGE_NAME}:${t}"
done

IFS=',' read -r -a python_floats <<< "${FLOAT_PYTHON:-}"
for t in "${python_floats[@]+"${python_floats[@]}"}"; do
  [[ -z "${t}" ]] && continue
  tag_and_maybe_push "${IMAGE_NAME}:python-${VERSION}" "${IMAGE_NAME}:${t}"
done

IFS=',' read -r -a go_floats <<< "${FLOAT_GO:-}"
for t in "${go_floats[@]+"${go_floats[@]}"}"; do
  [[ -z "${t}" ]] && continue
  tag_and_maybe_push "${IMAGE_NAME}:go-${VERSION}" "${IMAGE_NAME}:${t}"
done

IFS=',' read -r -a nginx_floats <<< "${FLOAT_NGINX:-}"
for t in "${nginx_floats[@]+"${nginx_floats[@]}"}"; do
  [[ -z "${t}" ]] && continue
  tag_and_maybe_push "${IMAGE_NAME}:nginx-${VERSION}" "${IMAGE_NAME}:${t}"
done

echo "Built ${IMAGE_NAME}:{,php-,python-,go-,nginx-}${VERSION}"
