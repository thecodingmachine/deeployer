#!/bin/bash

source ./test_functions.sh

set -e

# Kubernetes tests
echo "Starting Kubernetes tests"

expectError "Testing creation of host without a port" "host_without_port.json" "For container \"phpmyadmin\", host \"myhost.com\" needs a port to bind to. Please provide a containerPort in the \"host\" section." ../scripts/main.jsonnet
expectValue "Testing creation of ingress when a host is added" "host.json" ".generatedConf.phpmyadmin.ingress.spec.rules[0].host" '"myhost.com"' ../scripts/main.jsonnet
expectValue "Testing containerPort of ingress when a host is added" "host_with_container_port.json" ".generatedConf.phpmyadmin.ingress.spec.rules[0].host" '"myhost.com"' ../scripts/main.jsonnet
expectValue "Testing https enable (metadata section)" "host_with_https.json" ".generatedConf.phpmyadmin.ingress.metadata.annotations[\"cert-manager.io/issuer\"]" '"letsencrypt-prod"' ../scripts/main.jsonnet
expectValue "Testing https enable (tls section)" "host_with_https.json" ".generatedConf.phpmyadmin.ingress.spec.tls[0].hosts[0]" '"myhost.com"' ../scripts/main.jsonnet
expectValue "Testing https enable (issuer)" "host_with_https.json" ".generatedConf.issuer.kind" '"Issuer"' ../scripts/main.jsonnet
expectError "Testing https enable (missing mail)" "host_with_https_without_mail.json" "In order to have support for HTTPS, you need to provide an email address in the { \"config\": { \"https\": { \"mail\": \"some@email.com\" } } }" ../scripts/main.jsonnet
expectValue "Testing the presence of a timestamp label to force reloading" "host.json" ".generatedConf.phpmyadmin.deployment.spec.template.metadata.labels.deeployerTimestamp" '"2020-05-05 00:00:00"' ../scripts/main.jsonnet
assertValidK8s "host.json" ../scripts/main.jsonnet
assertValidK8s "volume.json" ../scripts/main.jsonnet

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
echo -e "\e[32m✓✓\e[39m All tests successful! \e[32m✓✓\e[39m"
