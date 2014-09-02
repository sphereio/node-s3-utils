#!/bin/bash

cat > "credentials.json" << EOF
/* SPHERE.IO credentials */
{
  "aws_key": "${AWS_KEY}",
  "aws_secret": "${AWS_SECRET}",
  "aws_bucket": "${AWS_BUCKET}"
}
EOF