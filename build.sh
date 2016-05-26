#!/bin/bash -e

IMAGE_ELASTICSEARCH_BASE="choffmeister/elasticsearch-prefilled"
IMAGE_ELASTICSEARCH_TEMP="epages-docs-elasticsearch-${RANDOM}${RANDOM}${RANDOM}"

IMAGE_ELASTICSEARCH="docker.epages.com/epages/docs-elasticsearch"
IMAGE_NGINX="docker.epages.com/epages/docs-nginx"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}"

TAG="$1"

bundle install
bundle exec rake build

# build elasticsearch image
docker run --name "${IMAGE_ELASTICSEARCH_TEMP}" -p 9200:9200 -d "${IMAGE_ELASTICSEARCH_BASE}"
sleep 10
bundle exec rake index
sleep 10
docker stop "${IMAGE_ELASTICSEARCH_TEMP}"
docker commit "${IMAGE_ELASTICSEARCH_TEMP}" "${IMAGE_ELASTICSEARCH}:${TAG}"
docker rm -vf "${IMAGE_ELASTICSEARCH_TEMP}"

# build nginx image
docker build -t "${IMAGE_NGINX}:${TAG}" -f Dockerfile.nginx .
