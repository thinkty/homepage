# This Dockerfile has been created with references to
# https://docs.aws.amazon.com/amplify/latest/userguide/custom-build-image.html
# https://jekyllrb.com/docs/installation/ubuntu/

FROM ubuntu:18.04

RUN apt-get update

# Install latest Ruby and required system packages
RUN apt-get install -y ruby-full build-essential zlib1g-dev

# Install Bundler and Jekyll
RUN gem install bundler jekyll

# Install the gems from Gemfile
CMD bundle install

# Build the jekyll site with algolia
CMD jekyll build && jekyll algolia

# Open port 80
EXPOSE 80
