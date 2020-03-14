#!/bin/bash

export JSONNET_PATH=../vendor/:../lib/


# First parameter: Test name
# Second parameter: libsonnet test file
# Third parameter: Expected error message
function expectError() {
    echo "  Running test:        $1"

    OUTPUT=`jsonnet "$2" 2>&1`
    if [[ $? == 0 ]]; then
        echo -e "\e[31m❌\e[39m Expected an error message"
        echo "  Instead, got '$OUTPUT'"
        exit 1
    fi
    (echo $OUTPUT | grep "$3") > /dev/null
    if [[ $? != 0 ]]; then
        echo -e "\e[31m❌\e[39m Expected error message '$3'"
        echo "  Instead, got '$OUTPUT'"
        exit 1
    fi

    echo -e "\e[32m✓\e[39m Successfully tested: $1"
}

# First parameter: Test name
# Second parameter: libsonnet test file
# Third parameter: JSON Path (as interpreted by jq)
# Fourth parameter: Value expected
function expectValue() {
    echo "  Running test:        $1"

    set -o pipefail
    OUTPUT=`jsonnet "$2" | jq "$3"`
    if [[ $? != 0 ]]; then
        echo -e "\e[31m❌\e[39m Jsonnet returned an error code"
        exit 1
    fi
    set +o pipefail
    (echo $OUTPUT | grep "$3") > /dev/null
    if [[ $OUTPUT != "$4" ]]; then
        echo -e "\e[31m❌\e[39m Expected '$4'"
        echo "  Instead, got '$OUTPUT'"
        exit 1
    fi

    echo -e "\e[32m✓\e[39m Successfully tested: $1"
}


expectError "Testing creation of host without a port" "host_without_port.jsonnet" "Can't create container by deployment without any port with deeployer"
expectValue "Testing creation of ingress when a host is added" "host.jsonnet" ".generatedConf.php_myadmin.ingress.spec.rules[0].host" '"myhost.com"'
