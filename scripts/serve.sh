#!/bin/sh

# Ensure rbenv-managed Ruby is available when running the script
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
	eval "$(rbenv init -)"
	rbenv rehash
fi

# Start Jekyll with LiveReload and bind to all interfaces
bundle exec jekyll serve --livereload --host 0.0.0.0
