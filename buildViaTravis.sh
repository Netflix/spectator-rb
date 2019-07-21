#!/bin/sh

set -e
set -x

bundle exec rake test
bundle exec rake rubocop
