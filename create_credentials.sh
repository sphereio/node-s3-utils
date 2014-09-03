#!/bin/bash

cat > ".s3-credentials.json" << EOF
{
  "key": "${S3_KEY}",
  "secret": "${S3_SECRET}",
  "bucket": "${S3_BUCKET}"
}
EOF