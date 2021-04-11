#!/bin/sh

# This is a script to build the Jekyll page
# and push my contents to Algolia index

JEKYLL_ENV=production bundle exec jekyll build
cowsay "Build complete. Updating Algolia"
jekyll algolia
