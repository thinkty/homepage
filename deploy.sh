#!/bin/sh

# This is a script to deploy the _site to aws S3
aws s3 sync _site/ s3://thinkty.net --profile default
