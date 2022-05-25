#!/usr/bin/env bash

DELETE_FLAG="true"

ENV=dev
API_TARGET="http://py-web:9999"
API_REPORT_FILE="api_report.json"
CONTAINER_NAME="zap2docker_scan"
APP_DIR="rest-api-goat"
REPORT_FOLDER="reports"

test -d "${REPORT_FOLDER}" || mkdir -p "${REPORT_FOLDER}"
if [ $DELETE_FLAG == "true" ]
then
	docker-compose rm -f web
	docker-compose rm -f py-web
	docker-compose rm -f zap2docker
fi

pushd "$APP_DIR" || return

# Goat REST API
docker-compose --no-cache web
docker-compose up -d web
docker-compose logs web

# Goat OpenAPI definition
docker-compose --no-cache py-web
docker-compose up -d py-web
docker-compose logs py-web

# OWASP ZAP
docker-compose run --name "$CONTAINER_NAME" -d -e ENV=dev -e REPORT_FILE="$API_REPORT_FILE" -e TARGET="$API_TARGET" zap2docker
docker logs -f "$CONTAINER_NAME"

popd || return