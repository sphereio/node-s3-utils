#!/bin/bash

cat > "credentials.json" << EOF
{
  "aws_key": "${AWS_KEY}",
  "aws_secret": "${AWS_SECRET}",
  "aws_bucket": "${AWS_BUCKET}"
}
EOF