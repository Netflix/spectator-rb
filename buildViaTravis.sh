#!/bin/sh

set -e
set -x

pwd

cat .rubocop.yml

bundle exec rubocop --version

bundle exec rake test
bundle exec rake rubocop
