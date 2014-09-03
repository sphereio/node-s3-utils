#!/bin/bash

cat > ".s3-credentials.json" << EOF
{
  "key": "${AWS_KEY}",
  "secret": "${AWS_SECRET}",
  "bucket": "${AWS_BUCKET}"
}
EOF