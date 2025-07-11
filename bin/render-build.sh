#!/usr/bin/env bash

set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

bundle exec rails db:migrate
bundle exec rails db:cleanup_cart_items
bundle exec rails db:cleanup_order_items