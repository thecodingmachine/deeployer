#!/bin/bash

# Formatting (j/lib)sonnet files
cd lib/deeployer
jsonnetfmt -i *.*sonnet
cd ../../tests
jsonnetfmt -i *.*sonnet
cd docker-compose-prod
jsonnetfmt -i *.*sonnet

# Getting back to root
cd ../..

# Formatting json files
json-format *.json
cd environments/default/
json-format spec.json
cd ../../tests/schema
json-format *.json



