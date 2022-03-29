#!/bin/sh

# Issue No.1
cowsay "Make sure you are not using 'serve' before deployment (issue #1)"

# This is a script to deploy the _site to aws S3
aws s3 sync _site/ s3://thinkty.net --profile default
