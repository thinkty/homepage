#!/bin/sh
set -e

# Ensure rbenv-managed Ruby is available when running the script
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - sh)"
    rbenv rehash
fi

# Stop any existing Jekyll processes that may still be holding the preview ports
if command -v lsof >/dev/null 2>&1; then
    lsof -ti :4000 2>/dev/null | xargs -r kill -9
    lsof -ti :35729 2>/dev/null | xargs -r kill -9
fi

# Start Jekyll with LiveReload and bind to all interfaces
bundle exec jekyll serve --livereload --host 0.0.0.0
