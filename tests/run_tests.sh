#!/bin/bash

export JSONNET_PATH=../vendor/:../lib/


# First parameter: Test name
# Second parameter: libsonnet test file
# Third parameter: Expected error message
function expectError() {
    echo "Running test: $1"

    OUTPUT=`jsonnet "$2" 2>&1`
    if [[ $? == 0 ]]; then
        echo "Expected an error message"
        exit 1
    fi
    (echo $OUTPUT | grep "$3") > /dev/null
    if [[ $? != 0 ]]; then
        echo "Expected error message '$3'"
        exit 1
    fi

    echo "Successfully tested: $1"
}

# First parameter: Test name
# Second parameter: libsonnet test file
# Third parameter: JSON Path (as interpreted by jq)
# Fourth parameter: Value expected
function expectValue() {
    echo "Running test: $1"

    OUTPUT=`jsonnet "$2" | jq "$3"`
    if [[ $? != 0 ]]; then
        echo "Jsonnet returned an error code"
        exit 1
    fi
    (echo $OUTPUT | grep "$3") > /dev/null
    if [[ $OUTPUT != "$4" ]]; then
        echo "Expected '$4', got '$OUTPUT'"
        exit 1
    fi

    echo "Successfully tested: $1"
}


expectError "Testing creation of host without a port" "host_without_port.jsonnet" "Can't create container by deployment without any port with deeployer"
expectValue "Testing creation of ingress when a host is added" "host.jsonnet" "Can't create container by deployment without any port with deeployer"