#!/usr/bin/env bash

set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

bundle exec rails db:migrate
bundle exec rails production:fix_constraints || true
bundle exec rails production:emergency_cleanup || true
bundle exec rails db:cleanup_cart_items || true
bundle exec rails db:cleanup_order_items || true