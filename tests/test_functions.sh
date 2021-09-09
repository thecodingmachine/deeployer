#!/bin/bash

export JSONNET_PATH=../vendor/:../lib/

# First parameter: Test name
# Second parameter: libsonnet test file
# Third parameter: Expected error message
function expectError() {
    set +e
    echo "  Running test:        $1"

    config=$(cat "$2")

    OUTPUT=$(jsonnet ../scripts/main.jsonnet --ext-code config="$config" --ext-str timestamp="2020-05-05 00:00:00" 2>&1)
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
# Second parameter: json test file
# Third parameter: JSON Path (as interpreted by jq)
# Fourth parameter: Value expected
# Fifth parameter: The test script to lanch (K8S or docker-compose)
function expectValue() {
    set +e


    echo "  Running test:        $1"

    set -o pipefail

    config=$(cat "$2")

    OUTPUT=$(jsonnet $5 --ext-code config="$config" --ext-str timestamp="2020-05-05 00:00:00" | jq "$3")
    if [[ $? != 0 ]]; then
        echo -e "\e[31m❌\e[39m Jsonnet returned an error code"
        set -e
        exit 1
    fi
    set +o pipefail
    if [[ $OUTPUT != "$4" ]]; then
        echo -e "\e[31m❌\e[39m Expected '$4'"
        echo "  Instead, got '$OUTPUT'"
        set -e
        exit 1
    fi

    echo -e "\e[32m✓\e[39m Successfully tested: $1"
    set -e
}

# Asserts that generated configuration file is a valid Kubernetes deployment
# First parameter: libsonnet test file
function assertValidK8s() {
    set +e


    echo "  Testing K8S validity for: $1"

    set -o pipefail
    OUTPUT=$(../scripts/deeployer-k8s show "$1" | kubeval --ignore-missing-schemas)
    if [[ $? != 0 ]]; then
        echo -e "\e[31m❌\e[39m Kubeval returned an error code"
        echo ""
        echo "  Tanka output:"
        echo ""
        ../scripts/deeployer-k8s show "$1"
        echo ""
        echo "  Kubeval error message:"
        echo ""
        echo "$OUTPUT"
        set -e
        exit 1
    fi
    set +o pipefail

    echo -e "\e[32m✓\e[39m Successfully tested K8S validity for $1"
    set -e
}
