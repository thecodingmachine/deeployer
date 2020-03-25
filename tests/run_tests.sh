#!/bin/bash

source ./test_functions.sh

set -e

# Kubernetes tests
echo "Starting Kubernetes tests"

expectError "Testing creation of host without a port" "host_without_port.jsonnet" "Can't create container by deployment without any port with deeployer"
expectValue "Testing creation of ingress when a host is added" "host.jsonnet" ".generatedConf.php_myadmin.ingress.spec.rules[0].host" '"myhost.com"'

# Docker-compose tests
echo "Starting docker-compose tests"

expectValue "Testing there is no Traefik if there is no container with a host" "docker-compose-prod/no_host.jsonnet" ".docker_compose.services.traefik" 'null'
expectValue "Testing creation of Traefik when a host is added" "docker-compose-prod/host.jsonnet" ".docker_compose.services.traefik.image" '"traefik:2"'

# Schema test
echo "Starting JsonSchema tests"

ajv test -s ../deeployer.schema.json -d schema/valid.json --valid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_definition_with_unknown_properties.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_with_wrong_declared_envVars.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_definition_without_image.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_definition_without_ports.json --invalid
