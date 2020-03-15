#!/bin/bash

cd lib/deeployer
jsonnetfmt -i *.*sonnet
cd ../../tests
jsonnetfmt -i *.*sonnet
