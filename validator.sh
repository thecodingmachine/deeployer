#!/bin/bash

cd environments/default
jsonlint *.json -q
jsonnetfmt *.jsonnet >/dev/null

cd ../../lib/
jsonnetfmt  *.libsonnet >/dev/null

cd deeployer
jsonnetfmt  docker-compose-generator.libsonnet >/dev/null
jsonnetfmt resource_generator.libsonnet >/dev/null

cd ../../scripts
jsonlint *.json -q
jsonnetfmt docker-compose.jsonnet >/dev/null
jsonnetfmt main.jsonnet >/dev/null

cd ../tests/docker-compose-prod
jsonlint *.json  -q

cd ../schema
jsonlint *.json -q

cd .. #location : test/
jsonlint *.json -q

cd .. #location : root/
jsonlint *.json -q
jsonnetfmt deeployer.libsonnet >/dev/null

