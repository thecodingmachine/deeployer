#!/bin/bash

source ./test_functions.sh

set -e

# Kubernetes tests
echo "Starting Kubernetes tests"

expectError "Testing creation of host without a port" "host_without_port.json" "Can't create container by deployment without any port with deeployer" ../scripts/main.jsonnet
expectValue "Testing creation of ingress when a host is added" "host.json" ".generatedConf.php_myadmin.ingress.spec.rules[0].host" '"myhost.com"' ../scripts/main.jsonnet
assertValidK8s "host.json" ../scripts/main.jsonnet

# Docker-compose tests
echo "Starting docker-compose tests"

expectValue "Testing there is no Traefik if there is no container with a host" "docker-compose-prod/no_host.json" ".docker_compose.services.traefik" 'null'  ../scripts/docker-compose.jsonnet
expectValue "Testing creation of Traefik when a host is added" "docker-compose-prod/host.json" ".docker_compose.services.traefik.image" '"traefik:2"'  ../scripts/docker-compose.jsonnet

# Schema test
echo "Starting JsonSchema tests"

ajv test -s ../deeployer.schema.json -d schema/valid.json --valid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_definition_with_unknown_properties.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_with_wrong_declared_envVars.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_container_definition_without_image.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_test_testing_envVars_with_a_specialObject.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_test_testing_envVars_with_nonStringValue.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_properties_definition_with_emptyString_in_image.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_properties_definition_with_emptyString_in_max_cpu.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_properties_definition_with_emptyString_in_min_cpu.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_properties_definition_with_emptyString_in_max_memory.json --invalid
ajv test -s ../deeployer.schema.json -d schema/invalid_properties_definition_with_emptyString_in_min_memory.json --invalid

echo
echo
echo -e "\e[32m✓✓\e[39m All tests successful! ✓✓"
