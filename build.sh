#!/bin/sh

# This is a script to build the Jekyll page
# and push my contents to Algolia index

bundle exec jekyll build && jekyll algolia
