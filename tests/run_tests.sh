#!/bin/bash

source ./test_functions.sh

# Kubernetes tests
echo "Starting Kubernetes tests"

expectError "Testing creation of host without a port" "host_without_port.jsonnet" "Can't create container by deployment without any port with deeployer"
expectValue "Testing creation of ingress when a host is added" "host.jsonnet" ".generatedConf.php_myadmin.ingress.spec.rules[0].host" '"myhost.com"'

echo ""


# Docker-compose tests
echo "Starting docker-compose tests"

expectValue "Testing there is no Traefik if there is no container with a host" "docker-compose-prod/no_host.jsonnet" ".docker_compose.services.traefik" 'null'
expectValue "Testing creation of Traefik when a host is added" "docker-compose-prod/host.jsonnet" ".docker_compose.services.traefik.image" '"traefik:2"'
