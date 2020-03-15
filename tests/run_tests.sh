#!/bin/bash

source ./test_functions.sh

expectError "Testing creation of host without a port" "host_without_port.jsonnet" "Can't create container by deployment without any port with deeployer"
expectValue "Testing creation of ingress when a host is added" "host.jsonnet" ".generatedConf.php_myadmin.ingress.spec.rules[0].host" '"myhost.com"'
