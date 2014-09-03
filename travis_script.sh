#!/bin/bash

set -e

./bin/s3utils files upload -s ./examples/stormtroopocat.png -t products/unprocessed/stormtroopocat.png
./bin/s3utils images convert -d ./examples/descriptions.json
./bin/s3utils files delete -p products/ -r 'products\/[\w\-]+\.png'
