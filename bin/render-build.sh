#!/usr/bin/env bash

set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Si la variable FORCE_DB_RESET est définie, forcer la recréation complète
if [ "$FORCE_DB_RESET" = "true" ]; then
  echo "🔄 FORCE_DB_RESET activé - Recréation complète de la DB"
  bundle exec rails db:drop || true
  bundle exec rails db:create
  bundle exec rails db:migrate
  bundle exec rails db:seed || true
else
  echo "📋 Migration normale"
  bundle exec rails db:migrate
fi