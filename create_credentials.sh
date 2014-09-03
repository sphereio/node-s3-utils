#!/bin/bash

cat > ".s3-credentials.json" << EOF
{
  "key": "${TRAVIS_S3_KEY}",
  "secret": "${TRAVIS_S3_SECRET}",
  "bucket": "${TRAVIS_S3_BUCKET}"
}
EOF