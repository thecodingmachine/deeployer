#!/bin/bash

cd environments/default
jsonlint *.json -i
jsonnetfmt *.jsonnet -i

cd ../../lib/
jsonnetfmt -i *.libsonnet

cd deeployer
# jsonnetfmt -i docker-compose-generator.libsonnet
# jsonnetfmt -i resource_generator.libsonnet
jsonnetfmt -i *.libsonnet

cd ../../scripts
jsonlint *.json -i 
jsonnetfmt -i *.jsonnet

cd ../tests/docker-compose-prod
jsonlint *.json -i 

cd ../schema
jsonlint *.json -i 

cd .. #location : test/
jsonlint *.json -i 

cd .. #location : root/
jsonlint *.json -i
jsonnetfmt *.libsonnet -i

