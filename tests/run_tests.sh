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

expectError "Testing creation of host without a port" "host_without_port.libsonnet" "Can't create container by deployment without any port with deeployer"
